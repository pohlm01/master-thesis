#import "imports.typ": *

= Introduction <sec:introduction>
== Motivation
Continuous improvements in quantum computing pose an incalculable risk to encryption algorithms used today.
It is not clear when quantum computers will be capable of breaking today's schemes, or even if they will ever reach this point.
Still, it is important to develop new ciphers and protocols already as it takes time and a lot of research to become confident enough in the security of a new cryptographic system.

#gls("tls", long: false), acronym for Transport Layer Security, is one of the most important encryption protocols used.
Nearly all websites use it to protect the integrity, authenticity, and confidentiality of the communication with the browser.
Besides HTTPS used for websites, more protocols use TLS to secure their communication.
To name a few: IMAP and SMTP used for e-mail exchange and LDAP, which is often used as a central place to store credentials in a corporate network, have secured variants that build on TLS.

Making TLS secure against attacks by quantum computers comes with a couple of challenges to solve.
To prove ownership of a website, Certificate Authorities (CAs) hand out a certificate to the legitimate website owner.
These certificates contain several signatures.
The big signature sizes of today's quantum-resistant schemes cause performance problems and even broken connections due to non-standard conform implementations that worked fine so far~@david_adrian_tldrfail_2023.

A new draft RFC~@rfc_mtc tries to mitigate the issue of big signatures with a new architecture of certificate infrastructures.
It uses Merkle Trees and inclusion proofs to them, to reduce the message sizes.
It aims to reduce the message sizes in most common cases by sacrificing general applicability.
Thus, the proposed architecture is meant as an addition to the current certificate infrastructure and not as a substitution.

Please note that the goal of this draft RFC is different from what is already being deployed in the real world.
The draft RFC "Hybrid key exchange in TLS~1.3" @tls1.3_hybrid makes that clear.
The attack known as #emph[harvest now, decrypt later] where an attacker stores captured traffic to decrypt it as soon as quantum computers are available is only a threat to confidentiality.
Session authentication, on the other hand, cannot be broken retroactively.
Nevertheless, it is important to investigate alternative authentication mechanisms already, as it takes time to develop and widely adopt them over the internet.




== Outline
