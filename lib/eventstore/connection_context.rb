require 'promise'

class Eventstore
  # Extension of a Ruby implementation of the Promises/A+ spec
  # that carries the correlation id of the command.
  # @see https://github.com/lgierth/promise.rb
  class Promise < ::Promise
    attr_reader :correlation_id
    def initialize(correlation_id)
      super()
      @correlation_id = correlation_id
    end

    def wait
      t = Thread.current
      resume = proc { t.wakeup }
      self.then(resume, resume)
      sleep
    end
  end

  # Registry storing handlers for the outstanding commands and
  # current subscriptions
  class ConnectionContext
    attr_reader :mutex,  :requests, :targets
    def initialize
      @mutex = Mutex.new
      @requests = {}
      @targets = {}
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
    def register_command(uuid, command, target = nil)
      # p fn: "register_command", uuid: uuid, command: command
      case command
      when 'Ping' then promise(uuid)
      when 'ReadStreamEventsForward' then promise(uuid)
      when 'SubscribeToStream' then promise(uuid, target)
      when 'WriteEvents' then promise(uuid)
      when 'HeartbeatResponseCommand' then :nothing_to_do
      when 'UnsubscribeFromStream' then :nothing_to_do
      else fail("Unknown command #{command}")
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength

    def fulfilled_command(uuid, value)
      prom = nil
      mutex.synchronize do
        prom = requests.delete(uuid)
      end
      # p fn: "fulfilled_command", uuid: uuid, prom: prom, requests: requests
      prom.fulfill(value) if prom
    end

    def rejected_command(uuid, error)
      prom = nil
      mutex.synchronize do
        prom = requests.delete(uuid)
      end
      # p fn: "fulfilled_command", uuid: uuid, prom: prom, requests: requests
      prom.reject(error) if prom
    end

    def trigger(uuid, method, args)
      target = mutex.synchronize { targets[uuid] }
      return if target.nil?
      target.__send__(method, *args)
    end

    def on_error(error = nil, &block)
      if block
        @error_handler = block
      else
        @error_handler.call(error) if @error_handler
      end
    end

    private

    def promise(uuid, target = nil)
      prom = Promise.new(uuid)
      mutex.synchronize do
        requests[uuid] = prom
        targets[uuid] = target
      end
      prom
    end
  end
end
