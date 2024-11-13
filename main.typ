#set page("a4")


#import "imports.typ": *
#import "style/radboud_cover.typ": title_page
#import "style/ru_template.typ": report, appendix
#import "style/todo.typ": outline-todos
#import "A_abbreviations.typ": abbreviations

#let title = "Master Thesis"
#let subtitle = "Something with PQ TLS"
#let author = "Maximilian Pohl"


#title_page(
  title: title,
  subtitle: subtitle,
  author: author,
  others: ((
    function: "Supervisor",
    name: "dr. it. Bart Mennink",
  ),
  (
    function: "Second Reader",
    name: "TBD",
  ),
  (
    function: "Daily Supervisor",
    name: "Marlon Baeten",
  )),
)

#set document(title: [#title - #subtitle], author: author)

// #outline-todos()

#show: make-glossary
#show: doc => report(table_of_contents: true, doc)

#register-glossary(abbreviations)

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