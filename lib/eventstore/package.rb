class Eventstore
  # Package is a length-prefixed binary frame transferred over TCP
  class Package
    def self.encode(code, correlation_id, msg)
      command = Beefcake::Buffer.new
      command << code
      command << 0x0 # non authenticated
      uuid_bytes = encode_uuid(correlation_id)
      uuid_bytes.each_byte { |b| command << b }
      msg.encode(command) if msg

      prefix_with_length(command)
    end

    def self.prefix_with_length(command)
      package = Beefcake::Buffer.new
      package.append_fixed32(command.length)
      package << command
      package
    end

    def encore_uuid(uuid)
      uuid.scan(/[0-9a-f]{4}/).map { |x| x.to_i(16) }.pack('n*')
    end

    def self.parse_uuid(bytes)
      a, b, c, d, e, f, g, h = *bytes.unpack('n*').map { |n| n.to_s(16) }.map { |n| n.rjust(4, '0') }
      [a, b, '-', c, '-', d, '-', e, '-', f, g, h].join('')
    end
  end
end
