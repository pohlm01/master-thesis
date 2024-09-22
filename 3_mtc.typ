#import "figures.typ": mtc_overview

= Merkle Tree Certificates for TLS

- Not a replacement, but an optimization
- Reduced Scope
  - Short-lived certificates
  - Relying Party needs recent transparency service
  - significant issuance delay

- *Roles*
  - Subscriber: Entity to be authenticated, e.g., web server
  - @ca
  - Relying party
  - Transparency service: Mirrors the @ca activity for a Relying Party
  - Monitors: Monitors transparency service for suspicious or unauthorized certificates

- *Terms*
  - Assertion: Protocol-specific statement that a @ca is certifying. E.g., DNS name or IP address.
  - Abridged assertion: Partially hashed Assertion to save space.
  - Certificate: Assertions with proof
  - Batch: Collection of assertions certified at the same time
  - Batch tree head: Merkle Tree head over all assertions of one batch
  - Inclusion proof: Proof that something is included in the head
  - validity window: A range of consecutive batch tree heads that a relying party accepts

#figure(
  mtc_overview,
  caption: [Overview of certificate issuance for Merkle Tree Certificates @benjamin_merkle_2024]
)

A @ca is defined by the following parameters that are publically known and cannot change:
- `hash`: The hash function used. Currently, only SHA-256
- `issuer_id`: A trust anchor identifier as defined in @id-tai. That is a relative @oid under the prefix 1.3.6.1.4.1. Organizations append their @pen registered at the @iana
- `public_key`: Used to sign validity window. Currently no key rotation supported. Might be in the future: #link("https://github.com/davidben/merkle-tree-certs/issues/36", "#36")
- `start_time`: issuance time of first batch in as POSIX timestamp @posix[pp.~113]
- `batch_duration`: number of seconds between two batches
- `lifetime`: number of seconds a batch is valid. Multiple of `batch_duration`
- `validity_window_size`: `lifetime`/`batch_duration`

Certificates are short-lived and therefore revocation mechanisms such as @ocsp and @crl are not necessary anymore.

- Recommended parameters are a batch duration of 1 hour, a validity window of 14 days.

A batch is in one of the following states:
- pending: Not yet due
- ready: Due but not yet issued
- issued