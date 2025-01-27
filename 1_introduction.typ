#import "imports.typ": *

= Introduction <sec:introduction>
== Motivation <sec:motivation>
Continuous improvements in quantum computing pose an incalculable risk to encryption algorithms used today.
It is unclear when quantum computers will be capable of breaking today's encryption algorithms or even if they will ever be able to.
Still, it is necessary to develop new ciphers and protocols already, as it takes much time and research to become confident in the security of a new cryptographic system.

One of the most important encryption protocols used today is @tls.
Websites use it to protect the integrity, authenticity, and confidentiality of communication with the browser.
According to Firefox telemetry data from October~2024, about 83~% of all page loads worldwide — and even 94~% in the USA — are secured by #gls("https", long: false), which is based on @tls~@firefox_telemetry.
Besides @https, more protocols use @tls to secure the communication.
For instance, #gls("imap", long: false) and #gls("smtp", long: false) -- used for e-mail exchange -- and #gls("ldap", long: false), which is often used as a central place to store credentials in a corporate network, have secured variants that build on @tls.

Securing @tls against attacks by quantum computers consists of three parts: protecting the confidentiality of the connection, ensuring server authentication, and validating the server identity.
The first is the most critical, as messages stored today can be decrypted retroactively by a #emph[harvest now, decrypt later] attack.
The @ietf Internet-Draft "Hybrid key exchange in TLS~1.3"~@tls1.3_hybrid provides a solution to that, and browsers are in the process of rolling it out already~@chrome_kyber @firefox_125_nightly.
Between 12~% and 20~% of the connections are already protected that way~@cloudflare_radar.
The second part of the @pq transition -- server authentication -- is covered by @kemtls.
It mitigates that current #gls("pq")-secure signatures are much bigger than their classical counterparts.
As the name suggests, @kemtls ensures server authentication using @pq safe @kem:pl instead of signatures.
As current @pq @kem:pl encapsulations are about half as big as @pq signatures, @kemtls reduces the message size compared to the naive replacement of classical signature with @pq signatures~@kem_tls.

The last of the three parts concerns securing the certification process that binds domain names to a long-living private key.
The current infrastructure uses certificates issued by trusted #glspl("ca"), which attests to the link between the domain name and private key.
These certificates comprise numerous signatures, which would significantly increase the size of the certificate if naively substituted with their @pq counterparts.
Big certificates increase the data transferred during @tls handshakes, resulting in a worse performance or even broken connections due to non-standard conforming implementations that worked fine so far. @david_adrian_tldrfail_2023

To avoid large certificates, the @ietf Internet-Draft "Merkle Tree Certificates for TLS"~@rfc_mtc proposes a new architecture for certificate infrastructures.
It uses Merkle Trees and Merkle Tree inclusion proofs to reduce the size of messages exchanged during @tls handshakes.
The architecture is designed for most common use cases but has a reduced scope compared to the current certificate infrastructure.
Thus, the proposed architecture is meant to enhance the current certificate infrastructure rather than replace it.

== Our Contributions <sec:our_contributions>
This work analyzes the Internet-Draft for #glspl("mtc", long: true) regarding the computational effort and number of bytes transferred during the @tls handshake and implements the necessary changes in a @tls stack for the first time.
First, we compare the size of @tls handshake messages in a classical, X.509-based #gls("pki", long: true) with the message size of the proposed @mtc architecture.
We do this for both classical, non-@pq secure signature schemes and with the @pq signature schemes that the @nist recently specified.
We show that the @mtc architecture is more size efficient in all cases and handles the big sizes of @pq signatures much better than an X.509-based setup.
Furthermore, the @mtc setup requires a new update channel, as @rp:pl must regularly refresh their roots of trust.
We estimate and interpret the size of these updates based on different assumptions derived from statistics in the current @pki.
Further, we estimate the CPU cycles clients use to verify @mtc and X.509 certificates and compare them with each other.

As a second contribution, we created the first @tls implementation compatible with the @mtc architecture.
We based our implementation on the popular #emph[Rustls] library and modified it to deal with two new negotiation mechanisms.
These negation mechanisms become necessary to allow the client and server to agree on the @mtc certificate type and a specific trust anchor.
In addition, we developed a library to verify @mtc:pl and integrated it into the Rustls library.
This demonstrates that the @mtc Internet-Draft works in practice, and we confirmed that the negotiation mechanisms maintain interoperability with the existing certificate infrastructure.

During the implementation process, we encountered some difficulties with the specification.
We contributed fixes and added some improvements for all the problems we found.
For example, we encountered incorrect test vectors caused by using a 16-bit rather than the specified 8-bit length prefix.
We corrected these in the Internet-Draft and the @ca implementation that produced these test vectors.
Besides the fixes, we incorporated a new trust anchor negotiation mechanism into the proposed standard and implemented the required changes in the provided @ca implementation.
Moreover, we proposed a length prefix for the @mtc embedding in the @tls `Certificate` message to allow parsing the @tls certificate message without depending on an external state.
This length prefix will be incorporated in the next pre-release of the standard.
Beyond that, we suggested a standard file structure of #gls("mtc")-related files for @tls clients and servers, based on how certificate files are organized on modern Linux-based computer systems nowadays, incorporating the changed needs that arise with the use of @mtc.

== Outline
We start this work with an Introduction containing the Motivation (@sec:motivation) and Our Contributions (@sec:our_contributions).
Afterward, @sec:preliminaries introduces the preliminaries required for this work.
This includes @sec:merkle_trees, which explains the basics of Merkle Trees, followed by @sec:pki, which provides an overview of the current #gls("pki", long: true), including #gls("ocsp", long: false), #gls("acme", long: false), and #gls("ct", long: true).
Moreover, in @sec:tls, we recap the relevant parts of a @tls handshake and briefly present an optimized version called @kemtls.
As a last preliminary, @sec:pq_signatures lists some classical and #gls("pq", long: true) secure signature schemes with their performance metrics.
Next, @sec:mtc introduces the #gls("mtc", long: true) architecture and contains sections that provide details about the #gls("ca", long: true) (@sec:mtc_ca), the Transparency Service (@sec:mtc_ts), and the negotiation of @mtc in @tls (@sec:negotiation_tls).
After explaining the @mtc architecture, @sec:mtc_pki_comparison compares the @mtc with the X.509 architecture.
We split specific considerations into four sections.
@sec:certificate_size compares the certificate sizes and @sec:update_size investigates the size requirements of the new update mechanism.
Moreover, in @sec:file_structure, we propose a common file structure for devices that support @mtc, which we base on the file structure commonly used for X.509-related files.
The last comparison, in @sec:cpu, focuses on the CPU associated with using @mtc or X.509 certificates.
Further, @sec:development summarizes the development process of the Rustls-based @mtc server and client implementation and contributions to the standardization process.
Lastly, @sec:conclusion summarizes the findings and provides items that deserve further attention.