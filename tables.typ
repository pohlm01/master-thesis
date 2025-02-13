#let o = (body) => table.cell(fill: orange.lighten(50%), body);
#let r = (body) => table.cell(fill: red.lighten(50%), body);
#let y = (body) => table.cell(fill: yellow.lighten(50%), body);

#let chrome_releases = {
table(
  stroke: .1mm,
  align: left,
  columns: 4,
  table.header(
    strong[Major version], strong[Release Date], strong[Days since last release], strong[Days since last major release]
  ),
    table.hline(stroke: .3mm),
    [131],  [December 10, 2024],    [7],    [],
    [131],  [December 3, 2024],     [14],   [],
    [131],  [November 19, 2024],    [7],    [],
    [131],  [November 12, 2024],    [7],    [28],
    table.hline(stroke: .3mm),
    [130],  [November 5, 2024],     [7],    [],
    [130],  [October 29, 2024],     [7],    [],
    [130],  [October 22, 2024],     [7],    [],
    [130],  [October 15, 2024],     [7],    [35],
    table.hline(stroke: .3mm),
    [129],  [October 8, 2024],      [7],    [],
    [129],  [October 1, 2024],      [7],    [],
    [129],  [September 24, 2024],   [7],    [],
    [129],  [September 17, 2024],   [7],    [27],
    table.hline(stroke: .3mm),
    [128],  [September 10, 2024],   [8],    [],
    [128],  [September 2, 2024],    [5],    [],
    [128],  [August 28, 2024],      [7],    [],
    [128],  [August 21, 2024],      [8],    [29],
    table.hline(stroke: .3mm),
    [127],  [August 13, 2024],      [7],    [],
    [127],  [August 6, 2024],       [7],    [],
    [127],  [July 30, 2024],        [7],    [],
    [127],  [July 23, 2024],        [7],    [],
    table.hline(stroke: .3mm),
    [126],  [July 16, 2024],        [],     [],
    table.hline(stroke: .4mm),
    table.cell(colspan: 2)[#strong[Average:]],  [7.35],  [29.75],
)}

#let firefox_releases = {
table(
  stroke: .1mm,
  align: (left, left, right, right, right),
  columns: (6em, auto, auto, auto, auto),
  table.header(
    strong[Version], strong[Release Date], strong[Days since last release], strong[Days since last major release], strong[Update size]
  ),
  table.hline(stroke: .3mm),
  [133.0],      [November 26, 2024],    [14],   [28],   [17~MB],
  table.hline(stroke: .3mm),
  [132.0.2],    [November 12, 2024],    [8],    [],     [9~MB],
  [132.0.1],    [November 4, 2024],     [6],    [],     [10~MB],
  [132.0],      [October 29, 2024],     [15],   [28],   [20~MB],
  table.hline(stroke: .3mm),
  [131.0.3],    [October 14, 2024],     [5],    [],     [9~MB],
  [131.0.2],    [October 9, 2024],      [8],    [],     [10~MB],
  [131.0],      [October 1, 2024],      [14],   [28],   [14~MB],
  table.hline(stroke: .3mm),
  [130.0.1],    [September 17, 2024],   [14],   [],     [9~MB],
  [130.0],      [September 3, 2024],    [14],   [28],   [18~MB],
  table.hline(stroke: .3mm),
  [129.0.2],    [August 20, 2024],      [7],    [],     [9~MB],
  [129.0.1],    [August 13, 2024],      [7],    [],     [8~MB],
  [129.0],      [August 6, 2024],       [11],   [28],   [16~MB],
  table.hline(stroke: .3mm),
  [128.0.3],    [July 26, 2024],        [3],    [],     [8~MB],
  [128.0.2],    [July 23, 2024],        [14],   [],     [8~MB],
  [128.0],      [July 9, 2024],         [],     [],     [33~MB],
  table.hline(stroke: .4mm),
  table.cell(colspan: 2)[#strong[Average:]], [10],  [28], [13.2~MB],
)}

#let format_num(num, decimal: ".", thousands: ",", precision: 2) = {
  let parts = str(calc.round(num, digits: precision)).split(".")
  let decimal_part = if parts.len() == 2 { parts.at(1) }
  let decimal_part = if decimal_part != none {
    let missing_zeros = precision - decimal_part.len()
    decimal_part + missing_zeros * "0"
  } else {
    precision * "0"
  }
  let integer_part = parts.at(0).rev().clusters().enumerate()
    .map((item) => {
      let (index, value) = item
      return value + if calc.rem(index, 3) == 0 and index != 0 {
        thousands
      }
    }).rev().join("")
  return if precision > 0 {
    integer_part + decimal + decimal_part
  } else {
    integer_part
  }
}

#let update_mechanism_size = {
  show table.cell: it => {
    if it.x == 0 {
      align(left, strong(it))
    } else if it.y == 1 {
      align(center, strong(it))
    } else if it.y == 0 {
      align(center, it)
    } else {
      align(right, it)
    }
  }

  let g = (x) => table.cell([#format_num(x)~kB])
  
  table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr),
  table.header(
    [], table.cell(colspan: 2)[Per update], table.cell(colspan: 2)[Per day],
    [], [150 CAs], [15 CAs], [150 CAs], [15 CAs],
  ),
  [A full update for every fetch],          g(2800),   g(280),    g(11200),  g(1120),
  [Only new tree heads + signature], g(1200),   g(120),   g(4800),   g(480),
  [Only new tree heads],             g(29.40),  g(2.94),  g(117.6),  g(11.76)
)
}

#let pq_signatures = {
  show table.cell: it => {
    if it.y == 0 or it.y == 1{
      align(center + horizon, strong(it))
    } else if it.y == 2 {
      align(center, it)
    } else if it.x == 0 {
      align(left, it)
    } else if it.x == 1 {
      align(center, it)
    } else {
      align(right, it)
    }
  }

  let g = (min, max, current, p: 2, ..additional) => {
    let x = (current - min)/(max - min)
    let text_color = if x > 0.5 {
      white
    } else {
      black
    }
    let content = if additional.pos().len() > 0 {
        additional.pos().at(0) + [#format_num(current, precision: p)]
    } else {
      [#format_num(current, precision: p)]
    }
    table.cell(fill: gradient.linear(..color.map.viridis).sample(100% - x * 100%),  text(fill: text_color, content))
  }

  grid(
    columns: (auto, auto),
    gutter: 1em,
    table(
      columns: 8,
      stroke: 0.3pt,
      table.header(
        [], [], table.cell(colspan: 2)[Sizes (bytes)], table.cell(colspan: 4)[CPU cycles],
        table.cell(rowspan: 2)[Name], table.cell(rowspan: 2)[PQ], table.cell(rowspan: 2)[Public Key], table.cell(rowspan: 2)[Signature], table.cell(colspan: 2)[Signing], table.cell(colspan: 2)[Verification],
        [cycles], [relative], [cycles], [relative],
        ),

        [Ed25519],      [#emoji.crossmark],     g(32, 1312, 32, p: 0),    g(64, 17088, 64, p: 0),       g(46314, 260458611, 46314, p: 0),        g(1, 5623.76, 1),       g(44881, 802701, 158754, p: 0),     g(0.28, 5.06, 1),
        [ECDSA P-256],  [#emoji.crossmark],     g(32, 1312, 32, p: 0),    g(64, 17088, 64, p: 0),       g(46314, 260458611, 108545, p: 0),       g(1, 5623.76, 2.34),    g(44881, 802701, 255095, p: 0),     g(0.28, 5.06, 1.61),
        [RSA-2048],     [#emoji.crossmark],     g(32, 1312, 256, p: 0),   g(64, 17088, 256, p: 0),      g(46314, 260458611, 1850021, p: 0),      g(1, 5623.76, 39.95),   g(44881, 802701, 44881, p: 0),      g(0.28, 5.06, 0.28),
        [ML-DSA-44],    [#emoji.checkmark.box], g(32, 1312, 1312, p: 0),  g(64, 17088, 2420, p: 0),     g(46314, 260458611, 152827, p: 0),       g(1, 5623.76, 3.30),    g(44881, 802701, 68674, p: 0),      g(0.28, 5.06, 0.43),
        [SLH-DSA-128s], [#emoji.checkmark.box], g(32, 1312, 32, p: 0),    g(64, 17088, 7856, p: 0),     g(46314, 260458611, 260458611, p: 0),    g(1, 5623.76, 5623.76), g(44881, 802701, 341835, p: 0),     g(0.28, 5.06, 2.15),
        [SLH-DSA-128f], [#emoji.checkmark.box], g(32, 1312, 32, p: 0),    g(64, 17088, 17088, p: 0),    g(46314, 260458611, 15385413, p: 0),     g(1, 5623.76, 332.20),  g(44881, 802701, 802701, p: 0),     g(0.28, 5.06, 5.06),
        [FN-DSA-512],   [#emoji.checkmark.box], g(32, 1312, 897, p: 0),   g(64, 17088, 666, p: 0),      g(46314, 260458611, 327217, p: 0),       g(1, 5623.76, 7.07, [#box(height: 0.7em, inset: -1pt,  image("images/red-alert-icon.svg")) #h(.3em)]), g(44881, 802701, 62934, p: 0), g(0.28, 5.06, 0.40),
    ),
    align(horizon,
    grid(
      gutter: .5em,
      align: center,
      text(size: .8em)[bad\ performance],
      rect(
        width: 1em,
        height: 8em,
        fill: gradient.linear(
          dir: ttb,
          ..color.map.viridis,
      )),
      text(size: .8em)[good\ performance]
)))
}

#let pq_signatures_slides = {
  show table.cell: it => {
    if it.y == 0 or it.y == 1{
      align(center + horizon, strong(it))
    } else if it.x == 0 {
      align(left, it)
    } else if it.x == 1 {
      align(center, it)
    } else {
      align(right, it)
    }
  }

  let g = (min, max, current, p: 2, ..additional) => {
    let x = (current - min)/(max - min)
    let text_color = if x > 0.5 {
      white
    } else {
      black
    }
    let content = if additional.pos().len() > 0 {
        additional.pos().at(0) + [#format_num(current, precision: p)]
    } else {
      [#format_num(current, precision: p)]
    }
    table.cell(fill: gradient.linear(..color.map.viridis).sample(100% - x * 100%),  text(fill: text_color, content))
  }

  grid(
    columns: (auto, auto),
    gutter: 1em,
    table(
      columns: 6,
      stroke: 0.3pt,
      table.header(
        [], [], table.cell(colspan: 2)[Sizes (bytes)], table.cell(colspan: 2)[CPU cycles],
        [Name], [PQ], [Public Key], [Signature], [Signing], [Verification],
        ),

        [Ed25519],      [#emoji.crossmark],     g(32, 1312, 32, p: 0),    g(64, 17088, 64, p: 0),      g(1, 5623.76, 1),       g(0.28, 5.06, 1),
        [ECDSA P-256],  [#emoji.crossmark],     g(32, 1312, 32, p: 0),    g(64, 17088, 64, p: 0),      g(1, 5623.76, 2.34),    g(0.28, 5.06, 1.61),
        [RSA-2048],     [#emoji.crossmark],     g(32, 1312, 256, p: 0),   g(64, 17088, 256, p: 0),     g(1, 5623.76, 39.95),   g(0.28, 5.06, 0.28),
        [ML-DSA-44],    [#emoji.checkmark.box], g(32, 1312, 1312, p: 0),  g(64, 17088, 2420, p: 0),    g(1, 5623.76, 3.30),    g(0.28, 5.06, 0.43),
        [SLH-DSA-128s], [#emoji.checkmark.box], g(32, 1312, 32, p: 0),    g(64, 17088, 7856, p: 0),    g(1, 5623.76, 5623.76), g(0.28, 5.06, 2.15),
        [SLH-DSA-128f], [#emoji.checkmark.box], g(32, 1312, 32, p: 0),    g(64, 17088, 17088, p: 0),   g(1, 5623.76, 332.20),  g(0.28, 5.06, 5.06),
        [FN-DSA-512],   [#emoji.checkmark.box], g(32, 1312, 897, p: 0),   g(64, 17088, 666, p: 0),     g(1, 5623.76, 7.07, [#box(height: 0.7em, inset: -1pt,  image("images/red-alert-icon.svg")) #h(.3em)]), g(0.28, 5.06, 0.40),
    ),
    align(horizon,
    grid(
      gutter: .5em,
      align: center,
      text(size: .8em)[bad\ performance],
      rect(
        width: 1em,
        height: 8em,
        fill: gradient.linear(
          dir: ttb,
          ..color.map.viridis,
      )),
      text(size: .8em)[good\ performance]
)))
}

#let mtc_cpu_cycles = {
  show table.cell: it => {
    if it.y == 0 or it.x == 2 {
      strong(it)
    } else {
      it
    }
  }

  let f = (x) => table.cell(format_num(x, precision: 0))
  
table(
    columns: 4,

    fill: (x, y) => {
      if calc.even(y) and y > 0 {
        gray.lighten(40%)
      }
    },

    align: (x, y) => {
      if calc.even(y) and y > 0 and x != 3 {
        right
      } else if y > 0 and x != 3 {
        left
      } else {
        center
      }
    },

    table.header(
      [Handshake signature], [Tree Traversal],  [$sum$], [PQ],
    ),

    [ECDSA-256],    [280M active APs],   [],         [],
    f(255095),      f(35734),      f(290829), [#emoji.crossmark],

    [RSA-2048],     [2B active APs],    [],         [],
    f(44881),       f(38337),      f(83218),  [#emoji.crossmark],

    [ML-DSA-44],    [280M active APs],  [],         [],
    f(68674),       f(35734),       f(104408),  [#emoji.checkmark.box],

    [ML-DSA-44],    [2B active APs],    [],         [],
    f(68674),       f(38337),      f(107011),  [#emoji.checkmark.box],
)
}

#let x509_cpu_cycles = {
  show table.cell: it => {
    if it.y == 0 or it.y == 1 or it.x == 4 {
      strong(it)
    } else {
      it
    }
  }

  let f = (x) => table.cell(format_num(x, precision: 0))
  
table(
    columns: 6,

    fill: (x, y) => {
      if calc.odd(y) and y > 1 {
        gray.lighten(40%)
      }
    },

    align: (x, y) => {
      if calc.odd(y) and y > 1 and x != 5 {
        right
      } else if y > 1 and x != 5 {
        left
      } else {
        center
      }
    },

    table.header(
      table.cell(colspan: 4)[Signatures],             [$sum$], [PQ],
      [Handshake],[SCT + OCSP], [EE], [Intermediate],                [], []
    ),

    [ECDSA-256],    [ECDSA-256],    [ECDSA-256],    [ECDSA-256],    [],         [],
    f(255095),      f(765285),      f(255095),      f(255095),      f(1530570), [#emoji.crossmark],

    [RSA-2048],     [ECDSA-256],    [RSA-2048],     [RSA-4096],     [],         [],
    f(44881),       f(765285),      f(44881),       f(120280),      f(975327),  [#emoji.crossmark],

    [ML-DSA-44],    [ML-DSA-44],    [ML-DSA-44],    [ML-DSA-44],    [],         [],
    f(68674),       f(206022),      f(68674),       f(68674),       f(412044),  [#emoji.checkmark.box],

    [ML-DSA-44],    [ML-DSA-44],    [ML-DSA-44],    [SLH-DSA-128s], [],         [],
    f(68674),       f(206022),      f(68674),       f(341835),      f(685205),  [#emoji.checkmark.box],
)
}

#let x509_certificate_sizes(kem: true) = {
  
  show table.cell: it => {
    if it.y == 0 or it.y == 1 or it.x == 6 {
      strong(it)
    } else {
      it
    }
  }
  
  table(
    columns: 8,
    
    fill: (x, y) => {
      if calc.odd(y) and y > 1 {
        gray.lighten(40%)
      }
    },

    align: (x, y) => {
      if calc.odd(y) and y > 1 and x != 7{
        right
      } else if y > 1 and x != 7{
        left
      } else {
        center
      }
    },

    table.header(
      table.cell(colspan: 4)[Signatures],             table.cell(colspan: 2)[Public Keys],  [$sum$], [PQ],
      [Handshake],[SCT + OCSP], [EE], [Intermediate], [EE], [Intermediate],                 [], []
    ),
    
    [ECDSA-256],  [ECDSA-256],  [ECDSA-256],  [ECDSA-256],  [ECDSA-256],  [ECDSA-256],  [],               [],
    [64],     [192],    [64],     [64],     [32],     [32],     [448],            [#emoji.crossmark],
    
    [RSA-2048], [ECDSA-256],  [RSA-2048], [RSA-4096], [RSA-2048], [RSA-2048], [],       [],
    [256],      [192],    [256],      [512],      [256],      [256],      [1,728],  [#emoji.crossmark],
    
    [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [],               [],
    [2,420],  [7,260],  [2,420],  [2,420],  [1,312],  [1,312],  [17,144],         [#emoji.checkmark.box],
    
    [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [SLH-DSA-128s], [ML-DSA-44], [ML-DSA-44], [],         [],
    [2,420],  [7,260],  [2,420],  [7,856],        [1,312],  [1,312],  [22,580],   [#emoji.checkmark.box],

    ..if kem {(
    y[ML-KEM-768], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44],  y[ML-KEM-768],  [ML-DSA-44], [],           [],
     [1,088],  [7,260],  [2,420],  [2,420],   [1,184],    [1,312],  [15,684],     [#emoji.checkmark.box],
    )},
  )
}

#let bikeshed_certificate_sizes(kem: true) = {
  show table.cell: it => {
    if it.y == 0 or it.x == 3 {
      strong(it)
    } else {
      it
    }
  }

  table(
    columns: 5,
    align: (x, y) => {
      if calc.even(y) and y > 0 and x != 4{
        right
      } else if y > 0  and x != 4{
        left
      } else {
        center
      }
    },
    
    fill: (x, y) => {
      if calc.even(y) and y > 0 {
        gray.lighten(40%)
      }
    },
    
    table.header([Handshake], [Public Key], [Proof Length], [$sum$], [PQ]),

    [ECDSA],  [ECDSA],  [280M active APs],  [], [],
    [64],     [32],     [672],            [768], [#emoji.crossmark],
        
    [RSA-2048],  [RSA-2048],  [2B active APs],  [], [],
    [256],     [256],     [736],            [1,238], [#emoji.crossmark],
    
    [ML-DSA-44], [ML-DSA-44], [280M active APs],  [], [],
    [2,420],  [1,312],  [672],            [4,404], [#emoji.checkmark.box],
    
    [ML-DSA-44], [ML-DSA-44], [2B active APs],  [], [],
    [2,420],  [1,312],  [736],            [4,468], [#emoji.checkmark.box],

    ..if kem {(
    y[ML-KEM-768], y[ML-KEM-768], [280M active APs],  [], [],
    [1,088],    [1,184],  [672],            [2,944], [#emoji.checkmark.box],
    )},

    ..if kem {(
    y[ML-KEM-768], y[ML-KEM-768], [2B active APs],  [], [],
    [1,088],    [1,184],  [736],            [3,008], [#emoji.checkmark.box],
    )},
  )
}

#let x509_size_short = {
  show table.cell: it => {
    strong(it)
  }
  
  figure(
      table(
        columns: 2,
        
        fill: (x, y) => {
          if calc.odd(y) {
            gray.lighten(40%)
          }
        },
    
        align: (x, y) => {
          if x == 0 and y > 0 {
            right
          } else {
            center
          }
        },
    
        table.header(
          [$sum$], [PQ],
        ),
        [448 bytes],      [#emoji.crossmark],
        [1,728 bytes],    [#emoji.crossmark],
        [17,144 bytes],   [#emoji.checkmark.box],
        [22,580 bytes],   [#emoji.checkmark.box],
      ),
    caption: [X.509])
}

#let bikeshed_x509_size_comp = {
  show table.cell: it => {
    strong(it)
  }

  grid(
    columns: 2,
    gutter: 3em,
    x509_size_short,
  
    figure(
        table(
        columns: 2,
        
        fill: (x, y) => {
          if calc.odd(y) {
            gray.lighten(40%)
          }
        },
    
        align: (x, y) => {
          if x == 0 and y > 0{
            right
          } else {
            center
          }
        },
    
        table.header(
          [$sum$], [PQ],
        ),
    
        [768 bytes],    [#emoji.crossmark],
        [1,238 bytes],    [#emoji.crossmark],
        [4,404 bytes],  [#emoji.checkmark.box],
        [4,468 bytes],  [#emoji.checkmark.box],
      ),
      caption: [MTC]
    )
  )
}

#let x509_certificates_top_10 = {
  show table.cell: it => {
    if it.y == 0 {
      strong(it)
    } else {
      it
    }
  }
    table(
      columns: 6,
  
      table.header(
        [Domain], [Handshake], [SCT], [EE], [Intermediate], [SHA-256 fingerprint],
      ),
      
      [gooogle.com], [256-bit ECDSA],  [2x 256-bit ECDSA],  [RSA-2048],  [RSA-4096],
      [`37:9A:80:C9:25:2C:66:A1:BB:89:D6:C0:C8:83:33:39: 55:1D:E6:0F:D3:75:58:5C:F9:A3:18:37:03:57:A0:D6`],
      
      [apple.com], [RSA-2048], [4x 256-bit ECDSA], [RSA-2048], [RSA-2048],
      [`8B:29:CD:F1:D9:4E:D6:19:13:19:BF:47:AB:05:20:16: 8D:0D:21:D5:80:3E:5E:CA:A2:FE:40:A7:BA:BE:1B:AD`],
      
      [facebook.com], [256-bit ECDSA], [3x 256-bit ECDSA], [RSA-2048],  [RSA-2048],
      [`AA:52:70:47:1F:CB:25:A5:47:0D:2F:04:21:52:23:2A: 80:7C:EE:D5:C0:D0:F8:41:54:B4:C3:C7:EF:FA:84:B4`],
      
      [microsoft.com], [RSA-2048], [3x 256-bit ECDSA], [RSA-4096], [RSA-2048],
      [`5E:7E:E1:BF:7B:02:DE:64:07:57:84:02:E6:8F:30:E4: 07:4A:4C:68:04:DA:E9:B7:12:50:70:E2:6E:A5:6B:F0`],
  
      [cloudflare.com], [256-bit ECDSA], [2x 256-bit ECDSA], [256-bit ECDSA], [384-bit ECDSA], 
      [`5A:18:79:DD:30:77:B1:51:E6:96:E2:BA:6D:D6:9F:E2: 77:EB:2E:BE:D6:82:D2:00:1E:A2:05:DB:94:A1:09:FA`]
    )
}