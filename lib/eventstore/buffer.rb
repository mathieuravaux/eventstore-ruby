class Eventstore
  def self.binary_to_uuid(bytes)
    a, b, c, d, e, f, g, h = *bytes.unpack('n*').map {|n| n.to_s(16) }.map { |n| n.rjust(4, "0") }
    [a, b, "-", c, "-", d, "-", e, "-", f, g, h].join("")
  end

  class Buffer
    attr_reader :buffer, :handler, :mutex
    def initialize(&block)
      @mutex = Mutex.new
      @buffer = ""
      @handler = block
    end

    def <<(bytes)
      mutex.synchronize do
        bytes = bytes.force_encoding('BINARY') if bytes.respond_to? :force_encoding
        buffer << bytes
        consume_available_packages
      end
    end

    def consume_available_packages
      loop do
        break if consume_next_package == :incomplete
      end
    end

    def consume_next_package
      #puts "fn=consume_next_package buffer=#{buffer.inspect}"
      return :incomplete if buffer.length < 4
      length = buffer[0...4].unpack("l<").first
      frame = buffer[4...(4 + length)]
      return :incomplete if frame.bytesize < length
      handle_frame(frame)
      @buffer = buffer[(4 + length)...-1]
      :consumed
    end

    def handle_frame(frame)
      code = frame[0].unpack('C').first
      flags = frame[1].unpack('C').first
      uuid_bytes = frame[2...(2 + 16)]
      message = frame[18..-1]

      command = Eventstore.command_name(code)
      handler.call(command, message, Eventstore.binary_to_uuid(uuid_bytes), flags)
    end

  end
end
