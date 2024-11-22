#import "tables.typ": *

= Appendix

#rotate(
    -90deg,
    reflow: true,
    [#figure(
      x509_certificates_top_10,
      caption: [Signature types in certificate chains delivered at 06.11.2024 for user agent `Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:132.0) Gecko/20100101 Firefox/132.0` at a Dutch internet connection]
    ) <tab:top_10_signatures>]
)

== Byte level analysis of handshake messages <sec:byte_analysis_handshake>
The implementation of the @tls negotiation mechanisms necessary for @mtc cannot be tested against a independently developed peer, as there exist no other implementation as of now.
Instead, we opted to manually analyze the messages exchanged between the client and server using Wireshark.
The setup contains a simple @tls server and client, both build upon the modified Rustls version supporting @mtc.
The server has a @mtc certificate and a fallback X.509 certificate available.
The client had the @ca parameters, a validity window, and the signature over this validity window available.
On startup, the client validated the signature over the validity window and parsed it if the @ca signature is valid.
For each request, it adds a `server_certificate_type` and `trust_anchors` extension to the `ClientHello` message, specified in RFC~7250 and an ongoing Internet-Draft, respectively~@rfc_raw_public_keys @rfc_tai.

The relevant parts of the `ClientHello` message are shown in @fig:wireshark_client_hello and @fig:bytes_trust_anchors.
The top part of @fig:wireshark_client_hello shows that Wireshark detected an extension to the `ClientHello` that it does not recognize.
The identifier is 64512 or in hexadecimal representation `0xfc00`.
This is the identifier we assigned in our implementation, as the @iana did not allocate an identifier for this extension yet.
The payload of this extension is shown in @fig:bytes_trust_anchors.
It starts with a two-byte #text(red)[length prefix] encoding the total length of the `TrustAnchorIdentifierList` in bytes.
Each of the list items has some #highlight[part in common].
It consists of a one-byte #highlight[#text(red)[length prefix]] for this specific item, followed by the item, i.e., `TrustAnchorIdentifier` itself.
Each of them starts with the sequence #highlight[`3e 0c 0f`], which is the binary @oid encoding for 62.12.15; the Issuer ID we used for the test @ca.
The byte thereafter encodes the *batch number*.
Our implementation is missing an optimization in which only the most recent batch number known to the client is sent, and the server implicitly knows that all older batches are also known to the client.
Going back to the second part of @fig:wireshark_client_hello, we can see that Wireshark correctly parsed the `server_certificate_type` extension and recognized that the client advertises support for X.509, but prefers `0xe0`.
The preference is expressed by the order in the list.
We chose the code point `0xe0` to represent @mtc in out implementation, as the @iana did not assign a value yet.

#figure(
  image("images/wireshark_extension_client_hello.png", width: 60%),
  caption: [`trust_anchors` and `server_certificate_type` extensions parsed by Wireshark for `ClientHello`]
) <fig:wireshark_client_hello>

#figure(
box(align(start)[#text(font: "DejaVu Sans Mono", size: 0.8em)[
0000 #h(0.4cm) #text(red)[00 32] #highlight[#text(red)[04] 3e 0c 0f] *02* #highlight[#text(red)[04] 3e 0c 0f] *04* #highlight[#text(red)[04] 3e 0c 0f] \
0010 #h(0.4cm) *03* #highlight[#text(red)[04] 3e 0c 0f] *01* #highlight[#text(red)[04] 3e 0c 0f] *06* #highlight[#text(red)[04] 3e 0c 0f] *08* \
0020 #h(0.4cm) #highlight[#text(red)[04] 3e 0c 0f] *07* #highlight[#text(red)[04] 3e 0c 0f] *0a* #highlight[#text(red)[04] 3e 0c 0f] *09* #highlight[#text(red)[04]] \
0030 #h(0.4cm) #highlight[3e 0c 0f] *05* \
]]),
caption: [Extension data in `trust_anchors` extension]
) <fig:bytes_trust_anchors>

As a reply to the `ClientHello`, the server sends a couple handshake messages, namely `ServerHello`, `Change Cipher Spec`, `Encrypted Extensions`, `Certificate`, `Certificate Verify`, and `Finished`.
Most of these messages stay the same with @mtc.
The only differences are the `server_certificate_type` extension sent in `Encrypted Extensions` message, and the `Certificate` message.
@fig:wireshark_server_hello and @fig:bytes_certificate_message show the parsed messages in Wireshark and the bytes of the `Certificate` message, respectively.
The top of @fig:wireshark_server_hello shows that the server selected the certificate type with code point `0xe0`, i.e., @mtc.
The second part shows that Wireshark had problem parsing the `Certificate` message and therefore highlights errors in yellow.
This is not a surprise, as Wireshark does not understand the certificate type negotiation and cannot parse @mtc.
Therefore, @fig:bytes_certificate_message show the payload bytes of the `Certificate` message.
It starts with a three-byte #text(red)[length prefix]
  #footnote[
    This is different from the Internet-Draft in version 3, the newest available as of writing.
    Instead, this is specified in our Pull Request which will be published with the next draft version.~@add_array_embedding
  ]
followed by the #text(gray.darken(20%))[Merkle Tree Certificate] itself.
We will not analyze the certificate itself byte-by-byte, as it generated by the Go-based @ca application and successfully parses in the Rust application, which are developed independently to a large extent.
As specified by the length prefix, the @mtc is `0x8c`, i.e., 140 bytes long.
After that follows the two-byte #text(red)[length prefix] for the extension list and the two-byte #highlight(fill: blue.lighten(50%), radius: 1mm)[extension type].
As in the `ClientHello` message, `0xfc00` encodes the `trust_anchors` extension. 
This extension is extension exists, because
  #quote(attribution: <rfc_mtc>)[If the authenticating party sends a certification path that matches the relying party's trust_anchors extension, as described in Section 4.2, the authenticating party MUST send an empty trust_anchors extension in the first CertificateEntry of the Certificate message.]
After the extension type follows a two-byte #text(red)[length prefix] that encodes the extension length, which is zero, meaning the extension is empty.

#figure(
  image("images/wireshark_extension_server_hello.png", width: 60%),
  caption: [`server_certificate_type` in encrypted extensions and `Certificate` message parsed by Wireshark for `ServerHello`. The yellow color indicates that Wireshark detected an error decoding the certificate chain. This is expected as the message contains an @mtc certificate.]
) <fig:wireshark_server_hello>


#figure(
box(align(start)[#text(font: "DejaVu Sans Mono", size: 0.8em)[
0000 #h(0.4cm) #text(red)[00 00 8c] #text(gray)[00 00 00 45 04 03 00 41 04 36 ed 7b dd] \
0010 #h(0.4cm) #text(gray)[4a 3a 42 8c e0 59 83 64 95 43 18 5a 4f 7e d6 1e] \
0020 #h(0.4cm) #text(gray)[64 27 5a df b6 a4 b9 d5 06 83 b2 d2 7b 63 03 94] \
0030 #h(0.4cm) #text(gray)[bf ae 07 92 d8 93 db be f7 25 8d 39 28 c5 34 04] \
0040 #h(0.4cm) #text(gray)[67 27 5b 5c 37 ce 56 2d db fb 69 7f 00 10 00 00] \
0050 #h(0.4cm) #text(gray)[00 0c 00 0a 09 6c 6f 63 61 6c 68 6f 73 74 04 3e] \
0060 #h(0.4cm) #text(gray)[0c 0f 0a 00 2a 00 00 00 00 00 00 00 00 00 20 b5] \
0070 #h(0.4cm) #text(gray)[a1 82 2b 21 3f 4f 84 9d 32 f4 7e d4 de c7 60 96] \
0080 #h(0.4cm) #text(gray)[c2 0b 7e ca fe a8 bc 98 4e 92 02 01 e5 e5 13] #text(red)[00] \
0090 #h(0.4cm) #text(red)[04] #highlight(fill: blue.lighten(50%), radius: 1mm)[fc 00] #text(red)[00 00] \
]]),
caption: [Payload of `Certificate` message]
) <fig:bytes_certificate_message>