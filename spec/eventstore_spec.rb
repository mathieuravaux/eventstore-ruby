require 'spec_helper'
require 'pry'

describe Eventstore do
  let(:es) { Eventstore.new('localhost', 1113) }
  subject { new_event_store }
  let(:injector) { new_event_store }

  def new_event_store
    es = Eventstore.new('localhost', 1113)
    es.on_error { |error| Thread.main.raise(error) }
    es
  end

  it 'supports the PING command' do
    Timeout.timeout(1) do
      promise = es.ping
      result = promise.sync
      expect(result).to eql 'Pong'
    end
  end

  def inject_event(stream)
    event_type = 'TestEvent'
    data = JSON.generate(at: Time.now.to_i, foo: 'bar')
    event = injector.new_event(event_type, data)
    # puts ">#{stream}\t\t#{event.inspect}"
    prom = injector.write_events(stream, event)
    prom.sync
  end

  it 'dumps the content of the outlet stream from the last checkpoint' do
    inject_events("outlet", 50)
    events = subject.read_stream_events_forward('outlet', 1, 20).sync
    expect(events).to be_kind_of(Eventstore::ReadStreamEventsCompleted)
    events.events.each do |event|
      expect(event).to be_kind_of(Eventstore::ResolvedIndexedEvent)
      JSON.parse(event.event.data)
    end
  end

  def inject_events_async(stream, target)
    Thread.new do
      begin
        inject_events(stream, target)
      rescue => error
        puts(error.inspect)
        puts(*error.backtrace)
        Thread.main.raise(error)
      end
    end
  end

  def inject_events(stream, target)
    target.times do |_i|
      inject_event(stream)
    end
  end

  it 'allows to make a live subscription' do
    stream = "catchup-test-#{SecureRandom.uuid}"
    received = 0


    sub = subject.new_subscription(stream)
    sub.on_event { |_event| received += 1 }
    sub.on_error { |error| fail(error.inspect) }
    sub.start

    inject_events(stream, 50)

    Timeout.timeout(20) do
      loop do
        break if received >= 50
        sleep(0.1)
      end
    end
  end

  it 'allows to make a catch-up subscription' do
    stream = "catchup-test-#{SecureRandom.uuid}"
    received = 0
    mutex = Mutex.new

    expect(subject.ping.sync).to eql 'Pong'

    # puts "stream: #{stream}"

    inject_events(stream, 1220)

    sub = subject.new_catchup_subscription(stream, -1)
    sub.on_event { |_event| mutex.synchronize { received += 1 } }
    sub.on_error { |error| fail error.inspect }
    sub.start

    inject_events_async(stream, 780)

    Timeout.timeout(10) do
      loop do
        break if received >= 2000
        sleep(0.1)
      end
    end
  end
end
