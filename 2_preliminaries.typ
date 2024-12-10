#import "imports.typ": *
#import "figures.typ": *
#import "tables.typ": pq_signatures

= Preliminaries <sec:preliminaries>
This section provides information relevant to understanding the architecture of #gls("mtc", long: true) and its implications.
It starts with a reminder of Merkle Trees and continues with an explanation of the present #gls("pki", long: true), including its building blocks, the #gls("acme", long: true), the #gls("ocsp", long: true), and the #gls("ct", long: true) design.
Afterward, this section provides a summary of the @tls protocol and the optimization @kemtls, and ends with a list of relevant #gls("pq", long: true) secure signature algorithms.

== Merkle Trees
Merkle Trees, also known as Hash Trees, are binary trees with the property that each inner node is the result of a cryptographic hash function on its child nodes.
Merkle Trees are tamper-evident and enable efficient verification of whether an element is included in the tree.
The term "tamper-evident" refers to the inability to add, delete, or modify information contained within the Merkle Tree without changing the root node.
An efficient verification means that, given the information and a proof, one can easily verify that the information is contained in the root hash.

As a reminder: A hash function takes an arbitrary length input and produces a fix-length output.
In the following, we will use $h = H(x)$ to denote that $h$ is the result of applying the hash function $H$ in the input $x$.
In addition, a cryptographic hash function typically has three properties: Collision resistance, first preimage resistance, and second preimage resistance.
Collision resistance means that it is hard to find any two inputs $x eq.not x'$ that result in the same hash output $H(x) = H(x')$.
First preimage resistance means that it is hard to find an input $x$ that produces a given hash output $h$. 
In other words, given a hash $h$, it is hard to find $x$ such that $h = H(x)$.
Second preimage resistance means that it is hard to find a second input $x'$ that produces the same hash as a given input $x$.
In other words, given an input $x$, it is hard to find $x'$ such that $H(x) = H(x')$.
Hard in this context means that something is computationally infeasible, i.e., cannot be calculated in polynomial time~@handbook_applied_crypto[Section~9.2.1].

#figure(
  merkle_tree,
caption:  [Visualization of a Merkle Tree with an inclusion proof for information $x_1$.
          The inclusion proof consists of the yellow marked $h_0$ and $h_5$ node, which allows a verifier to recalculate the red, thick path up to the rood node.
]) <fig:merkle_tree>

@fig:merkle_tree shows an example tree for the information $x_0$, $x_1$, $x_2$ and $x_3$.
The leaf nodes contain the hash of the information as $h_i = H_1(x_i)$.
Each of the inner nodes is the result of the hash function $H_2(h_i, h_(i+1))$ with the content of the two child nodes.
That way, one can build an inclusion proof to the root node without reveling any other information.
The inclusion proof contains the sibling hash for each node along the way to traverse up to the root note, so $h_0$ and $h_5$ in the example in @fig:merkle_tree.

Please note that the leaf and internal node use two different hash functions, $H_1$ and $H_2$.
This is to ensure that an internal node can never be interpreted as leaf node.
This would allow constructing multiple Merkle Trees with the same root hash~@merkle_tree_second_preimage.
In practice, it is enough to slightly alter the hash function, such as by prepending a single domain separator byte which is different for the leaf and internal nodes~@rfc_ct.
The internal hash function $H_2$ takes two arguments, even though hash functions generally only take a single input.
However, there are multiple ways to circumvent this restriction, for example, by concatenating the two inputs into one.

As long as the used hash function is collision resistant, it is not possible to alter, add, or delete any information included in the Merkle Tree without changing the hash of the root node~@handbook_applied_crypto[Section~13.4.1].
Instead, it is possible to add information to the tree and create a consistency proof showing that only specific data was added, but nothing else has changed in the tree.
This property can be used to build logs that are verifiably append-only~@rfc_ct.

== Public Key Infrastructure <sec:pki>
// - binds a public key of a set of information 
//   - typically an identity (WebPKI)
//   - but may also be permissions (e.g., @rpki)
// - Has the following components
//   - @ca
//     - Registration Authority
//     - Validation Authority
//   - 
// - used for @okta_pki
//   - Email encryption and authentication of the sender
//   - Signing documents and software
//   - Securing local networks and smart card authentication
//   - Restricted access to #glspl("vpn")

A #gls("pki", long: true) is a crucial part of ensuring security in various digital systems.
Its core functionality is to bind a cryptographic public key to a set of verified information~@rfc_pki.
Typically, this information represents an identity such as a domain name, company name, or the name of a natural person.
However, in some cases, the verified information instead contains permissions, or ownership, without an identity.
An example of that is the @rpki, which is used to secure @bgp announcements and therefore harden the security of routing on the internet @rfc_rpki.

The verified information and public key are combined with a cryptographic signature of the @ca and form a #emph([certificate]) that way.
The common format to encode the verified information and signature is X.509.
Later, a #gls("rp", long: true) can parse the certificate, verify the signature, and trust the signed information given that it trusts the @ca.

Such certificates are widely used in many applications. 
To name a few examples: It is used to encrypt and sign emails, to sign documents or software, to authenticate with a smart card, to restrict access to a @vpn, and to build a secure web browsing infrastructure~@okta_pki.

This work focuses on this last use case, the web browsing.
The corresponding @pki infrastructure is often referred to as #emph([WebPKI]).
It combines the domain name and possibly a company name with a public key, such that a @rp can verify it connected to the intended website.
This verification is built into the @https protocol, which combines the @http with the @tls security layer.
Typically, the @ca does not issue a certificate from its root certificate that is stored as trusted in the @rp:pl.
Instead, a @ca uses an intermediate certificate, signed with the root certificate, to sign the so called #gls("ee", long: true) certificate, i.e., the one attesting the link between the domain name and public key.
Together, the @ee and corresponding intermediate and root certificates are referred to as #emph[certificate chain].

For security reasons, certificates have only a limited lifetime, especially the @ee in the web ecosystem.
Since 2020 Chrome and Apple enforce new @ee certificates to be valid for at most 398 days @chrome_cert_lifetime @apple_cert_lifetime.
Let's Encrypt, a @ca which is responsible for 57~% of all currently valid certificates, issues certificates for just 90 days @merkle_town @lets_encrypt_cert_lifetime.
Let's Encrypt provides two reasons for their comparably short certificate lifetimes:
They want to limit the damage a miss issuance or key compromise can do, and they want to encourage an automated issuance process, which they see as a crucial part of a widespread @https adoption.

Nevertheless, it is important to have a mechanism in place to revoke certificates.
This can be necessary if a private key leaked or the assured information is not accurate (anymore).
There are two mechanisms in place for that:
The @crl:pl are regularly published by the @ca in which all revoked certificates are listed and the #gls("ocsp", long: true) allows @rp:pl to query the @ca if a certificate was revoked in real-time.

// As it will become relevant later on, the following section will explain @ocsp a bit more in-depth.

=== OCSP
@ocsp is meant as an improvement over the classical @crl, as it avoids downloading a list of all blocked certificates occasionally, but instead allows querying a @ca about the status of one specific certificate whenever it is needed.
The @ca includes an #gls("http", long: false) endpoint to an @ocsp responder in the certificates it issues, which @rp:pl such as browsers can query for recent information about whether a certificate is valid~@rfc_ocsp.

In practice, this comes with a couple of issues: Speed, high load on @ca servers, availability, and privacy.
Every time a @rp checks a certificate, an additional round trip to the @ocsp responder is required, which slows down the connection by about 30~%~@ocsp_30p_faster.
Moreover, the @ca:pl have to answer these status requests, which results in a high server load and therefore costs.
If an @ocsp responder is not reachable, the @rp either cannot connect to the server or has to ignore the failure, called fail-close and fail-open, respectively.
The German health care system showcases that a fail-close approach can be very fragile in practice~@e-rezept.
Browsers opted for a fail-open approach in favor of service availability.
This decision, however, limits the benefit of recent information, as an attacker can block access to the @ocsp endpoint and thereby block the information that a certificate was revoked~@ocsp_soft_fail.
Furthermore, @ocsp raises privacy concerns, as @ca:pl can build profiles of users based on which certificates they query.

@ocsp stapling mitigates these issues.
Instead of the user querying the @ocsp responder, the server regularly does so and embeds the response in the certificate message of the @tls handshake~@rfc_ocsp_stapling[Section 8] @rfc_tls13[Section 4.4.2].
This reduces the load on the @ca, eliminates the need for an additional round trip, fixes the privacy issues, and helps with service availability, as the @ocsp responses are cached by the website server for a limited time.

// Knowing about the existence of a certificate might be less obvious, but is undoubtedly an essential building block to revocation.
// The following section explains why this is not self-evident and how to ensure it anyway.

=== ACME
As mentioned earlier, present certificate lifetimes are often 90 days, but not longer than 398 days.
Short certificate lifetimes require automation to not overload humans with constant certificate renewals.
Additionally, automation facilitates widespread adoption of @https as it lowers the (human) effort -- and consequently costs -- associated.
Therefore, Let's Encrypt initiated the development of the #gls("acme", long: true) in 2015 and started issuing certificates in that highly automated way in the same year~@first_acme.
The @acme protocol finally became an #gls("ietf", long: false) standard in 2019~@rfc_acme.

Please note that the fully automated @acme mechanism allows for #emph([Domain Validation]) (DV) certificates only.
This means that the @ca verifies that the requestor has effective control over the domain, as opposed to #emph([Organization Validation]) and #emph([Extended Validation]) which require human interaction to verify the authenticity of the requesting organization.
@mtc requires a high degree of automation, so that DV certificates are the only practical certificate type for @mtc.
However, this is only a limited drawback for the applicable scope of @mtc as 93~% of all valid certificates are DV certificates as of 2024-09-21~@merkle_town.


There exist three standardized methods to verify a user requesting a certificate has effective control over the domain; the `HTTP-01`, `DNS-01`, and `TLS-ALPN` challenges.
Each of them generally works by placing a specific challenge value provided by the @ca into a place that only an owner of a domain can do.
As the names suggest, this is either a web page at a specific path, a TXT #gls("dns", long: false) entry, or a specific ALPN protocol in the @tls stack, respectively.
// Each of them has different advantages and disadvantages, 


// - Used to issue "Domain Validation" (DV) certificates
//   - 93~% of all currently valid certificates (21.09.2024) are DV certificates (@merkle_town)
//   - Alternatively, there are "Organization Validation" (OV) and "Extended Validation" (EV)
// - Receiving a certificate used to be a manual task which hindered a widespread adoption

// #figure(
//   acme_overview,
//   caption: [Overview of certificate issuance using the @acme protocol @rfc_acme]
// )


=== Certificate Transparency
// - WebPKI contains a lot of trusted CA (as of 21.09.2024: 153 Firefox @firefox_root_store, 135 Chrome @chrome_root_store)
// - Response to 2011 attack on DigiNotar
// - Any of them could be compromised and issue certificates for any website
// - Historically, this was difficult to detect
// - Now, each issued certificate must be logged publicly, such that domain owners can be notified about certificates issued on their name

Browser vendors ship a list of @ca:pl which are trusted to issue genuine certificates only.
As of November 6, 2024, there are 176 trusted root @ca:pl built into Firefox and 134 in Chrome~@firefox_root_store @chrome_root_store.
If only a single @ca misbehaves, this can tremendously impact the security of the whole system.
One infamous example is the security breach of DigiNotar in 2011, which allowed the attacker to listen into the connection of about 300,000 Iranian citizens with Google~@diginotar.
This was possible because the domain owner, i.e., Google, could not know that a certificate was issued in their name.
In such a case, even the best certificate revocation mechanism is meaningless, as there is nobody who could initiate it.
As a direct consequence, Google initiated a program to ensure that all issued certificates must be logged publicly such that a domain owner can recognize maliciously issued certificates and take action retroactively.
This is referred to as #gls("ct", long: true).

#figure(
  ct_overview,
  caption: [Certificate issuance with @ct~@certificate_transparency]
) <ct_overview>

@ct_overview illustrates the certificate issuance flow with @ct.
Whenever a domain owner requests a new certificate from a @ca and proves ownership of the domain, the @ca creates a pre-certificate that is mostly identical to the final certificate except that it contains a poison extension and has no @sct:pl embedded yet.
The poison extension ensures that this certificate is never accepted.
The pre-certificate breaks the cyclic dependency, that a #gls("ct")-log needs the certificate to create the @sct, but the @ca needs the @sct to create the certificate.
To issue the final certificate, the @ca must send this pre-certificate to at least two independent #gls("ct")-logs, which will ensure the certificate is logged publicly to an append-only log.
In return, each log provides a @sct to the @ca for including it in the final certificate.
Subsequently, the @ca returns the certificate with the embedded @sct:pl to the domain owner, which can use it whenever a @rp connects thereafter.
At the same time, Monitors are constantly watching the logs and possibly notify a domain owner for every certificate issued on their name.
In addition to Monitors, there are also Auditors -- not shown in the figure -- that check the consistency of the log.
This includes the append-only property, that all certificates are actually logged as promised, and that the log provides the same answers to all clients, independent of the location or other properties~@certificate_transparency.
If the answers provided differ, this is called a #emph[split-view] attack.

The functionality of an auditor may be spread over multiple entities.
For example, the consistency checks could be performed by the monitors, while they are receiving the added certificates anyway.
Additionally, there exists some specific and hardened hardware across the world that checks the log consistency over time and additionally tries to notice any split-view~@verification_transparency_dev @armored_witness.
To check that a certificate actually gets included into the log after the log operator sent a @sct is more complex.
To detect if a certificate was included in the log, browsers can request inclusion proof of a specific certificate for a Signed Tree Head they trust.
Unfortunately, this is difficult to do in practice, as browsers would leak which websites they visited to the log operators.

Nevertheless, @ct is a success and practically unavoidable in the current Web@pki.
This is primarily due to the requirements imposed by major web browsers:
Chrome and Apple require their trusted root @ca:pl to include at least two independent @sct:pl since 2018 and 2021, respectively~@chrome_enforce_ct @apple_enforce_ct.
That way, effectively every certificate must be logged publicly to be of any value.
This solves the problem of certificates that are unknown to a domain owner and @ct allows Monitors to analyze certificates and @ca:pl for misbehavior.

== TLS
// - Standardized by the @ietf
// - successor of @ssl, developed by Netscape Communications in the 1990s
// - Focus on newest version: @tls 1.3 from #cite(<rfc_tls13>, form: "year") specified in @rfc_tls13

// - consists of two sub-protocols
//   - Handshake for negotiation and key exchange
//   - Record to transport data
// - There are various optimizations that we skip here, such as 0-RTT or using a previously (out of band) negotiated key
// - The handshake runs as follows:
//   + `ClientHello` with `key_share`, `signature_algorithms`
//   + `ServerHello` with `key_share`, and encrypted extensions: `Certificate`, `CertificateVerify`, `Finished`, and application data
//   + `Finished` from client to server

#gls("tls", long: true) is building on a history back to the 1990s, when Netscape Communications published the first usable @ssl version, @ssl~2.0 in 1995 and shortly after @ssl~3.0 in 1996.
Afterward, the @ietf took over the development, renamed the protocol to @tls, and published @tls~1.0 in 1999.
The development went further, and the @ietf published the @tls versions 1.1 and 1.2 in 2006 and 2008, respectively.
Ten years later, a major overhaul was published as @tls~1.3 in #cite(<rfc_tls13>, form: "year").
It improved security and incorporated protocol simplifications and speed improvements~@ssl_tls_book.

The following will focus on @tls~1.3 as it is used for 94~% of all @https requests according to Cloudflare Radar on 2024-09-23 and support for @tls 1.1 and older has been dropped by all relevant browsers in 2020~@cloudflare_radar @chrome_drop_tls @firefox_drop_tls @microsoft_drop_tls @apple_drop_tls.

@tls consists of two sub-protocols, the handshake protocol for authentication and negotiation of cryptographic ciphers, followed by the record protocol to transmit the application data.
The following concentrates on the handshake protocol and skips some functionality such as client certificates, the usage of previously or out-of-band negotiated keys, and 0-RTT data that can be used to send application data before the handshake is finished.
This allows focus on the parts relevant to this thesis. 


#figure(
  tls_handshake_overview(),
  caption: [Overview of the simplified TLS~1.3 handshake~@rfc_tls13]
) <tls_handshake_overview>


@tls_handshake_overview illustrates the messages and extensions sent during the @tls handshake and whether they are encrypted.
A @tls connection is always initiated by the client through a `ClientHello` message.
This message contains extensions with a key share and signature algorithms the client supports.
The server responds with a `ServerHello` message, which contains a key share as an extension as well.
Knowing both key shares, the server and client derive a shared symmetric secret and use it to protect all subsequent messages.

The following messages authenticate the server to the client by sending its certificate chain and a `CertificateVerify` message.
The `CertificateVerify` message contains the signature over the handshake transcript up to that point.
This proves the server is in the possession of the private key corresponding to the certificate and messages have not been tampered with.
The handshake ends with a `Finished` message each side sends and verifies.
It contains a @mac over the transcript and thus assures the integrity and authenticity of the handshake.
This @mac is not strictly necessary for the security when performing a full handshake as described in this work, but is essential if protocol optimizations are used which allow using out-of-band or previously negotiated keys, for example~@finished_message_tls13.

After the successful handshake, @tls continues to the record layer to exchange the application data.

=== KEMTLS
@kemtls aims to improve the communication cost of @tls handshakes using the fact that the best currently available @pq @kem:pl are smaller than the @pq signatures.
Instead of explicitly authenticating the server in the `CertificateVerify` using a signature, @kemtls uses @kem:pl to authenticate the key exchange.
The exact differences with the standard @tls handshake are not relevant for this work, so we refrain from explaining them here.
However, it is relevant to note that a @kemtls handshake requires a @kem public key in the @ee certificate instead of a signature key~@kem_tls.
Hence, the utilization of @kemtls has an impact on the size of the certificate, as shown in @sec:certificate_size.

== Post-Quantum Signatures
// - Two PQ signatures are standardized by @nist in @fips_204 (ML-DSA, formally known as CRYSTALS-Dilithium) and @fips_205 (SLH-DSA formally known as Sphincs+)
// - The third - FN-DSA / Falcon - specified later. It relies on dangerous floating-point arithmetic that produces side-channel leakage.

// This section provides a short overview of the @pq signatures available today.
// It helps with understanding size and performance considerations later on.

@pq_signature_comp shows a comparison of @ecdsa and #gls("rsa", long: false)-2048 as classical signature schemes and the @pq signature schemes selected by the @nist for standardization.
@mldsa was known as #box[CRYSTALS]-Dilithium and @nist standardized it as FIPS 204 in 2024, together with the @slhdsa as FIPS 205 @fips_204 @fips_205.
A @nist draft for the @fndsa is expected in late 2024.

The @nist decided to specify three signature algorithms, as each of them has their benefits and drawbacks.
@mldsa is the recommended algorithm for most applications, as it has reasonable values in all categories.
@slhdsa is currently the most trusted algorithm, as it relies on the security of the well-established #gls("sha", long: false)--2 or #gls("sha")--3 hashing algorithms, that would need to be dramatically broken to harm the security of @slhdsa~@sphincs_proposal.
This makes @slhdsa a suitable candidate for long-term keys or situations where an upgrade is hard.
@fndsa might seem to have the best statistics, but it has the big drawback of relying on fast floating-point operations for signature generation.
Without that, signing is about 20 times slower.
The challenge with floating-point arithmetic is to implement it in constant time, and resistant against power analysis, as demonstrated by side-channel attacks against existing @fndsa implementations~@falcon_down @falcon_power_analysis.
This is mainly a concern for signatures produced on-the-fly.
If the signature is computed ahead-of-time, there is no timing leak to be observed.
Moreover, verifying does not rely on floating-point arithmetic, and even if it did, there would not be a private key that could be leaked.
@bas_westerbaan_state_2024


#figure(
  pq_signatures,
  caption: [
    Comparison of selected classical signature schemes with algorithms (to be) standardized by @nist. 
    The #box(baseline: 0.2em, height: 1em, image("images/red-alert-icon.svg")) symbols fast, but dangerous floating-point arithmetic. @bas_westerbaan_state_2024]
) <pq_signature_comp>
