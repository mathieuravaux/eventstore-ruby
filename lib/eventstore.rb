require 'securerandom'

# The Eventstore class is responsible for maintaining a full-duplex connection
# between the client and the Event Store server.
# EventStore is thread-safe, and it is recommended that only one instance per application is created.
#
# All operations are handled fully asynchronously, returning a promise.
# If you need to execute synchronously, simply call .sync on the returned promise.
#
# To get maximum performance from the connection, it is recommended that it be used asynchronously.
class Eventstore
  VERSION = '0.0.2'

  attr_reader :host, :port, :connection, :context, :error_handler
  def initialize(host, port = 2113)
    @host = host
    @port = port
    @context = ConnectionContext.new
    @connection = Connection.new(host, port, context)
  end

  def on_error(error = nil, &block)
    context.on_error(error, &block)
  end

  def close
    connection.close
  end

  def ping
    command('Ping')
  end

  def new_event(event_type, data, content_type: 'json', uuid: nil)
    uuid ||= SecureRandom.uuid
    content_type_code = { 'json' => 1 }.fetch(content_type, 0)
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
    command('WriteEvents', msg)
  end

  def read_stream_events_forward(stream, start, max)
    msg = ReadStreamEvents.new(
      event_stream_id: stream,
      from_event_number: start,
      max_count: max,
      resolve_link_tos: true,
      require_master: false
    )
    command('ReadStreamEventsForward', msg)
  end

  def subscribe_to_stream(handler, stream, resolve_link_tos = false)
    msg = SubscribeToStream.new(event_stream_id: stream, resolve_link_tos: resolve_link_tos)
    command('SubscribeToStream', msg, handler)
  end

  def unsubscribe_from_stream(subscription_uuid)
    msg = UnsubscribeFromStream.new
    command('UnsubscribeFromStream', msg, uuid: subscription_uuid)
  end

  private

  def command(*args)
    connection.send_command(*args)
  end
end

require_relative 'eventstore/errors'
require_relative 'eventstore/package'
require_relative 'eventstore/messages'
require_relative 'eventstore/message_extensions'
require_relative 'eventstore/connection_context'
require_relative 'eventstore/connection'
require_relative 'eventstore/connection/buffer'
require_relative 'eventstore/connection/commands'
require_relative 'eventstore/subscription'
require_relative 'eventstore/catchup_subscription'
