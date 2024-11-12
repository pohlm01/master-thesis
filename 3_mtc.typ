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
) <mtc_overview>

@mtc_overview depicts the issuance flow in a @mtc architecture.
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


= Comparison of MTC with the Current WebPKI <sec:mtc_pki_comparison>

From the introduction to @pki in @sec:pki and the explanation of @mtc in @sec:mtc, it might already be become obvious that there are big differences between these architectures.
This chapter presents the results of the analysis we conducted about the differences and the advantages and disadvantages the architectures result in.

The most obvious change is the significant reduction of the certificate lifetime.
The authors of @mtc propose a lifetime of 14 days.
As of October 2024, @tls certificates may be issued for at most 13 months, i.e., 398 days @chrome_cert_lifetime @apple_cert_lifetime and are often issued for 90 days, which is still more than 6 times as long as the lifetime of @mtc.
At the same time, it is likely that the validity periods of classical certificates will decrease further.
In October 2024, Apple published a proposal to the CA/Browser Forum suggesting a gradual reduction of the maximum certificate lifetime to 45 days by September 2027. @apple_45_days_cert
It is unclear if this proposal will get accepted, but it is clear that the maximum certificate lifetime will only decrease in the future, reducing the gap to @mtc.

Another notable difference is that the @mtc draft explicitly ignores certificate revocation.
This is a direct result of the short certificate lifetimes; if certificates live as long as it takes for a revocation to effectively propagate, certificate revocation is not necessary anymore.
This is a clear improvement over the current Web@pki, as it continuously suffers from ineffective revocation mechanisms @lets_encrypt_new_crl @crl_sets_effectiveness @reddit_ocsp_firefox.
Chrome does not check @ocsp or @crl:pl, but instead relies on a custom summary called #emph("CRLSets") containing a (small) subset of all revoked certificates curated by Google @chrome_crlsets.
Firefox does still check OCSP responses, but the CA/Browser forum changed its recommendation to support @ocsp in their @ca baseline requirements to an optional @ocsp support in version 2.0.1, effective as of March 2024 @cab_ocsp_optional_crl_mandatory.
As @ocsp entails high operational costs for @ca:pl, it is likely that @ocsp will further lose relevance.
Let's encrypt already announced to end their @ocsp support "as soon as possible" @lets_encrypt_end_ocsp.
Instead, the CA/Browser forum tightens the requirements for @crl:pl and Mozilla is working on accumulating all revoked certificates into a small list called #emph("CRLite") since 2017, but did not enable this mechanism by default in Firefox as of version 132 from October 2024 @crlite_paper @mozilla_crlite.

Furthermore, certificate transparency is built into @mtc, as opposed to the X.509 certificate infrastructure, where it was added later on.

A significant downside of @mtc compared to the classical certificate infrastructure are the longer issuance times.
There are two aspects to this: First, the issuance of the certificate itself takes up to `batch_duration` seconds, i.e., one hour assuming the default values, and second, the time the new tree heads propagated to a relevant number of @rp:pl.
The first one will not make up for the major part of the difference in practice.
For either certificate type -- X509 or @mtc -- the effective control over the domain needs to be validated upfront, which, depending on the challenge type, requires @dns entries to propagate or @http pages to propagate across multiple servers and data centers for big deployments @lets_encrypt_challange_types @tls_issuance_delay.
The second part, the propagation delay of new tree heads to the @rp:pl, will be more relevant.
X.509 certificates are trusted by @rp:pl immediately after they are issued.
In contrast to that, to verify @mtc:pl, the @rp must be up-to-date with the batch tree head for successful verification.
In practice, we do not expect updates from the trust services to the @rp happening substantially more frequently than every six hours.
Therefore, the delay until a new @mtc is broadly usable may be up to a few days in the worst case.

To determine how big the impact of the long issuance delay is, it is helpful to understand under which circumstances it requires a fast issuance fallback.
This could be an X.509 certificate or another, future mechanism that allows for fast issuance.
The size, and therefore performance, downside of large certificate chains only last for a limited time, until @rp:pl updated their trust stores to include the new tree heads and can again use the size efficient @mtc mechanism.
There are two main reasons why a fast issuance is required; for a new domain and for an unplanned move of the domain.
A scenario in which an expired certificate must be renewed quickly because of a forgotten, manual renewal is very unlikely, as @mtc require a high level of automation anyway.

In @mtc_fallback_estimate, Lena Heimberger estimates the likelihood of those fallbacks.
For that, she uses the fact that all certificates must be logged to a transparency log to be accepted by the major browser, which makes the analysis of all current and expired certificates possible.
Heimberger divided domains into two categories: Top domains and random domains.
This is interesting, because the most visited websites are more likely to be well maintained than websites that are visited less often.
The analysis she performed potentially has a high rate of large positives, but it is interesting to have an idea of the order of magnitude anyway.
Assuming a propagation delay of three days, the top domains have a chance of 0.0004~% of hitting a fallback, while the random domains have a chance of 0.009~%.
This shows that the chance of hitting a fallback is very unlikely, and thus the longer issuance delays will barely affect the daily operations.

// - Not a replacement, but an optimization
// - Reduced Scope
//   - Short-lived certificates
//   - Relying Party needs recent transparency service
//   - significant issuance delay
//   - Certificates are short-lived and therefore revocation mechanisms such as @ocsp and @crl are not necessary anymore.

== Size <sec:update_size>
The main improvement of @mtc over classical X.509 certificates is the size transmitted between the @ap and @rp during a @tls handshake.
This section investigates this difference in more detail and analysis the newly required transmissions from the Transparency Service to the @rp.
On a large scale, every byte saved during a @tls handshake equates in a relevant reduction as the handshakes take place before almost every connection.
For this analysis, we compare the sizes of pre- and post-quantum ready @tls handshakes using the current Web@pki infrastructure (@tab:x509_size) with the size estimated for @mtc.


// - A standard certificate chain contains the following signatures
//   - EE  
//     - 2x SCT
//     - 1x OCSP
//     - 1x CA signature
//   - Intermediate
//     - 1x CA signature
//   - CA
//     - 1x self signature (check if root is actually sent)

// That are 6 signatures in total and 3 public keys (+1 signature in the `CertificateVerify` if not KEMTLS)

// Correction: Root certs are typically not sent. There may be multiple certificates with the same CN #emoji.face.explode.

The analysis focuses on the authentication related cryptographic material exchanged during the handshake.
This means, we do not include the bytes that encode the domain name, key usage constraints, `not_before` or `not_after` timestamps, and similar.
We do also ignore the bytes required to establish a shared key used for the record layer, which is used for the encryption and authentication of the payload messages.
Therefore, an X.509 handshake contains the following components.
One signature for active authentication of the handshake, two signatures for @sct:pl, one signature for an @ocsp staple, one signature of the intermediate @ca on the End-Entity (EE) certificate, and one signature of the root @ca on the intermediate @ca.
In addition, the EE and intermediate certificate contain one public key each.
Summing this up, we count six signatures and two public keys.
The last case in @tab:x509_size marked in yellow is a bit of a special case.
It uses @kemtls and therefore sends a key encapsulation instead of a signature.
For our analysis, we ignore this fact, as it serves the same objective, namely actively authenticating the handshake.

@tab:x509_size contains one optimistic and one conservative but realistic estimate for each, a @pq and non @pq secure setup.
Additionally, it contains one setup for @kemtls.
The optimistic estimate assumes the usage of 256-bit @ecdsa signatures and keys across the whole chain.
About 24~% of all currently active certificates are issued for an @ecdsa key, with about 53~% using a 384-bit and 47~% using a 256-bit key length.
The remaining 76~% of all current EE certificates use an RSA algorithm. @merkle_town
For the root @ca:pl stored in the Firefox root program, the numbers are a bit different.
44~% (78) use a 4096-bit RSA key, 26~% (46) use a 2048-bit RSA key, 27~% use a 384-bit @ecdsa key and only 2~% (4) use a 256-bit @ecdsa key @firefox_root_store.
Without telemetry data from browsers, it is unfortunately very hard to judge which are the most common combinations just from the percentage of certificates issued and the configuration of root @ca:pl, as there is a big imbalance on which @ca:pl and certificates are heavily used and which are not.
We tried to get an impression by manually checking the certificate chains for the top 10 domains according to Cloudflare Radar @cloudflare_radar_domains.
The results in @tab:top_10_signatures show that the landscape of used signatures is diverse.
The significance is very limited, though, as five of the ten top domains do not serve a website and are purely used for @api calls (root-servers.net, googleapis.com, gstatic.com, tiktokcdn.com, amazonaws.com).
The remaining five domains serve a website, but it seems likely that the majority of calls still originates from @api calls.
Moreover, the server may adopt the presented certificate based on a specific subdomain and the user agent, which further complicates a holistic view.
Nevertheless, we are convinced that the chosen combinations represent adequate examples.

@tab:bikeshed_size shows example sizes for various parameters used for a @mtc setup.
From the number of columns, it gets obvious that a @mtc contains way less asymmetric cryptography.
The certificate contains a single key used to protect the integrity of the handshake.
Together with the length of the inclusion proof, they determine the size of the authentication related cryptography.
The size of the inclusion proof logarithmically depends on the number of certificates in a batch.
To estimate the size for the inclusion proof, we checked the number of active certificates for the biggest @ca, Let's Encrypt.
According to their own statistics, there exists about 420 million active certificates in October 2024, which matches with observations based on certificate transparency logs @merkle_town @lets_encrypt_stats.
The logs further show that there are around one billion active certificates in total.
For the first estimate on proof length, we take Let's Encrypt's recommendation to renew certificates every 60 days.
Knowing that certificates issued by Let's Encrypt are always valid for 90 days, we can deduce that there exist around $420 dot 10^9 dot 60/90 = 280 dot 10^9$ authenticating parties using the services of Let's Encrypt.
In a @mtc setup, @ap:pl are recommended to renew their certificates every ten days.
Assuming that a batch lasts for one hour, each batch contains $(280 dot 10^9)/(10 dot 24) = 1.16 dot 10^9$ certificates.
To accommodate this number of assertions, the Merkle Tree requires $ceil(log_2 1.16 dot 10^9)  = 21$ level, resulting in a proof length of 21 hashes.
The current draft only allows #gls("sha")-256 as hashing algorithm and also future iterations are unlikely to extend the length of the digest, even if changing the algorithm.
Therefore, the proof length for this scenario is $21 dot 32 "bytes" = 672 "bytes"$.

The second scenario indicates a worst case scenario, assuming a big increase in @ap:pl or centralization to few certificate authorities.
We map the one billion currently active certificates to one billion @ap:pl, which is very conservative as it ignores the transition periods, which we considered in the first scenario.
Assuming again that each @ap renews their certificate every ten days and a batch size of one hour, the above calculation results in a proof length of $832 "bytes"$.
It is interesting to realize that for every doubling of @ap:pl, the proof size grows by 32 bytes, as the tree depth grows logarithmically.

// - 78 RSA 4096 bits
// - 46 RSA 2048 bits
// - 4  EC secp256r1
// - 48 EC secp384r1

\

// - There exist ~420M active certificates issued by Let's Encrypt, the biggest of all CAs (Merkle Town 17.10.2024)
// - Let's Encrypt reports ~420M active certificates (https://letsencrypt.org/stats/ 14.10.2024)
// - Merkle Town reports \~1B active certificates in total (17.10.2024)
// - It is recommended to renew the cert every 60 days
//   - this would result in $420M dot 60/90 = 280M$ active subscribers.
//   - In @mtc authenticating parties should reissue their certificate every 10 days. This results in $frac(280M, 10 dot 24) = 1.16M$ certificates in every batch.
//   - This results in a path length of $log_2(1.16M) = 20.14 => 21$
//   - Proof length $21 dot 32 "byte" = 672 "byte"$
//   - For all active certificates: Conservatively assuming that there are 1B authenticating parties. $frac(1B, 10 dot 24) = 41.6M => log_2(41.6M) => 25.3 => 26 dot 32 = 832 "byte"$
//   - logarithmic, thus each doubling in subscribers results in 32 bytes more

#figure(
  x509_certificate_sizes,
  caption: [Bytes of authentication-related cryptographic material exchanged during the @tls handshake for various algorithms in the X.509 infrastructure.]
) <tab:x509_size>

#figure(
  bikeshed_certificate_sizes,
  caption: [Bytes of authentication-related cryptographic material exchanged during the @tls handshake using @mtc.]
) <tab:bikeshed_size>

Comparing @tab:x509_size and @tab:bikeshed_size shows that @mtc has big size advantages, especially when using @pq algorithms.
Focusing at the classical case first:
In the best X.509 case, when using only 256-bit @ecdsa for all signatures, @mtc performs slightly worse in terms of the number of authentication bytes.
While the X.509 case requires 448 authentication-related bytes, @mtc requires 768 bytes, which is a absolute difference of 320 bytes corresponding to 41.67~%.
Comparing @mtc to a mostly #gls("rsa", long: false)-based certificate, @mtc shows it advantages, as the X.509 certificate grows to 1,728~bytes.
Therefore, the @mtc is 960 or 800 bytes smaller, depending on the number of active @ap:pl in the @mtc system.
This corresponds to a reduction of 55.56~% or 46.30~%, respectively.
Moving on to the @pq algorithms, the drastic improvement of @mtc shows up.
Compared to the best X.509 case using only @mldsa signatures, @mtc saves 12,740 or 12,580 bytes, resulting in 74.31~% or 73.38~% depending on the number of active @ap:pl.
Moreover, it seems realistic that a @ca would use @slhdsa instead of @mldsa due to its higher security guarantees.
This further increases the advantage of @mtc to 80.05~% or 79.79~%, saving 18,176 or 18,016 byte, respectively.
When replacing the @mldsa key and signature with @mlkem, the handshake is 1,460 bytes smaller, independent of @mtc or X.509.
Nevertheless, the relative gain of @kemtls is bigger for @mtc as it exchanges less bytes in the baseline scenario.

// - In the best classical case, X.509 contains less authentication bytes
// - Compared to a realistic setup, @mtc with classical crypto already saves about 1000 bytes.
// - The best (non-KEMTLS) case saves $17,144-4,404=12,740$, i.e., 74.31~%
// - It seems realistic the the @ca will use SLH-DSA (in the beginning), which will increase the difference to $22,580-4,404=18,176$, i.e., 80.05~%
// - A big increase in @ap does not change a lot: $17,144-4,564=12,580$, i.e., 73.38~% / $22,580-4,564=18,016$, i.e., 79.79~%
// - @kemtls makes the savings slightly more impressive: $15,684 - 2,944 = 12740$, i.e., 81.23~% or $15,684 - 2,944 = 12580$, i.e., 80.21~%

// TODO Mention that there are also other size improvements due to the Bikeshed certificate format
In addition size improvements related to authentication cryptography, @mtc brings additional size improvements by using a new certificate format.
X.509 is based on @asn1 and certificates are transferred in @der encoding.
The @mtc Internet-Draft defines a new certificate format called Bikeshed certificate.
The name is meant as a placeholder, and the authors aim to replace it before it potentially becomes a standard.
@der uses a  type-length-value encoding, meaning that each value in the certificate explicitly has a type and length encoded.
The encoding of @mtc on the contrary is more efficient because types and lengths of fields are implicit, i.e., fixed, where possible.
Besides the encoding, the Bikeshed certificate type saves bytes by leaving out information that is superfluous in the new setting.
The following fields are not stored in a Bikeshed certificate, that are not already covered by the size considerations above:
- Not before timestamp
- Not after timestamp
- @crl endpoint
- @ocsp endpoint
- @sct timestamps and log IDs
- key usage restrictions
- subject and authority key identifier

To give an example:
The certificate chain for `www.google.com`#footnote([SHA-265 fingerprint \ `37:9A:80:C9:25:2C:66:A1:BB:89:D6:C0:C8:83:33:39:55:1D:E6:0F:D3:75:58:5C:F9:A3:18:37:03:57:A0:D6`]) has 2,486 bytes in @der format.
The chain contains 256-bit ECDSA, RSA-2048, and RSA-4096 bit keys and signatures.
Summing them up, the authentication related bytes transmitted in the certificate chain result in 1,248 bytes.
Note that this does not contain the @ocsp staple or handshake signature included in @tab:x509_size as they are not included in the certificate chain itself.
In comparison, a comparable Bikeshed certificate with a 256-bit ECDSA key would contain 704 authentication related bytes, assuming $280 dot 10^9$ active @ap:pl.
The full certificate would be 785 bytes in size.
Thus, the X.509 certificate chain has an overhead of 1,238 bytes or 99~% while the Bikeshed certificate has an overhead of 81 bytes or 12~%.
Even though this is only a single example, this shows that the X.509/@asn1 format produces a significant overhead, that can be reduced by introducing a new certificate format.

== Update mechanism considerations
- Size
  - Should not send whole signed validity window every day
    - There are currently ~150 trusted root CAs
    - If TS->RP updates delta + signature once a day 
      - If each of the CAs produces a new tree head every hour, this would be $24 dot 150 dot 32 "bytes" = 67,200 "bytes"$ of tree heads per day
      - Only the last valid signature needs to be distributed: Assuming SLH-DSA-128s $150 dot 7,856 = 1,178,400 "bytes"$
      - In sum, that are: 1,245,600B = 1.3MB per day
      - Compression should likely not work
    - If TS->RP pushes the whole validity window
      - Each signed validity window is about $7,856 "bytes" + 336 dot 32 "bytes" = 18,608 "bytes"$
      - Times the number of CAs: $150 dot 18,608 = 2,791,200 => 2.7 "MB"$
    - Daily update without the signatures: 
  - Proposed location: `/etc/ssl/mtc/{tai}/heads`, `/etc/ssl/mtc/{tai}/metadata`, and `/etc/ssl/mtc/{tai}/signature`
  - Maybe just delta
  - Probably do not include the CA signature $24 dot 150 dot 32 "bytes" = 67,200 "bytes" => 70 "KB"$
  - Where to store and in which format, which data to include

#figure(
  box(mtc_client_file_tree),
  caption: [Proposed file structure on a @rp. The signature only exists on @rp that are willing to perform the @pq signature check themself. The public key is part of the @ca parameters]
)

#figure(
  box(mtc_server_file_tree),
  caption: [Proposed file structure on an @ap.]
)

- Server memory efficiency can be improved by only storing the different proofs, but not the full certificate. Instead, the public key is stored only once and the cert is dynamically built.

- The signature over the validity window has the advantage that a CA would need to keep a split view over the whole window instead of for a single batch. See https://github.com/davidben/merkle-tree-certs/issues/84