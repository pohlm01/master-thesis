#import "figures.typ": *
#import "imports.typ": *
#import "tables.typ": *

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

Note that @mtc does not aim to replace the certificate infrastructure as we know it today; instead, it functions as an optional optimization.
Compared to today's Web@pki it has a reduced scope and assumes more prerequisites to function properly.
@mtc_pki_comparison elaborates on these differences, the following focuses more on the technical details of @mtc.

First, we introduce some roles and terminology:
- An #emph(gls("ap", long: true)) is an entity to be authenticated, such as a web server.
- A #emph(gls("rp", long: true)) authenticates a subscriber by verifying the certificate. This could be a browser, for example.
- A #emph(gls("ca", long: true)) collects Assertions from subscribers, validates them, and issues certificates.
- A #emph([Transparency Service]) mirrors the @ca:pl, validates the batches, and forwards them to the @rp:pl.
- A #emph([Monitor]) monitors the transparency services for suspicious or unauthorized certificates.
- An #emph([Assertion]) is information that a subscriber gets certified by a @ca, i.e., a public key and one or multiple domain name(s) and/or #gls("ip", long: false) address(es).
- An #emph([Abridged Assertion]) hashes the public key stored in an assertion to reduce the size, especially for potentially large @pq keys.
- A #emph([Batch]) is a collection of assertions that are certified simultaneously. The recommended #emph([Batch Duration]) is one hour, meaning that all assertions collected within this hour are certified at the same time.
- A #emph([Batch Tree Head]) is the Merkle Tree root node over all assertions of one batch.
- An #emph([Inclusion Proof]) is a proof that a certain assertion is included in a batch. The proof consists of the hashes required to rebuild the path up to the Batch Tree Head.
- A #emph([Validity Window]) is the range of consecutive batch tree heads that are valid at a time.
- A #emph([Certificate]) combines an assertion with an inclusion proof.


A @ca is defined by the following parameters that are publically known and cannot change. In particular, the Transparency Service trusts certain @ca:pl and uses this information to validate the signed validity windows it receives from the @ca:pl.
- `hash`: The hash function used to build the Merkle Tree. Currently, only SHA-256 is supported.
- `issuer_id`: A @tai as defined in @id-tai. That is a relative @oid under the prefix 1.3.6.1.4.1. Organizations append their @pen registered at the @iana.
- `public_key`: The public key is used by the Transparency Services to validate the signed validity window.
- `start_time`: Is the issuance time of first batch as POSIX timestamp @posix[pp.~113]
- `batch_duration`: The time between two batches given in full seconds.
- `lifetime`: The number of seconds a batch is valid. It must be a multiple of `batch_duration`.
- The `validity_window_size` defines the number of tree heads that are valid at the same time. It is calculated as the `lifetime` divided by the `batch_duration`.

The authors of the Internet Draft suggest a `batch_duration` of one hour and a `lifetime` of 14 days. This results in a `validity_window_size` of 336.

#figure(
  mtc_overview,
  caption: [Overview of certificate issuance for Merkle Tree Certificates @rfc_mtc]
) <mtc_overview>

@mtc_overview depicts the issuance flow in a @mtc architecture.
+ First, the subscriber requests a certificate from the @ca.
  Due to the frequency of that operation, this should be an automated process using the @acme protocol, for example.
+ Every time a batch becomes ready, the @ca builds the Merkle Tree, signs the Batch Tree Head with a @pq algorithm, and publishes the tree to the Transparency Services.
+ It also sends the inclusion proof back to the subscriber, which can subsequently use it to authenticate against #glspl("rp") that trust this batch.
// + The Transparency Services recompute the Merkle Tree to validate the Merkle Tree Head contains exactly what is advertised and validate the signature of the Batch Tree Head.
+ Monitors mirror all Assertions published to the Transparency Services and check for fraudulent behavior. 
  This can include, but is not limited to, notifying domain owners about certificates issued.
+ #glspl("rp") regularly update their trust anchors to the most recent Batch Tree Heads that have been validated by their trusted Transparency Service(s).
+ When connecting to a @ap, the @rp signals which trust anchors it supports, i.e., which tree heads it trusts.
+ If the subscriber has a valid inclusion proof for the assertions, i.e., a certificate, for one of the supported trust anchors, it will send this instead of a classical X.509 certificate.

== Certificate Issuance

- As mentioned earlier: Merkle Trees
- A batch is in one of the following states:
  - pending: Not yet due
  - ready: Due but not yet issued
  - issued
- CA orders the Assertions and builds a Merkle Tree
- CA signs all tree heads that are currently valid

#figure(
  merkle_tree,
caption: [Merkle Tree]) <merkle_tree>


Describe how tree is built, what is signed, and ...

== The Role of the Transparency Service
- Conceptually one instance, but actually distributed
- Could be the browser vendor or independent
- Retrieves the list of abridged assertions from the CA and rebuilds the tree
- checks the signature
- RP may check the signature themself, but don't have to if they have a trusted update channel
  - What does this imply? Does the TS become a single point of failure, i.e., can it serve malicious root nodes to the RP? Probably yes...
  - But they are a single point of failure anyways. Would probably some binary/update transparency here.

= Comparison of MTC with the current WebPKI <mtc_pki_comparison>

- Not a replacement, but an optimization
- Reduced Scope
  - Short-lived certificates
  - Relying Party needs recent transparency service
  - significant issuance delay
  - Certificates are short-lived and therefore revocation mechanisms such as @ocsp and @crl are not necessary anymore.

== Size

- A standard certificate chain contains the following signatures
  - EE  
    - 2x SCT
    - 1x OCSP
    - 1x CA signature
  - Intermediate
    - 1x CA signature
  - CA
    - 1x self signature (check if root is actually sent)

That are 6 signatures in total and 3 public keys (+1 signature in the `CertificateVerify` if not KEMTLS)

Correction: Root certs are typically not sent. There may be multiple certificates with the same CN #emoji.face.explode.

Algorithms to compare:
  - RSA-2048 / RSA-4096?
  - Ed22519 (not used)
  - NIST P-256

  - ML-DSA
  - SLH-DSA

  - ML-KEM?

#figure(
  certificate_sizes,
  caption: [Comparing the size of cryptographic material in certificate chains for various algorithms]
)

== Update mechanism considerations
- Size
  - Should not send whole signed validity window every day
  - Maybe just delta
  - Probably do not include the CA signature
  - Where to store and in which format, which data to include
  