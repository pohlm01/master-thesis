#import "figures.typ": *
#import "imports.typ": *
#import "tables.typ": *

= Merkle Tree Certificates for TLS <sec:mtc>
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

Note that the @mtc proposal does not aim to replace the certificate infrastructure as we know it today; instead, it functions as an optional optimization.
Compared to today's Web@pki it has a reduced scope and assumes more prerequisites to function properly.
@sec:mtc_pki_comparison elaborates on these differences, the following focuses more on the technical details of @mtc.

First, we introduce some roles and terminology:
- An #emph(gls("ap", long: true)) is an entity to be authenticated, such as a web server.
- A #emph(gls("rp", long: true)) authenticates an @ap by verifying the certificate. This could be a browser, for example.
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


A @ca is defined by the following parameters that are publically known and cannot change. In particular, the Transparency Service trusts certain @ca:pl and uses these parameters to validate the signed validity windows it receives from the @ca:pl.
- `hash`: The hash function used to build the Merkle Tree. Currently, only SHA-256 is supported.
- `issuer_id`: A @tai as defined in @id-tai. That is a relative @oid under the prefix `1.3.6.1.4.1`. Organizations append their @pen registered at the @iana.
- `public_key`: The public key is used by the Transparency Services to validate the signed validity window.
- `start_time`: Is the issuance time of first batch as POSIX timestamp @posix[pp.~113].
- `batch_duration`: The time between two batches given in full seconds.
- `lifetime`: The number of seconds a batch is valid. It must be a multiple of `batch_duration`.
- The `validity_window_size` defines the number of tree heads that are valid at the same time. It is calculated as the `lifetime` divided by the `batch_duration`.

The authors of the Internet-Draft suggest a `batch_duration` of one hour and a `lifetime` of 14 days. This results in a `validity_window_size` of 336.

#figure(
  mtc_overview,
  caption: [Overview of certificate issuance for Merkle Tree Certificates @rfc_mtc]
) <fig:mtc_overview>

@fig:mtc_overview depicts the issuance flow in a @mtc architecture.
+ First, the subscriber requests a certificate from the @ca.
  Due to the frequency of that operation, this should be an automated process using the @acme protocol, for example.
+ Every time a batch becomes ready, the @ca builds the Merkle Tree, signs the Batch Tree Head with a @pq algorithm, and publishes the tree to the Transparency Services.
+ It also sends the inclusion proof back to the @ap, which can subsequently use it to authenticate against #glspl("rp") that trust this batch.
// + The Transparency Services recompute the Merkle Tree to validate the Merkle Tree Head contains exactly what is advertised and validate the signature of the Batch Tree Head.
+ Monitors mirror all Assertions published to the Transparency Services and check for fraudulent behavior. 
  This can include, but is not limited to, notifying domain owners about certificates issued.
+ #glspl("rp") regularly update their trust anchors to the most recent Batch Tree Heads that have been validated by their trusted Transparency Service(s).
+ When connecting to an @ap, the @rp signals which trust anchors it supports, i.e., which tree heads it trusts.
+ If the subscriber has a valid inclusion proof for the assertions, i.e., a certificate, for one of the supported trust anchors, it will send this instead of a classical X.509 certificate.

The following sections elaborate on the responsibilities and objectives of the components involved. 

== Certificate Authority
As with the current certificate infrastructure, the @ca is responsible for checking the assertions it certifies.
In particular, the @ca must verify that the @ap requesting the certificate is in effective control over the domain names and @ip addresses the certificate is issued to.
The exact mechanism is outside the scope of this work, but usually involves completing a challenge by setting a DNS record or serving a file at a specific URL.

All assertions the @ca is willing to certify are accumulated in a batch.
A batch is always in one of three states: #emph([pending]), #emph([ready]), or #emph([issued]).
A pending batch is not yet due, i.e., the `start_time`~+~`batch_number`~$dot$~`batch_duration` is bigger than the current time.
A batch in the ready state is due according to the current time, but has not yet been issued.
This will typically be a small time frame in which the @ca builds the Merkle Tree and signs the validity window.
Subsequently, the batch transfers to the issued state, i.e., the @ca published the signed validity window and abridged assertions.
As an invariant, all batches before the latest issued one must be issued as well, i.e., no gaps are allowed.

Every time a batch becomes ready, the @ca converts all assertions it found to be valid into abridged assertions by hashing the (possibly large) signature key in that assertion to transform them into abridged assertions and afterward builds a Merkle Tree as depicted in @merkle_tree.
Next, the @ca signs a `LabeledValidityWindow` that contains the domain separator `Merkle Tree Crts ValidityWindow\0` to prevent cross protocol attacks, the `issuer_id`, the `batch_number`, and all Merkle Tree root hashes that are currently valid.


// - As mentioned earlier: Merkle Trees
// - A batch is in one of the following states:
//   - pending: Not yet due
//   - ready: Due but not yet issued
//   - issued
// - CA builds a Merkle Tree
// - CA signs all tree heads that are currently valid

#figure(
  merkle_tree,
caption: [Example Merkle Tree for three abridged assertions ($"aa"_0", aa"_1", aa"_2$)]) <merkle_tree>


== The Role of the Transparency Service
While transparency was an afterthought in the current certificate infrastructure, it is an integral part of the @mtc architecture.
The main task of the Transparency Service is to validate and mirror the signed validity windows produced by @ca:pl and serve them to @rp:pl as well as monitors.
To check a signed validity window, the Transparency Service fetches the latest signed validity window as well as all abridged assertions from a @ca.
It then checks that the signature of the validity window matches the public key of that @ca.
By rebuilding the Merkle Tree from the abridged assertions, the Transparency Service ensures that @ca produced certificates for exactly what the @ca serves as abridged assertions.
Due to the collision resistance of the hash function, it is computationally infeasible for the @ca to secretly include another assertion, leave one out, or modify an assertion.

Conceptually, the Transparency Service is a single instance.
In practice, though, it should consist of multiple services hosted by independent organizations.
This reduces the chance that a @ca can collude with a single Transparency Service to provide a split view.
Also, the authors of the draft imagine that in practice, the browser vendors would run such a Transparency Service for their product and use their update mechanism to frequently provide the most recent tree heads.


// == The Transparency Service -- Relying Party link
This link between the Transparency Service and @rp includes one significant design decision: Either, the Transparency Service forwards only the tree heads to the @rp, or it includes the @ca signature as well.
@sec:update_size elaborates on how that influences the amount of data to be distributed.
Omitting the @ca signature does not only significantly reduce update bandwidth but also means that the client does not need to perform @pq signature verification.
Consequently, the @rp must trust the Transparency Service to properly check the @ca signature, and it requires the @rp to have a secure channel with the Transparency Service.
Depending on how this channel is designed, it may require interaction with @pq signatures on the client side nevertheless.
Additionally, a malicious Transparency Service could provide a split view to a client without the need to collude with a @ca.
At the same time, if the Transparency Service is run by the browser vendor, it is anyway in the position to decide about with connection to trust.

// - Conceptually one instance, but actually distributed
// - Could be the browser vendor or independent
// - Retrieves the list of abridged assertions from the CA and rebuilds the tree
// - checks the signature
// - RP may check the signature themself, but don't have to if they have a trusted update channel
//   - What does this imply? Does the TS become a single point of failure, i.e., can it serve malicious root nodes to the RP? Probably yes...
//   - But they are a single point of failure anyways. Would probably some binary/update transparency here.

== The Role of the Monitor
The job of the monitors is watching the Transparency Services for any suspicious or malicious behavior.
This can include, but is not limited to, notifying domain owners about certificates issued on their domain, and to detect split views provided by Transparency Services.

