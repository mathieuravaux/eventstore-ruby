class Eventstore
  class Subscription
    attr_reader :es, :stream, :resolve_link_tos
    def initialize(es, stream, resolve_link_tos: true)
      @es = es
      @stream = stream
      @resolve_link_tos = resolve_link_tos
    end

    def on_error(error=nil, &block)
      if block
        @on_error = block
      else
        @on_error.call(error) if @on_error
      end
    end

    def on_event(event=nil, &block)
      if block
        @on_event = block
      else
        @on_event.call(event) if @on_event
      end
    end

    def start
      subscribe
    end

    def event_appeared(event)
      on_event(event)
    end

    private

    def subscribe
      args = SubscribeToStream.new(event_stream_id: stream, resolve_link_tos: resolve_link_tos)
      prom = es.send_command("SubscribeToStream", args, self)
      prom.sync
    end
  end
end