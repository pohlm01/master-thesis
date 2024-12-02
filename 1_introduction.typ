#import "imports.typ": *

= Introduction <sec:introduction>
== Motivation
Continuous improvements in quantum computing pose an incalculable risk to encryption algorithms used today.
It is not clear when quantum computers will be capable of breaking today's encryption algorithms, or even if they will ever be able to.
Still, it is necessary to develop new ciphers and protocols already, as it takes much time and research to become confident in the security of a new cryptographic system.

One of the most important encryption protocols used today is @tls.
Websites use it to protect the integrity, authenticity, and confidentiality of the communication with the browser.
About 83~% of all page loads worldwide -- and even 94~% in the USA -- are secured by #gls("https", long: false), which is based on @tls, according to Firefox telemetry data from October 2024 @firefox_telemetry.
Besides @https, more protocols use @tls to secure the communication.
For instance, #gls("imap", long: false) and #gls("smtp", long: false) used for e-mail exchange and #gls("ldap", long: false), which is often used as a central place to store credentials in a corporate network, have secured variants that build on @tls.

Securing @tls against attacks by quantum computers consists of three parts: protecting the confidentiality of the connection, ensuring server authentication, and validating the server identity.
The first is the most critical, as messages stored today can be decrypted retroactively by a #emph[harvest now, decrypt later] attack.
The @ietf Internet-Draft "Hybrid key exchange in TLS~1.3"~@tls1.3_hybrid provides a solution to that, and browsers are in the process of rolling it out already~@chrome_kyber @firefox_125_nightly.
Between 12~% and 20~% of the connections are already protected that way @cloudflare_radar.
The second part of the @pq transition -- server authentication -- is covered by @kemtls.
It mitigates the issue that @pq secure signatures are a lot bigger than their classical counterparts.
As the name suggests, @kemtls ensures server authentication using @pq safe @kem:pl instead of signatures.
As current @pq @kem:pl encapsulations are about half as big as @pq signatures, @kemtls reduces the message size compared to the naive replacement of classical signature with @pq signatures~@kem_tls.

The last of the three parts is about securing the certification process that ties domain names to a long-living private key.
The current infrastructure uses certificates issued by trusted #glspl("ca") which attests the link between domain name and private key.
These certificates comprise numerous signatures, which would significantly increase the size of the certificate if naively substituted with their @pq counterparts.
Big certificates increase the data transferred during @tls handshakes, resulting in a worse performance or even broken connections due to non-standard conform implementations that worked fine so far. @david_adrian_tldrfail_2023

To avoid big certificates, the @ietf Internet-Draft "Merkle Tree Certificates for TLS"~@rfc_mtc proposes a new architecture for certificate infrastructures.
It uses Merkle Trees and inclusion proofs to them to reduce the size of messages exchanged during @tls handshakes.
The architecture is designed for most common use-cases, but has a reduced scope compared to the current certificate infrastructure.
Thus, the proposed architecture is meant as an additional optimization to the current certificate infrastructure and not as a substitution.

This work investigates the proposal for @mtc:pl.
We built the first @tls implementation of the Internet-Draft to demonstrate that the draft works in practice.
The implementation brought a few difficulties to light, those solutions we successfully contributed back to the standardization process.
Additionally, we analyzed the reduction of the message size and provided size estimates for the regular updates that become necessary with the new architecture.
Moreover, we propose a standard file structure of @mtc related files for @tls clients and servers.


== Outline
