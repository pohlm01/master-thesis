#import "imports.typ": *
#import "figures.typ": acme_overview
#import "tables.typ": pq_signatures

= Preliminaries <sec:preliminaries>
This section will recap on information relevant to understand the topic of this thesis.
It starts with an explanation on how present @pki works, followed by a summary of @tls and a list of post quantum secure signatures that are relevant for this thesis.

== Public Key Infrastructure
A @pki is a crucial part to ensure security in various different digital systems.
Its core functionality is to bind a cryptographic public key to a set of information 

- binds a public key of a set of information @rfc3647
  - typically an identity (WebPKI)
  - but may also be permissions (e.g., @rpki @rfc6487)
- Has the following components
  - @ca
    - Registration Authority
    - Validation Authority
  - 
- used for @okta_pki
  - Email encryption and authentication of the sender
  - Signing documents and software
  - Securing local networks and smart card authentication
  - Restricted access to #glspl("vpn")
  

=== Certificate Authority


=== OCSP
@ocsp
@rfc_ocsp
@rfc_ocsp_stapling[Section 8]

=== Certificate Transparency
- WebPKI contains a lot of trusted CA (as of 21.09.2024: 153 Firefox @firefox_root_store, 135 Chrome @chrome_root_store)
- Response to 2011 attack on DigiNotar
- Any of them could be compromised and issue certificates for any website
- Historically, this was hard to detect
- Now, each issued certificate must be logged publically, such that domain owners can be notified about certificates issued on their name

@certificate_transparency


== ACME
@acme
@rfc_acme

- Used to issue "Domain Validation" (DV) certificates
  - 93 % of all currently valid certificates (21.09.2024) are DV certificates (@merkle_town)
  - Alternatively, there are "Organization Validation" (OV) and "Extended Validation" (EV)
- Receiving a certificate used to be a manual task which hindered a widespread adoption

#figure(
  acme_overview,
  caption: [Overview of certificate issuance using the @acme protocol @rfc_acme]
)

== TLS

- Standardized by the @ietf
- successor of @ssl, developed by Netscape Communications in the 1990s
- Focus on newest version: @tls 1.3 from #cite(<rfc_tls13>, form: "year") specified in @rfc_tls13

- consists of two sub-protocols
  - Handshake for negotiation and key exchange
  - Record to transport data

- There are various optimizations that we skip here, such as 0-RTT or using a previously (out of band) negotiated key
- The handshake runs as follows:
  + `ClientHello` with `key_share`, `signature_algorithms`
  + `ServerHello` with `key_share`, and encrypted extensions: `Certificate`, `CertificateVerify`, `Finished`, and application data
  + `Finished` from client to server

== Post Quantum Signatures

#figure(
  pq_signatures,
  caption: [Comparison of various (non) PQ secure signature schemes @bas_westerbaan_state_2024]
) <pq_signature_comp>

- Two PQ signatures are standardized by @nist in @fips_204 (ML-DSA, formally known as CRYSTALS-Dilithium) and @fips_205 (SLH-DSA formally known as Sphincs+)
- The third - FN-DSA / Falcon - specified later. It relies on dangerous floating-point arithmetic that produces side-channel leakage.