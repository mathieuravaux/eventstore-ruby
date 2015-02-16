## Generated from vendor/proto/ClientMessageDtos.proto for EventStore.Client.Messages
require "beefcake"

class Eventstore

  module OperationResult
    Success = 0
    PrepareTimeout = 1
    CommitTimeout = 2
    ForwardTimeout = 3
    WrongExpectedVersion = 4
    StreamDeleted = 5
    InvalidTransaction = 6
    AccessDenied = 7
  end

  class NewEvent
    include Beefcake::Message
  end

  class EventRecord
    include Beefcake::Message
  end

  class ResolvedIndexedEvent
    include Beefcake::Message
  end

  class ResolvedEvent
    include Beefcake::Message
  end

  class WriteEvents
    include Beefcake::Message
  end

  class WriteEventsCompleted
    include Beefcake::Message
  end

  class DeleteStream
    include Beefcake::Message
  end

  class DeleteStreamCompleted
    include Beefcake::Message
  end

  class TransactionStart
    include Beefcake::Message
  end

  class TransactionStartCompleted
    include Beefcake::Message
  end

  class TransactionWrite
    include Beefcake::Message
  end

  class TransactionWriteCompleted
    include Beefcake::Message
  end

  class TransactionCommit
    include Beefcake::Message
  end

  class TransactionCommitCompleted
    include Beefcake::Message
  end

  class ReadEvent
    include Beefcake::Message
  end

  class ReadEventCompleted
    include Beefcake::Message

    module ReadEventResult
      Success = 0
      NotFound = 1
      NoStream = 2
      StreamDeleted = 3
      Error = 4
      AccessDenied = 5
    end
  end

  class ReadStreamEvents
    include Beefcake::Message
  end

  class ReadStreamEventsCompleted
    include Beefcake::Message

    module ReadStreamResult
      Success = 0
      NoStream = 1
      StreamDeleted = 2
      NotModified = 3
      Error = 4
      AccessDenied = 5
    end
  end

  class ReadAllEvents
    include Beefcake::Message
  end

  class ReadAllEventsCompleted
    include Beefcake::Message

    module ReadAllResult
      Success = 0
      NotModified = 1
      Error = 2
      AccessDenied = 3
    end
  end

  class SubscribeToStream
    include Beefcake::Message
  end

  class SubscriptionConfirmation
    include Beefcake::Message
  end

  class StreamEventAppeared
    include Beefcake::Message
  end

  class UnsubscribeFromStream
    include Beefcake::Message
  end

  class SubscriptionDropped
    include Beefcake::Message

    module SubscriptionDropReason
      Unsubscribed = 0
      AccessDenied = 1
    end
  end

  class NotHandled
    include Beefcake::Message

    module NotHandledReason
      NotReady = 0
      TooBusy = 1
      NotMaster = 2
    end

    class MasterInfo
      include Beefcake::Message
    end
  end

  class ScavengeDatabase
    include Beefcake::Message
  end

  class ScavengeDatabaseCompleted
    include Beefcake::Message

    module ScavengeResult
      Success = 0
      InProgress = 1
      Failed = 2
    end
  end

  class NewEvent
    required :event_id, :bytes, 1
    required :event_type, :string, 2
    required :data_content_type, :int32, 3
    required :metadata_content_type, :int32, 4
    required :data, :bytes, 5
    optional :metadata, :bytes, 6
  end

  class EventRecord
    required :event_stream_id, :string, 1
    required :event_number, :int32, 2
    required :event_id, :bytes, 3
    required :event_type, :string, 4
    required :data_content_type, :int32, 5
    required :metadata_content_type, :int32, 6
    required :data, :bytes, 7
    optional :metadata, :bytes, 8
    optional :created, :int64, 9
    optional :created_epoch, :int64, 10
  end

  class ResolvedIndexedEvent
    required :event, EventRecord, 1
    optional :link, EventRecord, 2
  end

  class ResolvedEvent
    required :event, EventRecord, 1
    optional :link, EventRecord, 2
    required :commit_position, :int64, 3
    required :prepare_position, :int64, 4
  end

  class WriteEvents
    required :event_stream_id, :string, 1
    required :expected_version, :int32, 2
    repeated :events, NewEvent, 3
    required :require_master, :bool, 4
  end

  class WriteEventsCompleted
    required :result, OperationResult, 1
    optional :message, :string, 2
    required :first_event_number, :int32, 3
    required :last_event_number, :int32, 4
    optional :prepare_position, :int64, 5
    optional :commit_position, :int64, 6
  end

  class DeleteStream
    required :event_stream_id, :string, 1
    required :expected_version, :int32, 2
    required :require_master, :bool, 3
    optional :hard_delete, :bool, 4
  end

  class DeleteStreamCompleted
    required :result, OperationResult, 1
    optional :message, :string, 2
    optional :prepare_position, :int64, 3
    optional :commit_position, :int64, 4
  end

  class TransactionStart
    required :event_stream_id, :string, 1
    required :expected_version, :int32, 2
    required :require_master, :bool, 3
  end

  class TransactionStartCompleted
    required :transaction_id, :int64, 1
    required :result, OperationResult, 2
    optional :message, :string, 3
  end

  class TransactionWrite
    required :transaction_id, :int64, 1
    repeated :events, NewEvent, 2
    required :require_master, :bool, 3
  end

  class TransactionWriteCompleted
    required :transaction_id, :int64, 1
    required :result, OperationResult, 2
    optional :message, :string, 3
  end

  class TransactionCommit
    required :transaction_id, :int64, 1
    required :require_master, :bool, 2
  end

  class TransactionCommitCompleted
    required :transaction_id, :int64, 1
    required :result, OperationResult, 2
    optional :message, :string, 3
    required :first_event_number, :int32, 4
    required :last_event_number, :int32, 5
    optional :prepare_position, :int64, 6
    optional :commit_position, :int64, 7
  end

  class ReadEvent
    required :event_stream_id, :string, 1
    required :event_number, :int32, 2
    required :resolve_link_tos, :bool, 3
    required :require_master, :bool, 4
  end

  class ReadEventCompleted
    required :result, ReadEventCompleted::ReadEventResult, 1
    required :event, ResolvedIndexedEvent, 2
    optional :error, :string, 3
  end

  class ReadStreamEvents
    required :event_stream_id, :string, 1
    required :from_event_number, :int32, 2
    required :max_count, :int32, 3
    required :resolve_link_tos, :bool, 4
    required :require_master, :bool, 5
  end

  class ReadStreamEventsCompleted
    repeated :events, ResolvedIndexedEvent, 1
    required :result, ReadStreamEventsCompleted::ReadStreamResult, 2
    required :next_event_number, :int32, 3
    required :last_event_number, :int32, 4
    required :is_end_of_stream, :bool, 5
    required :last_commit_position, :int64, 6
    optional :error, :string, 7
  end

  class ReadAllEvents
    required :commit_position, :int64, 1
    required :prepare_position, :int64, 2
    required :max_count, :int32, 3
    required :resolve_link_tos, :bool, 4
    required :require_master, :bool, 5
  end

  class ReadAllEventsCompleted
    required :commit_position, :int64, 1
    required :prepare_position, :int64, 2
    repeated :events, ResolvedEvent, 3
    required :next_commit_position, :int64, 4
    required :next_prepare_position, :int64, 5
    optional :result, ReadAllEventsCompleted::ReadAllResult, 6, :default => ReadAllEventsCompleted::ReadAllResult::Success
    optional :error, :string, 7
  end

  class SubscribeToStream
    required :event_stream_id, :string, 1
    required :resolve_link_tos, :bool, 2
  end

  class SubscriptionConfirmation
    required :last_commit_position, :int64, 1
    optional :last_event_number, :int32, 2
  end

  class StreamEventAppeared
    required :event, ResolvedEvent, 1
  end

  class UnsubscribeFromStream
  end

  class SubscriptionDropped
    optional :reason, SubscriptionDropped::SubscriptionDropReason, 1, :default => SubscriptionDropped::SubscriptionDropReason::Unsubscribed
  end

  class NotHandled

    class MasterInfo
      required :external_tcp_address, :string, 1
      required :external_tcp_port, :int32, 2
      required :external_http_address, :string, 3
      required :external_http_port, :int32, 4
      optional :external_secure_tcp_address, :string, 5
      optional :external_secure_tcp_port, :int32, 6
    end
    required :reason, NotHandled::NotHandledReason, 1
    optional :additional_info, :bytes, 2
  end

  class ScavengeDatabase
  end

  class ScavengeDatabaseCompleted
    required :result, ScavengeDatabaseCompleted::ScavengeResult, 1
    optional :error, :string, 2
    required :total_time_ms, :int32, 3
    required :total_space_saved, :int64, 4
  end
end
