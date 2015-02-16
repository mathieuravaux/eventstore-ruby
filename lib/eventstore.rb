require 'securerandom'

class Eventstore
  attr_reader :connection, :context, :error_handler
  def initialize(host, port=2113)
    @context = ConnectionContext.new
    @connection = Connection.new(host, port, context)
  end

  def on_error(error=nil, &block)
    context.on_error(error, &block)
  end

  def send_command(*args, &block)
    connection.send_command(*args, &block)
  end

  def close
    connection.close
  end

  def ping
    send_command("Ping")
  end

  def new_event(event_type, data, content_type: "json", uuid: nil)
    uuid ||= SecureRandom.uuid
    content_type_code = {"json" => 1}.fetch(content_type, 0)
    NewEvent.new(
      event_id: Eventstore.uuid_to_binary(uuid),
      event_type: event_type,
      data: data,
      data_content_type: content_type_code,
      metadata_content_type: 1
    )
  end

  def write_events(stream, events)
    events = Array(events)
    msg = WriteEvents.new(
      event_stream_id: stream,
      expected_version: -2,
      events: events,
      require_master: true
    )
    send_command("WriteEvents", msg)
  end

  def read_stream_events_forward(stream, start, max)
    msg = ReadStreamEvents.new(
      event_stream_id: stream,
      from_event_number: start,
      max_count: max,
      resolve_link_tos: true,
      require_master: false
    )
    send_command("ReadStreamEventsForward", msg)
  end

  def new_catchup_subscription(*args)
    CatchUpSubscription.new(self, *args)
  end

  def new_subscription(*args)
    Subscription.new(self, *args)
  end

end

require "eventstore/version"
require "eventstore/commands"
require "eventstore/messages"
require "eventstore/connection"
require "eventstore/subscription"
require "eventstore/catchup_subscription"

