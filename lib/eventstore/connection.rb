class Eventstore
  # Connection owns the TCP socket, formats and sends commands over the socket.
  # It also starts a background thread to read from the TCP socket and handle received packages,
  # dispatching them to the calling app.
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

    def send_command(command, msg = nil, handler = nil, uuid = nil)
      code = COMMANDS.fetch(command)
      msg.validate! if msg

      correlation_id = uuid || SecureRandom.uuid
      frame = Package.encode(code, correlation_id, msg)

      mutex.synchronize do
        promise = context.register_command(correlation_id, command, handler)
        # puts "Sending #{command} command with correlation id #{correlation_id}"
        # puts "Sending to socket: #{frame.length} #{frame.inspect}"
        to_write = frame.to_s
        socket.write(to_write)
        promise
      end
    end

    private

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    def on_received_package(command, message, uuid, _flags)
      # p(fn: "on_received_package", command: command)
      # callback = context.received_package(uuid, command, message)
      case command
      when 'Pong' then                              context.fulfilled_command(uuid, 'Pong')
      when 'HeartbeatRequestCommand' then           send_command('HeartbeatResponseCommand')
      when 'SubscriptionConfirmation' then          context.fulfilled_command(uuid, decode(SubscriptionConfirmation, message))
      when 'ReadStreamEventsForwardCompleted'
        context.fulfilled_command(uuid, decode(ReadStreamEventsCompleted, message))
      when 'StreamEventAppeared'
        resolved_event = decode(StreamEventAppeared, message).event
        context.trigger(uuid, 'event_appeared', resolved_event)
      when 'WriteEventsCompleted' then              on_write_events_completed(uuid, decode(WriteEventsCompleted, message))
      else fail command
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength

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
      puts "Protobuf decoding error on connection #{object_id}"
      puts error.inspect
      p type: type, message: message
      puts "\n\n"
      puts(*error.backtrace)
      raise error
    end

    def socket
      @socket || connect
    end

    def connect
      @socket = TCPSocket.open(host, port)
      Thread.new do
        process_downstream
      end
      @socket
    rescue TimeoutError, Errno::ECONNREFUSED, Errno::EHOSTDOWN,
           Errno::EHOSTUNREACH, Errno::ENETUNREACH, Errno::ETIMEDOUT
      raise CannotConnectError, "Error connecting to Eventstore on #{host.inspect}:#{port.inspect} (#{$ERROR_INFO.class})"
    end

    def process_downstream
      loop do
        buffer << socket.sysread(4096)
      end
    rescue IOError, EOFError
      on_disconnect
    rescue => error
      on_exception(error)
    end

    def on_disconnect
      return if @terminating
      puts 'Eventstore disconnected'
      context.on_error(DisconnectionError.new('Eventstore disconnected'))
    end

    def on_exception(error)
      puts "process_downstream_error #{error.inspect}"
      context.on_error(error)
    end
  end
end
