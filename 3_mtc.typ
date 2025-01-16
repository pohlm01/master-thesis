#import "figures.typ": *
#import "imports.typ": *
#import "tables.typ": *

= Merkle Tree Certificates for TLS <sec:mtc>
// - *Roles*
//   - @ap: Entity to be authenticated, e.g., web server
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

// This section summarizes the @ietf Internet-Draft that describes #glspl("mtc") for @tls~@rfc_mtc.
The motivation to create a new certificate architecture is mainly driven by the large size of @pq signatures.
Unfortunately, today's Web@pki relies on signatures in various places not just limited to the @ca signature in the certificate, but also for the embedded @sct for @ct and possibly @ocsp staples for certificate revocation.
Therefore, replacing all these signatures naively results in a significant increase in bytes transferred during a @tls handshake, as @sec:certificate_size will show in detail.
To prevent this, the Internet-Draft proposes an architecture that reduces the number of signatures where possible and instead greatly relies on hash functions.
Hash functions have the advantage of being computationally lightweight, small, and @pq secure.

On a high level, the idea is to certify a batch of assertions simultaneously by building a Merkle Tree.
Instead of signing each assertion individually, the @ca signs only the tree head.
These tree heads are distributed to Transparency Services, which serve a similar goal as the logs in @ct, but additionally provide a channel for @rp:pl to regularly update to the most recent batch tree heads.

Note that the @mtc proposal does not aim to replace the certificate infrastructure as we know it today; instead, it functions as an optional optimization.
Compared to today's Web@pki, it has a reduced scope and assumes more prerequisites for functioning properly.
@sec:mtc_pki_comparison elaborates on these differences; the following focuses more on the technical details of @mtc.

#figure(
  mtc_overview(),
  caption: [Overview of certificate issuance for Merkle Tree Certificates @rfc_mtc]
) <fig:mtc_overview>

@fig:mtc_overview provides an overview of the @mtc architecture. The following introduces the roles and terminology used in the figure and later sections:
- An #emph(gls("ap", long: true)) is an entity to be authenticated, such as a web server.
- A #emph(gls("rp", long: true)) authenticates an @ap by verifying the certificate. This could be a browser, for example.
- A #emph(gls("ca", long: true)) collects Assertions from @ap:pl, validates them, and issues certificates.
- A #emph([Transparency Service]) mirrors the @ca:pl, validates the batches, and forwards them to the @rp:pl.
- A #emph([Monitor]) monitors the transparency services for suspicious or unauthorized certificates.
- An #emph([Assertion]) is information that an @ap gets certified by a @ca, i.e., a public key and one or multiple domain name(s) or #gls("ip", long: false) address(es). An #emph([Abridged Assertion]) hashes the public key stored in an assertion to reduce the size, especially for potentially large @pq keys.
- A #emph([Batch]) is a collection of assertions that are certified simultaneously.
- The #emph([Batch Duration]) is the time the batch spans. The authors recommend a Batch Duration of one hour, meaning that all assertions collected within this hour are certified simultaneously in one Batch.
- A #emph([Batch Tree Head]) is the Merkle Tree root node over all assertions of one batch.
- An #emph([Inclusion Proof]) is a proof that a certain assertion is included in a batch. The proof consists of the hashes required to rebuild the path up to the Batch Tree Head.
- A #emph([Validity Window]) is the range of consecutive batch tree heads valid at a time.
- A #emph([Certificate]) combines an assertion with an inclusion proof.

#figure(
  mtc_terms(),
  caption: [This figure illustrates the terms Batch Duration, Batch Tree Head, Validity Window, and Assertion]
) <fig:mtc_terms_overview>


With this terminology, the following explains the certificate issuance flow depicted in @fig:mtc_overview
+ First, the @ap requests a certificate from the @ca.
  Due to its frequency, this operation should be automated using the @acme protocol, for example.
+ Every time a batch becomes ready, the @ca builds the Merkle Tree, signs the whole Validity Window, which includes the new Batch Tree Head, with a @pq algorithm, and publishes the tree to the Transparency Services.
+ The @ca also sends the inclusion proof back to the @ap, which can subsequently use it to authenticate against #glspl("rp") that trust this batch.
// + The Transparency Services recompute the Merkle Tree to validate the Merkle Tree Head contains exactly what is advertised and validate the signature of the Batch Tree Head.
+ Monitors mirror all Assertions published to the Transparency Services and check for fraudulent behavior.
  This can include, but is not limited to, notifying domain owners about certificates issued.
+ @rp:pl regularly update their trust anchors to the most recent Batch Tree Heads validated by their trusted Transparency Service(s).
+ When connecting to an @ap, the @rp signals which trust anchors it supports, i.e., which tree heads it trusts.
+ If the @ap has a valid @mtc certificate for one of the supported trust anchors, it will send this instead of a classical X.509 certificate.


The following sections elaborate on the responsibilities and objectives of the components involved. 

== Certification Authority <sec:mtc_ca>
A @ca is defined by the following publicly known parameters that cannot change.
In particular, the Transparency Service trusts certain @ca:pl and uses these parameters to validate the signed validity windows it receives from the @ca:pl.
- `hash`: The hash function used to build the Merkle Tree. Currently, only #gls("sha")#{"-256"} is supported.
- `issuer_id`: A @tai as defined in @rfc_tai. That is a relative @oid under the prefix `1.3.6.1.4.1`. Organizations append their @pen registered at the @iana.
- `public_key`: The Transparency Services use the public key to validate the signed validity window.
- `start_time`: Is the issuance time of the first batch as POSIX timestamp @posix[pp.~113].
- `batch_duration`: The time between two batches given in full seconds.
- `lifetime`: The number of seconds a batch is valid. It must be a multiple of `batch_duration`.
- The `validity_window_size` defines the number of tree heads that are valid simultaneously.
  It is calculated as the `lifetime` divided by the `batch_duration`.

The authors of the Internet-Draft suggest a `batch_duration` of one hour and a `lifetime` of 14 days.
This results in a `validity_window_size` of 336.

As with the current certificate infrastructure, the @ca is responsible for checking the assertions it certifies.
In particular, the @ca must verify that the @ap requesting the certificate effectively controls the domain names and @ip addresses to which the certificate is issued.
The exact mechanism is outside the scope of this work but usually involves completing a challenge by setting a DNS record or serving a file at a specific URL.

All assertions the @ca is willing to certify are accumulated in a batch.
A batch is always in one of three states: #emph([pending]), #emph([ready]), or #emph([issued]).
A pending batch is not yet due, i.e., the `start_time`~+~`batch_number`~$dot$~`batch_duration` is bigger than the current time.
A batch in the ready state is due at the current time but has not yet been issued.
This will typically be a small time frame in which the @ca builds the Merkle Tree and signs the validity window.
Subsequently, the batch transfers to the issued state, i.e., the @ca published the signed validity window and abridged assertions.
As an invariant, all batches before the latest issued one must be issued as well; no gaps are allowed.

Every time a batch becomes ready, the @ca converts all assertions it found to be valid into abridged assertions by hashing the -- possibly large -- signature key in that assertion.
Afterward, it builds a Merkle Tree as depicted in @fig:merkle_tree_abridged_assertion.
Lastly, the @ca signs a `LabeledValidityWindow` that contains the domain separator `Merkle Tree Crts ValidityWindow\0`, the `issuer_id`, the `batch_number`, and all Merkle Tree root hashes that are currently valid.
The domain separator allows the protocol to be extended in the future, if the @ca would need to sign different structs with the same key.
One example could be introducing a revocation mechanism that requires the @ca to sign some data with the same key.
Signing the entire validity window instead of each tree root individually has two advantages:
For one, if a client or Transparency Service is behind more than one Tree Head, only a single signature needs to be transferred instead of multiple, which saves bandwidth and computational effort for the signature verification.
The second benefit is that it complicates split-view attacks.
A @ca would have to keep the split view for an entire validity window instead of just a single tree head, which increases the chances of it being noticed.


// - As mentioned earlier: Merkle Trees
// - A batch is in one of the following states:
//   - pending: Not yet due
//   - ready: Due but not yet issued
//   - issued
// - CA builds a Merkle Tree
// - CA signs all tree heads that are currently valid

#figure(
  merkle_tree_abridged_assertion(),
caption: [Example Merkle Tree for three assertions]) <fig:merkle_tree_abridged_assertion>


== The Role of the Transparency Service <sec:mtc_ts>
While transparency was an afterthought in the current certificate infrastructure, it is an integral part of the @mtc architecture.
The main task of the Transparency Service is to validate and mirror the signed validity windows produced by @ca:pl and serve them to @rp:pl as well as monitors.
To check a signed validity window, the Transparency Service fetches the latest signed validity window and all abridged assertions from a @ca.
It then checks that the signature of the validity window matches the public key of that @ca.
By rebuilding the Merkle Tree from the abridged assertions, the Transparency Service ensures that @ca produced certificates for exactly what the @ca serves as abridged assertions.
Due to the collision resistance of the hash function, it is computationally infeasible for the @ca to secretly include another assertion, leave one out, or modify an assertion.

Conceptually, the Transparency Service is a single instance.
In practice, though, it should consist of multiple services hosted by independent organizations.
This reduces the chance that a @ca can collude with a single Transparency Service to provide a split view.
Also, the draft authors imagine that, in practice, browser vendors would run such a Transparency Service for their product and use their update mechanism to frequently provide the most recent tree heads~@rfc_mtc.


// == The Transparency Service -- Relying Party link
This link between the Transparency Service and @rp includes one significant design decision: Either the Transparency Service forwards only the tree heads to the @rp, or it includes the @ca signature as well.
@sec:update_size elaborates on how that influences how much data is distributed.
Omitting the @ca signature significantly reduces update bandwidth and eliminates the need for the client to perform @pq signature verification.
Consequently, the @rp must trust the Transparency Service to check the @ca signature adequately, and it requires the @rp to have a secure channel with the Transparency Service.
Depending on how this channel is designed, it may require interaction with @pq signatures on the client side nevertheless.
Additionally, a malicious Transparency Service could provide a split view to a client without the need to collude with a @ca.
At the same time, if the browser vendor runs the Transparency Service, it is anyway in a position to decide which connection to trust, even without potentially modifying the trusted roots.

// - Conceptually one instance, but actually distributed
// - Could be the browser vendor or independent
// - Retrieves the list of abridged assertions from the CA and rebuilds the tree
// - checks the signature
// - RP may check the signature themself, but don't have to if they have a trusted update channel
//   - What does this imply? Does the TS become a single point of failure, i.e., can it serve malicious root nodes to the RP? Probably yes...
//   - But they are a single point of failure anyways. Would probably some binary/update transparency here.

// == The Role of the Monitor
// The job of the monitors is watching the Transparency Services for any suspicious or malicious behavior.
// This can include, but is not limited to, notifying domain owners about certificates issued on their domain, and to detect split views provided by Transparency Services.

// We call something a split view if a Transparency Service provides different data to different users.
// One could imagine a targeted attack to a single user or @ip address, or tailored for a specific region, for example.
// This requires a Transparency Service to act maliciously, which could be the result of an attack.
// If a Transparency Service pulls a new batch from the @ca, it may decide to add or remove some assertions to the Merkle Tree and publish the modified batch tree head to some consumers.
// Note that the @ca signature of this batch tree head would not verify anymore, but some devices may decide to omit checking the @ca signature and instead rely on the Transparency Service.
// If an attacker wanted to convince a signature checking user, it must control the @ca and Transparency Service to forge the signature.
// Towards the monitors, the Transparency Service may continue to present the unmodified batch, while the @rp:pl receive a root that includes malicious assertions.
// Therefore, the monitors would not be able to notify the legitimate domain owners about a suspicious certificate.

// A monitor alone has a hard time detecting such a split view if the attacker manages to properly separate the requests it wants to serve a modified version from the monitors.

== Negotiation in TLS <sec:negotiation_tls>
To use the @mtc architecture, the @rp and @ap have to negotiate using it.
For that, the Internet-Draft refers to the `server_certificate_type` and `client_certificate_type` of RFC~7250~@rfc_raw_public_keys. 
On a high level, the @rp sends them as an extension of the `ClientHello` with all supported certificate types, and the @ap communicates the chosen certificate type to the @rp as an encrypted extension.

Additionally, the @rp has to communicate to the @ap which trust anchor it supports.
For that, the @mtc specification refers to an Internet-Draft called #emph[TLS Trust Anchor Identifiers]~@rfc_tai.
It allows the @rp to send the newest batch tree heads it supports to the @ap, such that the @ap can choose to send a certificate that the @rp trusts.
In particular, this allows the @ap to know which @mtc certificate to send during a certificate rotation.

In practice, it is not possible to send the whole list of known trust anchors to an @ap for two main reasons: size and privacy.
The list of all supported trust anchors is potentially large, considering that the trust anchor mechanism is not exclusively designed for @mtc but explicitly also for other mechanisms, such as X.509.
Assuming that just 50 @ca:pl would participate in this mechanism with an average identifier length of four bytes, each `ClientHello` would carry 250 additional bytes, 200 for the identifiers and 50 for the encoding with length prefixes.
The second concern is that a server can use the detailed information about the client for fingerprinting.
Especially with the quickly changing @mtc system, users might have recognizable trust stores, depending on when they pulled the latest tree heads from the Transparency Service.

To circumvent these downsides, the @rp has two options.
The @ap can create a @svcb @dns record listing all the trust anchors it supports, which is a short and not privacy-sensitive list.
Based on this information, the @rp can decide with trust anchor to offer to the @ap during the handshake.
Requiring information from the @dns complicates the deployment, but the #emph[Encrypted Client Hello] relies on a @svcb @dns record as well~@rfc_ech and is deployed in practice already~@firefox_ech@apple_ech@cloudflare_ech@chrome_ech.
The second option a @rp has is to guess trust anchors an @ap may support and do a retry if the guess was not correct.
The main downside is that a retry causes an additional round trip and, therefore, higher latency.