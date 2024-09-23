#import "@preview/bytefield:0.0.6": *

#bytefield(
// Config the header
bitheader(
"bytes",
// adds every multiple of 8 to the header.
0, [start], // number with label
5,
// number without label
12, [#text(14pt, fill: red, "test")],
23, [end_test],
24, [start_break],
36, [Fix], // will not be shown
angle: -50deg, // angle (default: -60deg)
text-size: 8pt, // length (default: global header_font_size or 9pt)
),
// Add data fields (bit, bits, byte, bytes) and notes
// A note always aligns on the same row as the start of the next data field.
note(left)[#text(16pt, fill: blue, font: "Consolas", "Testing")],
bytes(3,fill: red.lighten(30%))[Test],
note(right)[#set text(9pt); #sym.arrow.l This field \ breaks into 2 rows.],
bytes(2)[Break],
note(left)[#set text(9pt); and continues \ here #sym.arrow],
bits(24,fill: green.lighten(30%))[Fill],
group(right,3)[spanning 3 rows],
bytes(12)[#set text(20pt); *Multi* Row],
note(left, bracket: true)[Flags],
bits(4)[#text(8pt)[reserved]],
flag[#text(8pt)[SYN]],
flag(fill: orange.lighten(60%))[#text(8pt)[ACK]],
flag[#text(8pt)[BOB]],
bits(25, fill: purple.lighten(60%))[Padding],
// padding(fill: purple.lighten(40%))[Padding],
bytes(2)[Next],
bytes(8, fill: yellow.lighten(60%))[Multi break],
note(right)[#emoji.checkmark Finish],
bytes(2)[_End_],
)
