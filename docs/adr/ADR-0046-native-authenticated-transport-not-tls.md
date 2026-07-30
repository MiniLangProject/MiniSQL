# ADR-0046: native authenticated transport, not TLS

Decision: M29 implements directional AES-256-GCM protection with replay-safe
sequence numbers after password authentication. This permits a fail-closed
remote mode using facilities available through Windows CNG. It is explicitly
not named or represented as TLS because no certificate or TLS state machine is
implemented.
