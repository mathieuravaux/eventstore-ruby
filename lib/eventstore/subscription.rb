class Eventstore
  class Subscription
    attr_reader :connection, :stream, :resolve_link_tos
    def initialize(connection, stream, resolve_link_tos: true)
      @connection = connection
      @stream = stream
      @resolve_link_tos = resolve_link_tos
    end

    def on_error(error = nil, &block)
      if block
        @on_error = block
      else
        @on_error.call(error) if @on_error
      end
    end

    def on_event(event = nil, &block)
      if block
        @on_event = block
      else
        @on_event.call(event) if @on_event
      end
    end

    def start
      subscribe
    end

    def stop
      if @subscribe_response
        connection.send_command('UnsubscribeFromStream', UnsubscribeFromStream.new, uuid: @subscribe_response.correlation_id)
      end
      @subscribe_response = nil
    end

    def event_appeared(event)
      on_event(event)
    end

    private

    def subscribe
      args = SubscribeToStream.new(event_stream_id: stream, resolve_link_tos: resolve_link_tos)
      @subscribe_response = connection.send_command('SubscribeToStream', args, self)
      @subscribe_response.sync
    end
  end
end
