class Eventstore
  class CannotConnectError < RuntimeError; end
  class DisconnectionError < RuntimeError; end

  def self.uuid_to_binary(uuid)
    uuid.scan(/[0-9a-f]{4}/).map { |x| x.to_i(16) }.pack('n*')
  end

  class Connection
    attr_reader :host, :port, :context, :error_handler
    attr_reader :buffer, :mutex

    def initialize(host, port, context)
      @host = host
      @port = Integer(port)
      @context = context

      @buffer = Buffer.new(&method(:on_received_package))
      @mutex = Mutex.new
    end

    def close
      @terminating = true
      socket.close
    end

    def send_command(command, msg = nil, target = nil, uuid = nil)
      code = COMMANDS.fetch(command)
      msg.validate! if msg

      correlation_id = uuid || SecureRandom.uuid
      frame = encode_message(code, correlation_id, msg)

      mutex.synchronize do
        promise = context.register_command(correlation_id, command, target)
        # puts "Sending #{command} command with correlation id #{correlation_id}"
        # puts "Sending to socket: #{frame.length} #{frame.inspect}"
        to_write = frame.to_s
        written = socket.write(to_write)
        fail if written != to_write.bytesize
        promise
      end
    end

    private

    def on_received_package(command, message, uuid, _flags)
      # p fn: "on_received_package", command: command
      # callback = context.received_package(uuid, command, message)
      case command
      when 'Pong' then                              context.fulfilled_command(uuid, 'Pong')
      when 'HeartbeatRequestCommand' then           send_command('HeartbeatResponseCommand')
      when 'SubscriptionConfirmation' then          context.fulfilled_command(uuid, decode(SubscriptionConfirmation, message))
      when 'ReadStreamEventsForwardCompleted' then  context.fulfilled_command(uuid, decode(ReadStreamEventsCompleted, message))
      when 'StreamEventAppeared' then               context.trigger(uuid, 'event_appeared', decode(StreamEventAppeared, message).event)
      when 'WriteEventsCompleted' then              on_write_events_completed(uuid, decode(WriteEventsCompleted, message))
      else fail command
      end
    end

    def on_write_events_completed(uuid, response)
      if response.result != OperationResult::Success
        p fn: 'on_write_events_completed', at: error, result: response.result
        context.rejected_command(uuid, response)
        return
      end

      context.fulfilled_command(uuid, response)
    end

    def decode(type, message)
      type.decode(message)
    rescue => error
      puts 'Protobuf decoding error'
      puts error.inspect
      p type: type, message: message
      puts "\n\n"
      puts(*error.backtrace)
    end

    def socket
      @socket || connect
    end

    def connect
      @socket = TCPSocket.open(host, port)
      process_downstream
      @socket
    rescue TimeoutError, Errno::ECONNREFUSED, Errno::EHOSTDOWN,
           Errno::EHOSTUNREACH, Errno::ENETUNREACH, Errno::ETIMEDOUT
      raise CannotConnectError, "Error connecting to Eventstore on #{host.inspect}:#{port.inspect} (#{$ERROR_INFO.class})"
    end

    def process_downstream
      Thread.new do
        begin
          loop do
            bytes = socket.readpartial(1024)
            buffer << bytes
          end
        rescue IOError, EOFError
          unless @terminating
            # puts "Eventstore disconnected"
            context.on_error(DisconnectionError.new('Eventstore disconnected'))
          end
        rescue => error
          puts error.inspect
          puts(*error.backtrace)
          context.on_error(error)
        end
      end
    end

    def encode_message(code, correlation_id, msg)
      frame = Beefcake::Buffer.new
      frame << code
      frame << 0x0 # non authenticated
      uuid_bytes = Eventstore.uuid_to_binary(correlation_id)
      uuid_bytes.each_byte { |b| frame << b }
      msg.encode(frame) if msg

      envelope = Beefcake::Buffer.new
      envelope.append_fixed32(frame.length)
      envelope << frame
      envelope
    end
  end
end
