#set page("a4")


#import "imports.typ": *
#import "style/radboud_cover.typ": *
#import "style/ru_template.typ": report, appendix
#import "style/todo.typ": outline-todos
#import "A_abbreviations.typ": abbreviations

// Possible titles:
// Implementation and Analysis of Merkle Tree Certificates for Post-Quantum Secure TLS
// ...

#let title = "Master Thesis"
#let subtitle = "Implementation and Analysis of Merkle Tree Certificates for Post-Quantum Secure authentication in TLS"
#let author = "Maximilian Pohl"


#title_page(
  title: title,
  subtitle: subtitle,
  author: author,
  others: ((
    function: "Supervisor",
    name: "dr. ir. Bart Mennink",
  ),
  (
    function: "Second Reader",
    name: "prof. dr. Peter Schwabe",
  ),
  (
    function: "Daily Supervisor",
    name: "Marlon Baeten M.Sc.",
  )),
)

#set document(title: [#title - #subtitle], author: author)

#show: make-glossary
#register-glossary(abbreviations)

#show: doc => report(
  doc, 
  table_of_contents: true,
  print: false,
  abstract: [
    // #word-count(total => [
    #include "0_abstract.typ"
    // #total.words words in total])
  ]
)

// #word-count(total => [
#include "1_introduction.typ"
// #total.words words in total])
#include "2_preliminaries.typ"
#include "3_mtc.typ"
#include "4_comparison.typ"
#include "5_contributions.typ"
#include "6_conclusion.typ"



#show: appendix
#include "A_abbreviations.typ"
#include "B_appendix.typ"

= Bibliography
#bibliography("references.bib", title: none)