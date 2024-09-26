#set page("a4")


#import "imports.typ": *
#import "style/radboud_cover.typ": title_page
#import "style/ru_template.typ": report, appendix
#import "style/todo.typ": outline-todos


#title_page(
  title: [Master Thesis],
  subtitle: [Something with PQ TLS],
  author: [Maximilian Pohl],
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

#outline-todos()

// #outline(indent: true, title: "Content")

#show: make-glossary
#show: doc => report(table_of_contents: true, doc)

#include "1_introduction.typ"
// #word-count(total => [
#include "2_preliminaries.typ"
// #total.words words in total])
#include "3_mtc.typ"
#include "4_contributions.typ"


#show: appendix
#include "A_abbreviations.typ"

= Bibliography
#bibliography("references.bib", title: none)