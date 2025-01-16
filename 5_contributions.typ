#import "imports.typ": *
#import "figures.typ": *

= Development Insights <sec:development>

#figure(
  implementation,
  caption: [Overview about implemented components]
) <fig:implementation>

// As part of this work, we implemented parts of the @mtc system and contributed to the standardization process.
The objective of this work was to establish an #gls("mtc")-based @tls connection between an @ap and @rp for the first time and to contribute enhancements or address errors or ambiguities in the @mtc Internet-Draft along the way.
@fig:implementation provides an overview of the implemented components and their interactions.
The Transparency Service and Monitor are grayed out as we bypass them for this proof-of-concept setup and instead copy over the validity window and signature directly from the @ca.
As the icons indicate, we based the @ap and @rp on the #emph[Rustls] project~@github_rustls.
For the @ca, we added to the development of an existing @ca implementation that is written along the @mtc specification~@go_mtc_ca.
The @ca is implemented in the programming language Go.

We chose to use Rustls for multiple reasons.
Firstly, writing a whole @tls implementation ourselves seems overcomplicated for this work and fails to demonstrate that the new @mtc system can be integrated well with existing software.
Therefore, we decided to adopt an existing implementation.
Rustls is a comparably modern implementation of the @tls protocol and is cleanly implemented.
One reason is that it never supported @tls~1.1 or older, which helps keep the code base clean and organized.
Nevertheless, Rustls is a serious project that gained adoption in big production deployments~@lets_encrypt_rustls @rustls_openssl_nginx.
Furthermore, Rustls is written in the programming language Rust, which, in contrast to C used in other famous @tls implementations such as OpenSSL, BoringSSL, or wolfSSL, provides memory safety.
Additionally, Rust's strong type system makes catching possible mistakes in the implementation comparably easy already during compilation.
Moreover, we avoided using the same programming language as for the @ca implementation.
This requires rewriting some common parts, such as parsing the binary certificate format and checking the signature.
It also ensures that neither of the implementations covertly behaves differently from expected.


// We started by adding the type definitions required for the certificate type and trust anchor negotiation mechanisms.

// Rustls uses a separate library for checking certificates, called #emph[WebPKI]~@github_rustls_webpki.
// In the Rust ecosystem, libraries are referred to as #emph[crates].

The integration of @mtc into Rustls necessitated numerous modifications.
First, we added the negotiation mechanism for the certificate type based on RFC~7250~@rfc_raw_public_keys.
The negotiation mechanism relies on extensions exchanged during the `ClientHello` and `ServerHello` messages.
This adoption entailed several changes to the Rustls code base, as it needs to keep state about which certificate type was negotiated.
Previously, Rustls assumed X.509 certificates and related structures like stapled @ocsp responses at various places.
In addition to negotiating the certificate type, we implemented the negotiation mechanism for the #glspl("tai", long: true) as described in @sec:negotiation_tls.
Therefore, we extended the certificate selection logic to first match on the requested @tai:pl and fall back to the previously used certificate selection based on the @sni.
We simplified the @tai negotiation so that the client does not preselect the @tai:pl it requests in the `ClientHello` based on a @dns query, simplifying the implementation and testing.
// Instead, the client sends all the @tai:pl it supports, which is only a very limited set in our test setup.
// In a real deployment, this is not practical due to the possibly large set of supported @tai:pl and fingerprinting possibilities.

For checking X.509 certificates, Rustls uses the #emph[WebPKI]~@github_rustls_webpki library.
Similarly, we developed an @mtc verifier library~@github_mtc_verifier.
Specifically, it reads the supported Trust Anchors from `/etc/ssl/mtc` and verifies the @ca signature over the validity window as proposed in @sec:file_structure.
On startup, the library automatically loads all validated root tree heads into memory and also allows triggering a reload during runtime.
For each @tls handshake that negotiated to use @mtc as certificate type, our library
+ parses the certificate,
+ rebuilds the path through the Merkle Tree,
+ checks if the recomputed tree head matches the stored tree head,
+ and checks that the certificate falls in the latest validity window based on the stored @ca parameters and batch number in the certificate.
If there are no errors, the certificate validates.
Note that no signature validation is necessary during the certificate validation, as the @ca signature was checked when loading the tree heads into memory.
This does not mean there is no signature check during the entire handshake.
If no optimization such as @kemtls is used, the `CertificateVerify` message still contains a signature over the messages exchanged up to this point.

Along the way, we identified some issues in the specification and @ca implementation.
// Along the way, the @ca implementation required a few adoptions.
First, we found a mismatch between the test vectors provided in the draft specification due to the use of a 16-bit instead of 8-bit length encoding for @dns names.
The test vectors served as examples for assertions and abridged assertions for given inputs.
We adopted the @ca implementation and standard accordingly~@fix_mtc_length_prefix_1 @fix_mtc_length_prefix_2 @fix_mtc_length_prefix_3.

While we worked on this thesis, the Internet-Draft switched to using #glspl("tai", long: true) to identify the batches.
Before, @mtc contained an Issuer ID as an opaque byte string and a batch number.
During this switch, the authors of the proposed standard forgot to update the definitions for the hash nodes of the Merkle Tree; we fixed this inconsistency.
Additionally, we removed the batch number from the hash input, as it is included in the newly added #gls("tai")-based `batch_id`.
Moreover, we introduced a more concise naming convention distinguishing `issuer_id` and `batch_id` to make it clear where only the @oid part for the issuer is used and where the batch number is appended to the issuer ID~@fix_consitently_use_tai.
Lastly, we also adopted the @ca implementation to the @tai:pl~@add_mtc_tai @fix_mtc_tai.

When implementing the parser for the @tls `Certificate` message, we noticed that a consistent way of embedding the certificate in the @tls message -- independent of the type -- keeps the parsing logic free of external state.
Up to that point, the bytes of the @mtc were embedded into the `Certificate` message without a length prefix.
Strictly seen, a length prefix is unnecessary if the parser knows to interpret the certificate as @mtc as it contains all length information needed.
However, in practice, the parsing happens without knowledge of the negotiated certificate type even though the application as a whole is already aware of it.
Interpreting the certificate bytes is postponed to a later stage and possibly passed on to an external library such as the Rustls WebPKI library or our @mtc verification library.
Therefore, allowing the parser to treat the certificate as opaque bytes with a given length prefix is advisable.
The classical X.509 certificates and the `RawPublicKey` certificate type from RFC~7250~@rfc_raw_public_keys already use a 24-bit length prefix.
We streamlined the @mtc draft specification to embed the @mtc in a 24-bit length prefixed byte array as well~@add_array_embedding.

Moreover, we replaced a pre-standard version of Dilithium with @mldsa in the @ca implementation~@mtc_use_mldsa.
This was required to verify the @ca signature in our @mtc verification library.
The @ca implementation used an implementation of the third round of the @nist post-quantum signature competition, which has slight incompatibilities with the final specification.
As Rust did not have a library of Dilithium in the same round-three state available, the upgrade to the official @mldsa became necessary, for which libraries exist in Go and Rust.

Further, we opened a discussion on simplifying the certificate type negotiation, but the proposal turned out not to be practical~@supersede_certificate_type.
The idea was to combine the certificate type negotiation with the negotiation of the trust anchor.
As the trust anchors negotiation mechanism works not only for @mtc but also for X.509 and possibly other certificate types, we proposed that the peer contains the selected trust anchor in the @tai extension of the `Certificate` message.
So far, the negotiation mechanism merely indicates that one of the proposed trust anchors was selected, but it does not specify which one.
By changing this indication to include the selected @tai, the peer could deduce the certificate type and therefore a separate certificate type negotiation would be superfluous.
However, D. Benjamin identified some issues that might arise from the fact that not all certificates participate in the @tai negotiation mechanism.
Therefore, some niche cases are not properly covered.
For example, if a server sends a fallback certificate that does not participate in the @tai negotiation, or of which the @tai is unknown to the client, the client does not know what certificate type to expect.
As a result, the client cannot parse the certificate even if the client would accept it anyway, such as a widely accepted X.509 certificate.
Consequently, we closed this discussion without additional modifications.

Lastly, we also suggested adding the file structure explained in @sec:file_structure to the Internet-Draft @file_structure.
As explained earlier, we hope to achieve a more uniform @mtc ecosystem from that.
As of this writing, the discussion has not started on that topic yet, so it is unclear if this proposal will be incorporated into the standard~@file_structure.

The development efforts resulted in a successful connection @tls handshake between an example client and server based on our modified Rustls version.
We can use the @ca implementation to create certificates, validity windows, and signatures, which we copy manually to the directories as proposed in @sec:file_structure.
The server loads the @mtc certificates next to the fallback X.509 and serves them to the client if negotiated.
The client uses our @mtc verifier implementation to read the available batch tree heads from the disk, validate the signatures, and validate the @mtc certificates.
@sec:byte_analysis_handshake compares the exchanged handshake messages on a byte level with the text in the Internet-Drafts, illustrating that our implementation adheres to the draft specifications.
This was necessary as our implementation is the first, and interoperability tests with other implementations are, therefore, impossible.
At the same time, we showed interoperability between the existing @ca implementation in Go and our @mtc verifier written in Rust.


// - Develop certificate verifier in Rust #link("https://github.com/pohlm01/mtc-verifier", "pohlm01/mtc-verifier")
// - Integrate MTC negotiation and verification for client and server in Rustls https://github.com/pohlm01/rustls-mtc
  // - Rustls is a modern TLS library purely written in Rust
  // - It gains adoption beyond the Rust ecosystem @lets_encrypt_rustls @rustls_openssl_nginx
  // - Rust is a modern, memory-safe programming language
  // - There exist already a Go implementation of a CA: Show compatibility with it

  // - The integration required implementation/adoption of negotiation mechanism via RFC 7250
  // - Also keeping track of the certificate type: So far X.509 was assumed implicitly at various places
  // - Additionally, implementing TAI negotiation (no DNS mechanism included yet), including choosing the cert at the server
  
  // - Server and client read the data from disk as described in @sec:update_size

  // - mtc verifier provides functionality to check mtc certificates (rebuilding the Merkle tree path in during TLS handshake, verifying CA signature during startup)
  
  

// - Fix prefix error #link("https://github.com/davidben/merkle-tree-certs/pull/90", "davidben/merkle-tree-certs#90"), #link("https://github.com/bwesterb/mtc/pull/2", "bwesterb/mtc#2"),  #link("https://github.com/bwesterb/mtc/pull/4", "bwesterb/mtc#4")

// - Replace `issuer` and `batch_number` in hash structs with `batch_id` #link("https://github.com/davidben/merkle-tree-certs/pull/91", "davidben/merkle-tree-certs#91"), #link("https://github.com/bwesterb/mtc/pull/8", "bwesterb/mtc#8")

// - Update CA implementation to from Dilithium to ML-DSA https://github.com/bwesterb/mtc/pull/9

// - Use array embedding for Certificate message https://github.com/davidben/merkle-tree-certs/pull/95

// - Integrate Trust Anchor Identifiers into example CA implementation https://github.com/bwesterb/mtc/issues/3

// - Discussion on TAI for certificate type negotiation: https://github.com/davidben/tls-trust-expressions/issues/76

// - Propose file/data structure https://github.com/davidben/merkle-tree-certs/issues/97