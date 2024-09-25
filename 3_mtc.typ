#import "figures.typ": mtc_overview
#import "imports.typ": *

= Merkle Tree Certificates for TLS
// - *Roles*
//   - Subscriber: Entity to be authenticated, e.g., web server
//   - @ca
//   - Relying party
//   - Transparency service: Mirrors the @ca activity for a Relying Party
//   - Monitors: Monitors transparency service for suspicious or unauthorized certificates

// - *Terms*
//   - Assertion: Protocol-specific statement that a @ca is certifying. E.g., DNS name or IP address.
//   - Abridged assertion: Partially hashed Assertion to save space.
//   - Certificate: Assertions with proof
//   - Batch: Collection of assertions certified at the same time
//   - Batch tree head: Merkle Tree head over all assertions of one batch
//   - Inclusion proof: Proof that something is included in the head
//   - validity window: A range of consecutive batch tree heads that a relying party accepts

This section summarizes the @ietf draft that describes #glspl("mtc") for @tls. @rfc_mtc

Note that @mtc does not aim to replace the certificate infrastructure as we know it today but instead functions as an optional optimization.
Compared to today's Web@pki it has a reduced scope and assumes more prerequisites to function properly.
@mtc_pki_comparison elaborates on these differences, the following focuses more on the technical details of @mtc.

First, we introduce some roles and terminology:
- A #emph([Subscriber]) is an entity to be authenticated, for example a web server.
- A #emph(gls("rp", long: true)) authenticates a subscriber by verifying the certificate. This could be a browser, for example.
- A #emph(gls("ca", long: true)) collects assertions from subscribers, validates them, and issues certificates.
- A #emph([Transparency Service]) mirrors the #glspl("ca"), validates the batches and forwards them to the #glspl("rp").
- A #emph([Monitor]) monitors the transparency services for suspicious or unauthorized certificates.
- An #emph([Assertion]) information that a subscriber gets certified by a @ca, i.e., a public key and one or multiple @dns name(s) and/or @ip address(es).
- An #emph([Abridged Assertion]) hashes the public key stored in an assertion to reduce the required size, especially for large @pq keys.
- A #emph([Batch]) is a collection of assertions certified at the same time. The recommended #emph([Batch Duration]) is one hour, meaning that all assertions collected within this hour are certified at the same time.
- A #emph([Batch Tree Head]) is the Merkle Tree root node over all assertions of one batch.
- A #emph([Inclusion Proof]) is a proof that a certain assertion is included in a batch.
- A #emph([Validity Window]) is the range of consecutive batch tree heads that are valid at a time.
- A #emph([Certificate]) combines an assertion with an inclusion proof.


#figure(
  mtc_overview,
  caption: [Overview of certificate issuance for Merkle Tree Certificates @rfc_mtc]
) <mtc_overview>

@mtc_overview depicts the issuance flow in a @mtc architecture.
+ First, the subscriber requests a certificate at the @ca.
  Due to the frequency of that operation, this is an automated process using the @acme protocol.
+ Every time a batch becomes ready, the @ca builds the Merkle Tree, signs the Batch Tree Head with a @pq algorithm and publishes the tree to the Transparency Services.
+ It also sends the inclusion proof back to the subscriber, which can subsequently use it to authenticate against #glspl("rp") that trust that batch.
// + The Transparency Services recompute the Merkle Tree to validate the the Merkle Tree Head contains exactly what is advertised and validate the signature of the Batch Tree Head.
+ Monitors mirror all Assertions published to the Transparency Services and check for fraudulent behavior. 
  This can include, but is not limited to, notifying domain owners about certificates issued.
+ #glspl("rp") regularly update their trust anchors to the most recent Batch Tree Heads that have been validated by their trusted Transparency Service(s).
+ When connecting to a Subscriber, the @rp signals which trust anchors it supports, i.e., which tree heads is trusts.
+ If the subscriber has a valid inclusion proof, i.e., certificate, for one of the supported trust anchors, it will send this instead of a classical X.509 certificate.

- Not a replacement, but an optimization
- Reduced Scope
  - Short-lived certificates
  - Relying Party needs recent transparency service
  - significant issuance delay




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

== Comparison of @mtc with the current Web@pki <mtc_pki_comparison>

