#import "imports.typ": *
#import "figures.typ": *
#import "tables.typ": pq_signatures

= Preliminaries <sec:preliminaries>
This section will recap information relevant to understanding the architecture and its implications of @mtc, the topic of this thesis.
It starts with an explanation of how the present @pki works, followed by a summary of the @tls protocol and a list of relevant post-quantum secure signatures.

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

A @pki is a crucial part of ensuring security in various digital systems.
Its core functionality is to bind a cryptographic public key to a set of verified information @rfc_pki.
Typically, this information represents an identity such as a domain name, company name, or the name of a natural person.
However, in some cases, the verified information instead contains permissions, or ownership, without an identity.
An example for that is the @rpki, which is used to secure @bgp announcements and therefore harden the security of routing on the internet @rfc_rpki.

The verified information and public key are combined with a signature of the @ca and form a #emph([certificate]) that way.
A #emph([relying party]) can subsequently verify the signature and trust the signed information given that it trusts the @ca.

Such certificates can be used in email encryption and authentication of the sender, to sign documents or software, for authentication with a smart card, or to restrict access to a @vpn, for example. @okta_pki
The following concentrates on the @pki infrastructure used to secure the browsing of websites.
It combines the domain name and possibly a company name with a public key, such that a relying party can verify it connected to the intended website.
This @pki infrastructure is often referred to as #emph([WebPKI]).

Certificates have only a limited lifetime.
Since 2020 Chrome and Apple enforce new certificates to be valid for at most 398 days @chrome_cert_lifetime @apple_cert_lifetime.
Let's Encrypt, which is responsible 57~% of all currently valid certificates, issues certificates for just 90 days @merkle_town @lets_encrypt_cert_lifetime.
Let's Encrypt provides two reasons for their comparably short certificate lifetimes:

+ They want to limit the damage a miss issuance or key compromise can do.

+ They want to encourage an automated issuance process, which they see as a crucial part of a widespread @https adoption.

Nevertheless, it is important to have a mechanism in place to revoke certificates.
This can be necessary if a private key leaked or the assured information is not accurate (anymore).
There are two mechanisms in place for that:

+ #glspl("crl") are regularly published by the @ca in which all revoked certificates are listed.

+ The #gls("ocsp", long: true) allows relying parties to query the @ca if a certificate was revoked in real-time.

As it will become relevant later on, the following section will explain @ocsp a bit more in-depth.

=== OCSP
@ocsp is meant as an improvement over the classical @crl, as it avoids downloading a list with all blocked certificates occasionally, but instead allows querying a @ca about the status of one specific certificate whenever it is needed.
The @ca includes an #gls("http", long: false) endpoint to an @ocsp responder in the certificates it issues, which relying parties such as browsers can query for recent information about whether a certificate is valid.
@rfc_ocsp

In practice, this comes with a couple issues: Speed, high load on @ca servers, availability, and privacy.
Every time a relying party checks a certificate, an additional round trip to the @ocsp responder is required, which slows down the connection.
This results in a slowdown of about 30~% for each connection @ocsp_30p_faster.
The #glspl("ca") have to answer these status requests, which results in a high server load and therefore costs.
If an @ocsp responder is not reachable, the relying party either cannot connect to the server or has to ignore the failure.
Browsers opted for the second option in favor of service availability.
This decision, however, limits the benefit of recent information, as an attacker can block access to the @ocsp endpoint. @ocsp_soft_fail
Furthermore, @ocsp raises privacy concerns, as #glspl("ca") can build profiles of users based on which certificates they query.

@ocsp stapling mitigates these issues.
Instead of the user querying the @ocsp responder, the server regularly does so and embeds the response in the certificate message of the @tls handshake. @rfc_ocsp_stapling[Section 8] @rfc_tls13[Section 4.4.2]
This reduces the load on the @ca, eliminates the need for an additional round trip, fixes the privacy issues, and helps with service availability, as the @ocsp responses are cached by the website server for a limited time.

Knowing about the existence of a certificate might be less obvious but undoubtedly essential building block to revocation.
The following section explains why this is not self-evident and how to ensure it anyway.

=== Certificate Transparency
// - WebPKI contains a lot of trusted CA (as of 21.09.2024: 153 Firefox @firefox_root_store, 135 Chrome @chrome_root_store)
// - Response to 2011 attack on DigiNotar
// - Any of them could be compromised and issue certificates for any website
// - Historically, this was hard to detect
// - Now, each issued certificate must be logged publically, such that domain owners can be notified about certificates issued on their name

Browser vendors ship a list of #glspl("ca") which are trusted to issue genuine certificates only.
As of November 6, 2024, there are 176 trusted root #glspl("ca") built into Firefox and 134 in Chrome @firefox_root_store @chrome_root_store.
If only a single @ca misbehaves, this can tremendously impact the security of the whole system.
One infamous example is the security breach of DigiNotar in 2011, which allowed the attacker to listen into the connection of about 300,000 Iranian citizens with Google. @diginotar
This was possible, because the domain owner, i.e., Google, could not know that a certificate was issued in their name.

As a direct consequence, Google initiated a program to ensure that all issued certificates must be logged publically such that a domain owner can recognize maliciously issued certificates and take action retroactively.
This is referred to as @ct.

#figure(
  ct_overview,
  caption: [Certificate issuance with @ct @certificate_transparency]
) <ct_overview>

@ct_overview illustrates the issuance flow for certificates with @ct. To issue a certificate, a @ca must first send a pre-certificate to at least two independent #gls("ct")-logs, which will make sure the certificate will get logged publically to an append-only log.
In return, the @ca gets a @sct to include in the final certificate.
This pre-certificate is a slight adoption of the final certificate to break the cyclic dependency, that a #gls("ct")-log needs the certificate to create the @sct, but the @ca needs the @sct to create the certificate. @certificate_transparency

Chrome and Apple require their trusted root #glspl("ca") to include at least two independent #glspl("sct") since 2018 and 2021, respectively.
That way, effectively every certificate must be logged publically to be of any value.
This allows #gls("ct")-monitors to analyze certificates and #glspl("ca") for misbehavior. @chrome_enforce_ct @apple_enforce_ct


== ACME
As mentioned earlier, present certificate lifetimes are often 90 days, but not longer than 398 days.
Short certificate lifetimes require some kind of automation to not overload humans with constant certificate renewals.
Additionally, automation facilitates widespread adoption of @https as it lowers the (human) effort -- and consequently costs -- associated with its usage.
Therefore, Let's Encrypt initiated the development of the #gls("acme", long: false) protocol in 2015 and started issuing certificates in that highly automated way. @first_acme
The @acme protocol finally became an #gls("ietf", long: false) standard in 2019. @rfc_acme

Please note that the fully automated @acme mechanism allows for #emph([Domain Validation]) (DV) certificates only.
This means that the @ca verifies that the requestor has effective control over the domain, as opposed to #emph([Organization Validation]) and #emph([Extended Validation]) which require human interaction to verify the authenticity of the requesting organization.
This is only a limited drawback since 93~% of all valid certificates are DV certificates as of 2024-09-21 @merkle_town.

// - Used to issue "Domain Validation" (DV) certificates
//   - 93~% of all currently valid certificates (21.09.2024) are DV certificates (@merkle_town)
//   - Alternatively, there are "Organization Validation" (OV) and "Extended Validation" (EV)
// - Receiving a certificate used to be a manual task which hindered a widespread adoption

// #figure(
//   acme_overview,
//   caption: [Overview of certificate issuance using the @acme protocol @rfc_acme]
// )

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

@tls is building on a history back to the 1990s, when Netscape Communications published the first usable @ssl version, @ssl 2.0 in 1995 and shortly after @ssl 3.0 in 1996.
Afterward, the @ietf took over the development, renamed the protocol to @tls, and published @tls 1.0 in 1999.
The development went further, and the @ietf published @tls versions 1.1 and 1.2 in 2006 and 2008 respectively.
Ten years later, the major overhaul was published as @tls 1.3 in #cite(<rfc_tls13>, form: "year").
It improved security and incorporated protocol simplifications and speed improvements.
@ssl_tls_book

The following will focus on @tls 1.3 as it is used for 94~% of all @https requests according to Cloudflare Radar on 2024-09-23 and support for @tls 1.1 and older has been dropped by all relevant browsers in 2020. @cloudflare_radar @chrome_drop_tls @firefox_drop_tls @microsoft_drop_tls @apple_drop_tls

@tls consists of two sub-protocols, the handshake protocol for authentication and negotiation of cryptographic ciphers, followed by the record protocol to transmit the application data.
The following concentrates on the handshake protocol and skips some functionality such as client certificates, the usage of previously or out-of-band negotiated keys, and 0-RTT data that can be used to send application data before the handshake is finished.
This allows focus on the parts relevant to this thesis. 

@tls_handshake_overview illustrates the messages and extensions sent during the @tls handshake and whether they are encrypted.
A @tls connection is always initiated by the client through a `ClientHello` message.
This message contains extensions with a key share and signature algorithms the client supports.
The server responds with a `ServerHello` message, which contains a key share as an extension as well.
Knowing both key shares, the server and client derive a shared symmetric secret only they know and use it to protect all subsequent messages.

The following messages authenticate the server to the client by sending its certificate (chain) and a `CertificateVerify` message.
The `CertificateVerify` message contains the signature over the handshake transcript up to that point.
This proves the server is in the possession of the private key corresponding to the certificate and messages have not been tampered with.
The handshake ends with a `Finished` message each side sends and verifies.
It contains a @mac over the transcript and thus assures the integrity of the handshake and prevents message replay attacks.

After the successful handshake, the application data are exchanged.

#figure(
  tls_handshake_overview,
  caption: [Overview of the simplified TLS 1.3 handshake @rfc_tls13]
) <tls_handshake_overview>

=== KEMTLS

== Post Quantum Signatures
// - Two PQ signatures are standardized by @nist in @fips_204 (ML-DSA, formally known as CRYSTALS-Dilithium) and @fips_205 (SLH-DSA formally known as Sphincs+)
// - The third - FN-DSA / Falcon - specified later. It relies on dangerous floating-point arithmetic that produces side-channel leakage.

This section provides a short overview of the @pq signatures available today.
It helps with understanding size and performance considerations later on.

@pq_signature_comp shows a comparison of @ecdsa and #gls("rsa")-2048 as classical signature schemes and the @pq signature schemes selected by the @nist for standardization.
@mldsa was known as CRYSTALS-Dilithium and @nist standardized it as FIPS 204 in 2024, together with the @slhdsa as FIPS 205. @fips_204 @fips_205
A @nist draft for the @fndsa is expected in late 2024.

The @nist decided to specify three signature algorithms, as each of them has their benefits and drawbacks.
@mldsa is the recommended algorithm for most applications, as it has reasonable values in all categories.
@slhdsa is currently the most trusted algorithm, as it relies on the security of the well-established #gls("sha", long: false)--2 or #gls("sha")--3 hashing algorithms, that would need to be dramatically broken to harm the security of @slhdsa.
This makes @slhdsa a good candidate for long-term keys or situations where an upgrade is hard.
@fndsa might seem to have the best statistics, but it has the big drawback of relying on fast floating point operations for signature generation.
Without that, signing is about 20 times slower.
The challenge with floating point arithmetic is to implement it in constant time, and resistant against power analysis, as shown by side-channel attacks against existing @fndsa implementations @falcon_down @falcon_power_analysis.
This is mainly a concern for signatures produced on-the-fly.
If the signature is computed ahead-of-time, there is no timing leak to be observed.
Also, verifying does not rely on floating point arithmetic, and even if it did, there would not be a private key that could be leaked.
@bas_westerbaan_state_2024


#figure(
  pq_signatures,
  caption: [
    Comparison of selected classical signature schemes with algorithms (to be) standardized by @nist. 
    The #emoji.warning symbols fast, but dangerous floating point arithmetic. @bas_westerbaan_state_2024]
) <pq_signature_comp>
