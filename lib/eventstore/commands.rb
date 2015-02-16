class Eventstore
  COMMANDS = {
    "HeartbeatRequestCommand".freeze => 0x01,
    "HeartbeatResponseCommand".freeze => 0x02,

    "Ping".freeze => 0x03,
    "Pong".freeze => 0x04,

    "PrepareAck".freeze => 0x05,
    "CommitAck".freeze => 0x06,

    "SlaveAssignment".freeze => 0x07,
    "CloneAssignment".freeze => 0x08,

    "SubscribeReplica".freeze => 0x10,
    "ReplicaLogPositionAck".freeze => 0x11,
    "CreateChunk".freeze => 0x12,
    "RawChunkBulk".freeze => 0x13,
    "DataChunkBulk".freeze => 0x14,
    "ReplicaSubscriptionRetry".freeze => 0x15,
    "ReplicaSubscribed".freeze => 0x16,

    # "CLIENT COMMANDS
    # "CreateStream".freeze => 0x80,
    # "CreateStreamCompleted".freeze => 0x81,

    "WriteEvents".freeze => 0x82,
    "WriteEventsCompleted".freeze => 0x83,

    "TransactionStart".freeze => 0x84,
    "TransactionStartCompleted".freeze => 0x85,
    "TransactionWrite".freeze => 0x86,
    "TransactionWriteCompleted".freeze => 0x87,
    "TransactionCommit".freeze => 0x88,
    "TransactionCommitCompleted".freeze => 0x89,

    "DeleteStream".freeze => 0x8A,
    "DeleteStreamCompleted".freeze => 0x8B,

    "ReadEvent".freeze => 0xB0,
    "ReadEventCompleted".freeze => 0xB1,
    "ReadStreamEventsForward".freeze => 0xB2,
    "ReadStreamEventsForwardCompleted".freeze => 0xB3,
    "ReadStreamEventsBackward".freeze => 0xB4,
    "ReadStreamEventsBackwardCompleted".freeze => 0xB5,
    "ReadAllEventsForward".freeze => 0xB6,
    "ReadAllEventsForwardCompleted".freeze => 0xB7,
    "ReadAllEventsBackward".freeze => 0xB8,
    "ReadAllEventsBackwardCompleted".freeze => 0xB9,

    "SubscribeToStream".freeze => 0xC0,
    "SubscriptionConfirmation".freeze => 0xC1,
    "StreamEventAppeared".freeze => 0xC2,
    "UnsubscribeFromStream".freeze => 0xC3,
    "SubscriptionDropped".freeze => 0xC4,
    "ConnectToPersistentSubscription".freeze => 0xC5,
    "PersistentSubscriptionConfirmation".freeze => 0xC6,
    "PersistentSubscriptionStreamEventAppeared".freeze => 0xC7,
    "CreatePersistentSubscription".freeze => 0xC8,
    "CreatePersistentSubscriptionCompleted".freeze => 0xC9,
    "DeletePersistentSubscription".freeze => 0xCA,
    "DeletePersistentSubscriptionCompleted".freeze => 0xCB,
    "PersistentSubscriptionAckEvents".freeze => 0xCC,
    "PersistentSubscriptionNakEvents".freeze => 0xCD,
    "UpdatePersistentSubscription".freeze => 0xCE,
    "UpdatePersistentSubscriptionCompleted".freeze => 0xCF,

    "ScavengeDatabase".freeze => 0xD0,
    "ScavengeDatabaseCompleted".freeze => 0xD1,

    "BadRequest".freeze => 0xF0,
    "NotHandled".freeze => 0xF1,
    "Authenticate".freeze => 0xF2,
    "Authenticated".freeze => 0xF3,
    "NotAuthenticated".freeze => 0xF4
  }

  def self.command_name(code)
    @names ||= reverse_lookup_table
    @names.fetch(code)
  end

  def self.reverse_lookup_table
    COMMANDS.inject(Hash.new) { |h, (k, v)| h.merge!({v => k }) }
  end
end
