#import "figures.typ": *
#import "imports.typ": *
#import "tables.typ": *

= Comparison of MTC with the Current WebPKI <sec:mtc_pki_comparison>

Based on the introduction to @pki in @sec:pki and the explanation of @mtc in @sec:mtc, it becomes obvious that there are significant differences between these architectures.
This chapter presents the results of the analysis we conducted about the differences and the advantages and disadvantages the architectures result in.

The most obvious change is the significant reduction of the certificate lifetime.
The authors of @mtc propose a lifetime of 14 days.
In contrast, as of October 2024, @tls leaf certificates for the Web@pki may be issued for at most 13 months, i.e., 398 days~@chrome_cert_lifetime @apple_cert_lifetime.
Often they are issued only for 90 days, which is still more than six times as long as the proposed lifetime of @mtc.
At the same time, it is likely that the validity periods of classical certificates will decrease further.
In October 2024, Apple published a proposal to the CA/Browser Forum suggesting a gradual reduction of the maximum certificate lifetime to 45 days by September 2027~@apple_45_days_cert.
It is unclear if this proposal will be accepted, but it is clear that the maximum certificate lifetime will only decrease in the future, possibly approaching the certificate lifetime of @mtc.

Another notable difference is that the @mtc draft explicitly ignores certificate revocation.
This is a direct result of the short certificate lifetimes; if certificates live as long as it takes for a revocation to effectively propagate, certificate revocation is not necessary anymore.
Eliminating the need for a revocation mechanism is a clear improvement over the current Web@pki, as it continuously suffers from ineffective revocation mechanisms~@lets_encrypt_new_crl @crl_sets_effectiveness @reddit_ocsp_firefox.
Chrome does not check @ocsp or @crl:pl, but relies on a custom summary called #emph("CRLSets") containing a (small) subset of all revoked certificates curated by Google @chrome_crlsets.
In contrast to that, Firefox does still check @ocsp responses, but the CA/Browser forum changed its recommendation to support @ocsp in their @ca baseline requirements to an optional @ocsp support in version 2.0.1, effective as of March 2024~@cab_ocsp_optional_crl_mandatory.
As @ocsp entails high operational costs for @ca:pl, it is likely that @ocsp will further lose relevance.
Let's Encrypt already announced to end their @ocsp support "as soon as possible"~@lets_encrypt_end_ocsp.
Instead, the CA/Browser forum tightens the requirements for @crl:pl and Mozilla is working on accumulating all revoked certificates into a small list called #emph("CRLite") since 2017, but did not enable this mechanism by default in Firefox as of version 132 from October 2024~@crlite_paper @mozilla_crlite.

Furthermore, certificate transparency is built into @mtc, as opposed to the X.509 certificate infrastructure, where it was added later on.

A significant downside of @mtc compared to the classical certificate infrastructure is the longer issuance times.
There are two aspects to this: First, the issuance of the certificate itself takes up to `batch_duration` seconds, i.e., one hour assuming the default values, and second, the time the new tree heads propagate to a relevant number of @rp:pl.
The first one will not make up for the major part of the difference in practice.
For both X509 and @mtc certificates, the @ca must validate the @ap has effective control over the domain beforehand.
This validation process often involves @dns record propagation or @http page propagation across multiple servers and data centers, especially for large-scale deployments~@lets_encrypt_challange_types @tls_issuance_delay.
Therefore, classical certificate issuance can take up to an hour as well, though in optimized configurations it can work a lot faster.
The second part, the propagation delay of new tree heads to the @rp:pl, is more relevant.
X.509 certificates are trusted by @rp:pl immediately after they are issued.
In contrast to that, to verify @mtc:pl, the @rp must be up-to-date with the batch tree head for successful verification.
In practice, we do not expect updates from the Transparency Service to the @rp to happen substantially more frequently than every six hours.
Therefore, the delay until a new @mtc is broadly usable may be up to a few days in the worst case.

To determine how big the impact of the long issuance delay is, it is helpful to understand which circumstances require fast certificate issuance.
In such a situation, the Internet-Draft assumes the existence of a fallback mechanism for fast issuance.
This could be an X.509 certificate or another, future mechanism that allows for fast issuance.
The drawback of large certificate chains is only temporary, until @rp:pl updated their trust stores to incorporate the new tree heads, enabling them to utilize the size-efficient @mtc mechanism again.
There are two main reasons why a fast issuance is required; for a new domain and for an unplanned move of the domain.
A scenario in which an expired certificate must be renewed quickly because of a forgotten, manual renewal is very unlikely, as @mtc requires a high level of automation anyway.

In @mtc_fallback_estimate, Heimberger estimates the likelihood of those fallbacks.
For that, she uses the fact that all certificates must be logged to a transparency log to be accepted by the major browser, which makes the analysis of all current and expired certificates possible.
Heimberger divided domains into two categories: Top domains and random domains.
This is interesting because the most visited websites are more likely to be well maintained than websites that are visited less often.
The analysis she performed potentially has a high rate of large positives, but it is useful to have an idea of the order of magnitude anyway.
Assuming a propagation delay of three days, the top domains have a chance of 0.0004~% of hitting a fallback, while the random domains have a chance of 0.009~%.
This shows that the chance of hitting a fallback is very unlikely, and thus the longer issuance delays will barely affect the daily operations.

// - Not a replacement, but an optimization
// - Reduced Scope
//   - Short-lived certificates
//   - Relying Party needs recent transparency service
//   - significant issuance delay
//   - Certificates are short-lived and therefore revocation mechanisms such as @ocsp and @crl are not necessary anymore.

== Certificate Size <sec:certificate_size>
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
On a large scale, every byte saved during a @tls handshake is a relevant reduction, as the handshakes take place before almost every connection.
Cloudflare published some notable statistics regarding the number of bytes transferred from server to client.
Their statistic only considers QUIC connections, as they likely originate from browsers.
This fits nicely, as the @mtc architecture is mainly designed for browser-like applications as well.
For non-resumed QUIC connections, the median number of transferred bytes is 7.8~kB and the average is 395~kB.
The big difference between the median and average indicates that a few data-heavy connections heavily influence the average, while there is a high volume of small connections.
This allows the rough estimate that about 40~% of the bytes transferred from the server to the client are for the certificate chain in at least half of the non-resumed QUIC connections.

Therefore, we investigate the main improvement of @mtc over classical X.509 certificates in this section, namely the size reduction of the @tls handshake.
Initially, we focus on the authentication related cryptographic material exchanged during the handshake.
This means, we do not include the bytes that encode the domain name, key usage constraints, validity timestamps, and similar.
We do also ignore the bytes required to establish a shared key used for the record layer, which is used for the encryption and authentication of the payload messages.
Hence, an X.509 handshake contains the following components:
One signature for active authentication of the handshake, two signatures for @sct:pl, optionally one signature for an @ocsp staple, one signature of the intermediate @ca on the @ee certificate, and one signature of the root @ca on the intermediate @ca.
In addition, the @ee and intermediate certificate contain one public key each.
The root certificate is typically not sent to the @rp, as it is expected to know it already.
Summing this up, we count six signatures and two public keys.
The last case in @tab:x509_size, marked in yellow, is a special case.
It uses @kemtls and therefore sends a key encapsulation instead of a signature and stores the public key of the @kem in the certificate instead of a public key for signature generation.
For our analysis, we ignore this fact, as it serves the same objective, namely actively authenticating the handshake.

@tab:x509_size contains one optimistic and one conservative but realistic estimate for each, a @pq and non @pq secure setup.
Additionally, it contains one setup for @kemtls.
The optimistic estimate assumes the usage of 256-bit @ecdsa signatures and keys across the whole chain.
About 24~% of all currently active certificates are issued for an @ecdsa key, with about 53~% using a 384-bit and 47~% using a 256-bit key length.
The remaining 76~% of all current @ee certificates use an RSA algorithm. @merkle_town
For the root @ca:pl stored in the Firefox root program, the numbers are a bit different.
44~% (78) use a 4096-bit RSA key, 26~% (46) use a 2048-bit RSA key, 27~% use a 384-bit @ecdsa key and only 2~% (4) use a 256-bit @ecdsa key @firefox_root_store.
Without telemetry data from browsers, it is not possible to judge which are the most common combinations just from the percentage of certificates issued and the configuration of root @ca:pl, as there is a big imbalance on which @ca:pl and certificates are heavily used and which are not.
We tried to get an impression by manually checking the certificate chains for the top 10 domains according to Cloudflare Radar @cloudflare_radar_domains.
The results in @tab:top_10_signatures show that the landscape of used signatures is diverse.
The significance is very limited, though, as five of the ten top domains do not serve a website and are purely used for @api calls (root-servers.net, googleapis.com, gstatic.com, tiktokcdn.com, amazonaws.com).
The remaining five domains serve a website, but it seems likely that the majority of calls still originates from @api calls, which may use different certificate chains.
Moreover, the server may adopt the presented certificate based on a specific subdomain, the user agent, and other factors, which further complicates a holistic view.
Nevertheless, we are convinced that the chosen combinations represent adequate examples.

The signatures for @sct:pl is more uniform.
RFC 6962 @rfc_ct, the specification of certificate transparency, only allows either a 256-bit @ecdsa or a @rsa signature.
The Chrome source code solely contains logs that sign with a 256-bit @ecdsa @chromium_ct_log_list.
Therefore, we assume a 256-bit @ecdsa for the @sct:pl in all cases.

@tab:bikeshed_size shows example sizes for various parameters used for a @mtc setup.
From the number of columns, it becomes obvious that a @mtc contains way less asymmetric cryptography.
The certificate contains a single key used to protect the integrity of the handshake.
Together with the length of the inclusion proof, they determine the size of the authentication related cryptography.
The size of the inclusion proof logarithmically depends on the number of certificates in a batch.
To estimate the size for the inclusion proof, we checked the number of active certificates for the biggest @ca, Let's Encrypt.
According to their own statistics, there exists about 420 million active certificates in October 2024, which matches with observations based on certificate transparency logs @merkle_town @lets_encrypt_stats.
The logs further show that there are around one billion active certificates in total.
For the first estimate of the proof length, we take Let's Encrypt's recommendation to renew certificates every 60 days.
Knowing that certificates issued by Let's Encrypt are always valid for 90 days, we can deduce that there exist around $420 dot 10^9 dot 60/90 = 280 dot 10^9$ authenticating parties using the services of Let's Encrypt.
In a @mtc setup, @ap:pl are recommended to renew their certificates every ten days.
Assuming that a batch lasts for one hour, each batch contains $(280 dot 10^9)/(10 dot 24) = 1.16 dot 10^9$ certificates.
To accommodate this number of assertions, the Merkle Tree requires $ceil(log_2 1.16 dot 10^9)  = 21$ level, resulting in a proof length of 21 hashes.
The current draft only allows #gls("sha")-256 as hashing algorithm and also future iterations are unlikely to extend the length of the digest, even if changing the algorithm.
Therefore, the proof length for this scenario is $21 dot 32 "bytes" = 672 "bytes"$.

The second scenario indicates a worst-case scenario, assuming a big increase in @ap:pl or centralization to few certificate authorities.
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

Comparing @tab:x509_size and @tab:bikeshed_size reveals that @mtc has big size advantages, especially when using @pq algorithms.
Focusing on the classical case first:
In the best X.509 case, when using only 256-bit @ecdsa for all signatures, @mtc performs slightly worse in terms of the number of authentication bytes.
While the X.509 case requires 448 authentication-related bytes, @mtc requires 768~bytes, which is an absolute difference of 320~bytes, i.e., the X.509 certificate is 41.67~% smaller than the @mtc.
Comparing @mtc to a mostly #gls("rsa", long: false)-based certificate, @mtc demonstrates it advantages, as the X.509 certificate grows to 1,728~bytes.
Therefore, the @mtc is 960 or 800~bytes smaller, depending on the number of active @ap:pl in the @mtc system.
This corresponds to a reduction of 55.56~% or 46.30~%, respectively.
Moving on to the @pq algorithms, the drastic improvement of @mtc shows up.
Compared to the best X.509 case using only @mldsa signatures, @mtc saves 12,740 or 12,580 bytes, resulting in a reduction by 74.31~% or 73.38~% depending on the number of active @ap:pl.
Moreover, it seems realistic that a @ca would use @slhdsa instead of @mldsa due to its higher security guarantees.
This further increases the advantage of @mtc to 80.05~% or 79.79~%, saving 18,176 or 18,016 bytes, respectively.
When replacing the @mldsa key and signature with @mlkem, the handshake is 1,460 bytes smaller, independent of @mtc or X.509.
Nevertheless, the relative gain of @kemtls is bigger for @mtc as it exchanges fewer bytes in the baseline scenario.

// - In the best classical case, X.509 contains less authentication bytes
// - Compared to a realistic setup, @mtc with classical crypto already saves about 1000 bytes.
// - The best (non-KEMTLS) case saves $17,144-4,404=12,740$, i.e., 74.31~%
// - It seems realistic that the @ca will use SLH-DSA (in the beginning), which will increase the difference to $22,580-4,404=18,176$, i.e., 80.05~%
// - A big increase in @ap does not change a lot: $17,144-4,564=12,580$, i.e., 73.38~% / $22,580-4,564=18,016$, i.e., 79.79~%
// - @kemtls makes the savings slightly more impressive: $15,684 - 2,944 = 12740$, i.e., 81.23~% or $15,684 - 2,944 = 12580$, i.e., 80.21~%

// TODO Mention that there are also other size improvements due to the Bikeshed certificate format
In addition to size improvements related to authentication cryptography, @mtc brings additional size improvements by using a new certificate format.
X.509 is based on @asn1 and certificates are transferred in @der encoding.
The @mtc Internet-Draft defines a new certificate format called Bikeshed certificate.
The name is meant as a placeholder, and the authors aim to replace it before it potentially becomes a standard.
@der uses a  type-length-value encoding, meaning that each value in the certificate explicitly has a type and length encoded.
The encoding of @mtc, on the contrary, is more efficient because types and lengths of fields are implicit, i.e., fixed, where possible.
Besides the encoding, the Bikeshed certificate type saves bytes by omitting information that is superfluous in the new setting.
The following fields are not stored in a Bikeshed certificate, that are not already covered by the size considerations above:
- Not before timestamp
- Not after timestamp
- @crl endpoint
- @ocsp endpoint
- @sct timestamps and log IDs
- Key usage restrictions
- Subject and authority key identifier

To give an example:
The certificate chain for `www.google.com`#footnote([SHA-256 fingerprint \ `37:9A:80:C9:25:2C:66:A1:BB:89:D6:C0:C8:83:33:39:55:1D:E6:0F:D3:75:58:5C:F9:A3:18:37:03:57:A0:D6`]) has 2,486 bytes in @der format.
The chain contains 256-bit ECDSA, RSA-2048, and RSA-4096 bit keys and signatures.
Summing them up, the authentication related bytes transmitted in the certificate chain result in 1,248~bytes.
Note that this does not contain the @ocsp staple or handshake signature included in @tab:x509_size as they are not included in the certificate chain itself.
In comparison, a comparable Bikeshed certificate with a 256-bit ECDSA key would contain 704 authentication related bytes, assuming 280 million active @ap:pl.
The full certificate would be 785 bytes in size.
Thus, the X.509 certificate chain has an overhead of 1,238 bytes or 99~% while the Bikeshed certificate has an overhead of 81 bytes or 12~%.
Even though we only analyzed a single example that closely, this indicates that the X.509/@asn1 format produces a significant overhead, that can be reduced by introducing a new certificate format.
An analysis of the certificate chains of the top websites provides shows that certificates are often even bigger than our example.
#cite(<dennis_cert_size>, form: "author") investigated the size of certificate chains send by roughly 75,000 of the Tranco the top sides~@tranco.
It shows that the 5#super[th] percentile of certificate chains is 2308~bytes big and the median certificate chain has even 4032~bytes.
Applying existing certificate compression algorithms, this reduces to 1619~bytes and 3243~bytes, respectively~@dennis_cert_size.
This shows that @mtc is almost always smaller in practice, even when using classical authentication algorithms instead of @pq.

== Update Mechanism Considerations <sec:update_size>
As with many optimizations, one does not get the results from @sec:certificate_size without a trade.
The @mtc architecture requires the @rp to regularly update the tree heads it trusts, as shown in Step 5 of @fig:mtc_overview.
To pull the updates, the @rp regularly requires a connection to the Transparency Service.

This update mechanism is the reason the @mtc architecture cannot replace all X.509 based @pki:pl.
For the @tls use cases, the updates are feasible.
There are a few common use cases for @tls:
For public websites served via @https and visited by a browser, the browser requires a connection to the internet anyway.
For public @api:pl, the connecting @rp requires an internet connection as well.
For services hosted in a corporate network that does not allow connections to the public internet, it should not be a problem either.
In this case, corporate networks should use an internal @ca, instead of relying on public @ca:pl.
On the contrary, non @tls use cases that rely on X.509 certificates are not covered by the @mtc architecture, which is also clearly stated in the Internet-Draft.
For example, smart cards could not regularly update the stored certificates, as they do not have an internet connection.
Signing documents or code would not work either, as an entity verifying the signature would need to remember all trusted batch tree heads of the past.
In other words, validating the signature produced by the certified key should happen temporally close to the certificate issuance, in the order of few weeks at most.

// - @rp:pl have to be updated regularly.
// - Requires a constant connection to the internet and validation of the certificate temporally close to certificate issuance
//   - not a problem as this is in the nature of browsers
//   - Not possible for other use cases where certificates are used
//     - smart cards
//     - secure boot
//     - document or code signing

For the use cases that allow a regular update, an important metric for the update mechanism is the amount of data that needs to be transferred from the Transparency Service to the @rp:pl.
We base this estimation on a web surfing use case with the following assumptions:
We assume 150 trusted root @ca:pl, which is somewhere between the number of @ca:pl currently in the root store of Firefox and Chrome @firefox_root_store @chrome_root_store.
Furthermore, we assume each @ca uses a batch duration of one hour and lifetime of 14 days, as recommended in the Internet-Draft @rfc_mtc[Section 5.1].
According to a recent post by O’Brien, working in the Chrome Security team at Google, Chrome strives for an update frequency of six hours or less @mtc_fallback_estimate.
Therefore, we assume six hours as the default browser update frequency for @mtc tree heads.
Lastly, we assume each @ca to use #gls("slhdsa")-128s to sign their validity window as the security guarantees for this algorithm are better compared to @mldsa, which is relevant for a long-lasting key.

In addition to the basic assumptions, the update size depends on what exactly a @rp pulls from the Transparency Service.
The straightforward way is to regularly pull all signed validity windows of all trusted root @ca:pl.
Each validity window contains 7,856 bytes for the signature, 4 bytes for the batch number, and $24 dot 14 dot 32 = 10,752$ bytes for the three heads.
Multiplying this with 150 trusted @ca:pl, each update transfers around 2.8 Megabyte, independent of the update cadence.
As an optimization, the transfer could only contain the tree heads that the @rp does not know yet.
This reduces the bytes transferred for the tree heads to $6 dot 32 = 192$ bytes if a @rp updates exactly every six hours.
The signature would match the most recent batch number transferred, as it covers all valid batch tree heads anyway.
In other words: The Transparency Service does not need to transfer one signature for each batch tree head, but only one per update per @ca.
Together, this results in $150 dot (7,856 + 4 + 192) approx 1.2$~megabyte for each update every six hours.
During a day, that accumulates to 4.8 Megabytes per @rp.
A more extreme optimization requires full trust into the update mechanism and Transparency Service.
In such circumstances, the update can omit the @ca signatures and save significant update bandwidth that way.
For a six-hour update interval, each update contains $150 dot (4 + 192) = 29.4$ kilobytes, adding up to 117.6 Kilobytes per day.
Compared to transferring the signatures, this saves 97.6~% in update bandwidth.
The shorter the update interval, the more advantageous it is to omit the signature, as it needs to be transferred once per update.

All the updates sizes scale linearly with the number of active @ca:pl.
This means, if we assume only 15 @ca:pl that support the @mtc architecture, we can reduce the estimates on the update size for all scenarios by 90~% to 280~kilobyte for a full update, 120~kilobytes for an update every six hours including @ca signatures, and only three kilobytes for an update every six hours without the @ca signatures.
This might be a reasonable assumption as well, especially at the beginning, as only the biggest @ca:pl are likely willing to invest the necessary resources in such a fundamental change.

As mentioned, omitting the @ca signatures requires trust in the Transparency Service and update mechanism.
It is important to note that the Transparency Service that the browser uses to retrieve its updates is likely operated by the browser vendor.
In practice, users must trust their browser vendor in the first place to not build in any backdoors or install untrusted @ca:pl.
To mitigate potential damage from this trust relation, a browser vendor could set up a verifiable, transparent update log that all updates must be pushed to before they can be installed by the browser.
A similar setup -- namely firmware transparency -- is described as part of the Tillian project containing software to build a transparency log, mostly used for #gls("ct", long: true) @trillian_firmware_transparency.
However, the precise realization is not straightforward as the present transparency log implementations rely on classical signatures such as @rsa or @ecdsa.
Additionally, the mechanism to bootstrap the updates requires some engineering, as it cannot be assumed that the browser knows recent @mtc roots that could be used to set up a #gls("tls")-based update connection.
Potentially, the update mechanism requires large X.509 certificates with @pq cryptography, at least in some cases.

// - Size
//   - Should not send whole signed validity window every day
//     - There are currently ~150 trusted root CAs
//     - If TS->RP updates delta + signature once a day 
//       - If each of the CAs produces a new tree head every hour, this would be $24 dot 150 dot 32 "bytes" = 67,200 "bytes"$ of tree heads per day
//       - Only the last valid signature needs to be distributed: Assuming SLH-DSA-128s $150 dot 7,856 = 1,178,400 "bytes"$
//       - In sum, that are: 1,245,600B = 1.3MB per day
//       - Compression should likely not work
//     - If TS->RP pushes the whole validity window
//       - Each signed validity window is about $7,856 "bytes" + 336 dot 32 "bytes" = 18,608 "bytes"$
//       - Times the number of CAs: $150 dot 18,608 = 2,791,200 => 2.7 "MB"$
//     - Daily update without the signatures:
== Common File Structure
Besides small update sizes, it is desirable to store @mtc related data on a common place on an @os.
Having a common place for certificates on a single machine has the multiple advantages.
Firstly, it reduces the number of updates required in the @mtc architecture.
Instead of every application pulling their own updates, the @os can take care of it for various applications depending on up-to-date tree heads.
Furthermore, applications do not have to implement the update logic themselves.
This does save development resources and reduces the attack surface as there exist fewer different implementations.

Nowadays, Linux based operating systems such as Debian, RHEL, or Android store certificates on a well known location for other programs to access it @go_root_store.
// Debian, as an example, provides the trusted root certificates as a normal system package, which can be updated with the built-in package manager @debian_ca_certificates.
We use the X.509 file structure of Debian as an inspiration to propose a common file structure.
@fig:mtc_client_file_tree shows the file structure we propose for a @rp.
The absolute path (`/etc/ssl/mtc`) might vary per distribution.
The structure thereafter is more interesting.
We propose that each @ca lives in its own subdirectory, with the Issuer ID as the directory name.
The Issuer ID for @mtc:pl is an @oid, so directory names would look like `123.54.2`.
The directory contains the @ca parameters, the root hashes of the validity window and optionally the signature of the validity window.
As mentioned above, the signature is not necessary if the @rp trusts the Transparency Service and update mechanism.
In this case, the Transparency Service is not operated by a browser vendor, but maybe by the @os vendor.
Still, the argument remains that a user needs to trust its @os vendor either way and may therefore skip synchronizing the signature.
In the proposed structure, the validity window contains the same data as specified in the Internet-Draft, namely the batch number and the hashes of all valid tree heads.
The @ca parameters contain the following information:
- The issuer ID, i.e., the @oid of the @ca
- The signature scheme used to sign the validity windows
- The public key of the @ca. It must match the signature scheme
- The proof type used for inclusion proof in the certificates. As of now, the only option is a #gls("sha")-256 based Merkle Tree inclusion proof
- The start time of the @ca, i.e., the time the @ca was set up. This is required to calculate the validity of a certificate based on its batch number
- The batch duration. This is required to calculate the validity of a certificate based on its batch number as well
- The validity window size. Again, This is required to calculate the validity of a certificate based on its batch number


#figure(
  box(mtc_client_file_tree),
  caption: [Proposed file structure on a @rp. The signature only exists on @rp:pl that are willing to perform the @pq signature check themselves. The public key of the @ca is part of the @ca parameters.]
) <fig:mtc_client_file_tree>

For a server setup, it is likely not as important to aim for a homogeneous file structure.
Nevertheless, it is worth making explicit what data is required by an @ap to function in the @mtc architecture.
@fig:mtc_server_file_tree provides an example file structure that could be used.
As for the file structure of the @rp, we propose to create one directory per Issuer ID.
Within that, the valid @mtc certificates are stored, named as `<batch_number>.mtc`.
Adhering to the recommended parameters, there are either one or two valid certificates at a time, because of the overlapping of old and new certificates.
For the @ap, the only relevant information from the @ca parameters are the start time, batch duration, and validity window size to be able to calculate if a certificate is expired.
The Issuer ID is included in the certificates, but it is likely handy to include it in the @ca parameters nevertheless.
We propose to keep the format for the @ca parameters the same for @rp and @ap, such that they can share the same parser logic.
At the same time, storing some information on the @ap that is not strictly required, does not seem to entail significant downsides.


#figure(
  box(mtc_server_file_tree),
  caption: [Example file structure on an @ap.]
) <fig:mtc_server_file_tree>


// - The signature over the validity window has the advantage that a CA would need to keep a split view over the whole window instead of for a single batch. See https://github.com/davidben/merkle-tree-certs/issues/84