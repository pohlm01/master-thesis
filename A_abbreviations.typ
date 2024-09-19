#import "@preview/glossarium:0.4.1":  print-glossary

= Abbreviations

#print-glossary((
    (key: "tls", short: "TLS", long: "Transport Layer Security"),
    (key: "ocsp", short: "OCSP", long: "Online Certificate Status Protocol"),
    (key: "ca", short: "CA", long: "Certificate Authority"),
    (key: "pki", short: "PKI", long: "Public Key Infrastructure"),
    (key: "crl", short: "CRL", long: "Certificate Revocation List")
  ),
  disable-back-references: true)