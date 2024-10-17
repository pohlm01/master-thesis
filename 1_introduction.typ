#import "imports.typ": *

= Introduction <sec:introduction>
== Motivation
Continuous improvements in quantum computing pose an incalculable risk to encryption algorithms used today.
It is not clear when quantum computers will be capable of breaking today's schemes, or even if they will ever reach this point.
Still, it is necessary to develop new ciphers and protocols already, as it takes time and a lot of research to become confident enough in the security of a new cryptographic system.

#gls("tls", long: false), acronym for Transport Layer Security, is one of the most important encryption protocols used.
Websites use it to protect the integrity, authenticity, and confidentiality of the communication with the browser.
About 83~% of all page loads worldwide -- and even 94~% in the USA -- are secured by #gls("https", long: false), which is based on @tls, according to Firefox telemetry data @firefox_telemetry from October 2024.
Besides @https, more protocols use @tls to secure the communication.
#gls("imap", long: false) and #gls("smtp", long: false) used for e-mail exchange and #gls("ldap", long: false), which is often used as a central place to store credentials in a corporate network, have secured variants that build on @tls.

Securing @tls against attacks by quantum computers consists of three parts; protecting the confidentiality of the connection, ensuring server authentication, and validating the server identity.
The first is most critical, as messages stored today can be decrypted retroactively by a #emph[harvest now, decrypt later] attack.
The draft RFC "Hybrid key exchange in TLS~1.3" @tls1.3_hybrid describes a solution to that, and browsers are in the process of rolling it out already. @chrome_kyber @firefox_125_nightly
@kemtls ensures server authentication using @pq safe #glspl("kem") to reduce the message size compared to the naive replacement of classical signature with @pq signatures during the handshake. @kem_tls

The last of the three parts is about securing the certification process that ties domain names to a long-living private key.
The current infrastructure uses certificates issued by trusted #glspl("ca") which attests the link between domain name and private key, signed by the @ca.
These certificates comprise numerous signatures, which would significantly increase the size of the certificate if naively substituted with their @pq counterparts.
Big certificates increase the data transferred during @tls handshakes, resulting in a worse performance or even broken connections due to non-standard conform implementations that worked fine so far. @david_adrian_tldrfail_2023

This work investigates a draft RFC~@rfc_mtc that aims to mitigate the issue of big signatures with a new architecture of certificate infrastructures.
It uses Merkle Trees and inclusion proofs to them, to reduce the message sizes.
This approach is designed for most common use-cases, but is not as generally applicable as current certificates.
Thus, the proposed architecture is meant as an addition to the current certificate infrastructure and not as a substitution.


== Outline
