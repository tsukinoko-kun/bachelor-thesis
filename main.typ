#include "src/cover_page.typ"

// Start the rest of your document on a new page
#pagebreak()

#emph(text(weight: "bold")[Abstract -])
#text(weight: "bold")[#include "src/abstract.typ"]

#include "src/001_introduction.typ"

#bibliography("refs.bib")
