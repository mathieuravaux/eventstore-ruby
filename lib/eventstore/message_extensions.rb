class Eventstore
  # @see https://github.com/EventStore/EventStore/blob/master/src/EventStore.Core/Data/ResolvedEvent.cs#L9
  module OriginalEventMixin
    def original_event
      link ? link : event
    end

    def original_stream_id
      original_event.event_stream_id
    end

    def original_event_number
      original_event.event_number
    end
  end
end

Eventstore::ResolvedEvent.include(Eventstore::OriginalEventMixin)
Eventstore::ResolvedIndexedEvent.include(Eventstore::OriginalEventMixin)
