#include "src/cover_page.typ"

// Start the rest of your document on a new page
#pagebreak()

#counter(page).update(1)

#let paper-size = "a4"

#set text(font: "TeX Gyre Termes", size: 10pt, spacing: .35em)
#set enum(numbering: "1)a)i)")

#show figure: set block(spacing: 15.5pt)
#show figure: set place(clearance: 15.5pt)
#show figure.where(kind: table): set figure.caption(
  position: top,
  separator: [\ ],
)
#show figure.where(kind: table): set text(size: 8pt)
#show figure.where(kind: table): set figure(numbering: "I")
#show figure.where(kind: image): set figure(supplement: "Fig.", numbering: "1")
#show figure.caption: set text(size: 8pt)
#show figure.caption: set align(start)
#show figure.caption.where(kind: table): set align(center)

#set figure.caption(separator: [. ])
#show figure: fig => {
  let prefix = (
    if fig.kind == table [TABLE] else if fig.kind
      == image [Fig.] else [#fig.supplement]
  )
  let numbers = numbering(fig.numbering, ..fig.counter.at(fig.location()))
  // Wrap figure captions in block to prevent the creation of paragraphs. In
  // particular, this means `par.first-line-indent` does not apply.
  // See https://github.com/typst/templates/pull/73#discussion_r2112947947.
  show figure.caption: it => block[#prefix~#numbers#it.separator#it.body]
  show figure.caption.where(kind: table): smallcaps
  fig
}

// Code blocks
#show raw: set text(
  font: "TeX Gyre Cursor",
  ligatures: false,
  size: 1em / 0.8,
  spacing: 100%,
)

// Configure the page and multi-column properties.
#set columns(gutter: 12pt)
#set page(
  columns: 2,
  paper: paper-size,
  numbering: "1",
  number-align: center,
  // The margins depend on the paper size.
  margin: if paper-size == "a4" {
    (x: 41.5pt, top: 80.51pt, bottom: 89.51pt)
  } else {
    (
      x: (50pt / 216mm) * 100%,
      top: (55pt / 279mm) * 100%,
      bottom: (64pt / 279mm) * 100%,
    )
  },
)

// Configure equation numbering and spacing.
#set math.equation(numbering: "(1)")
#show math.equation: set block(spacing: 0.65em)

// Configure appearance of equation references
#show ref: it => {
  if it.element != none and it.element.func() == math.equation {
    // Override equation references.
    link(it.element.location(), numbering(
      it.element.numbering,
      ..counter(
        math.equation,
      ).at(it.element.location()),
    ))
  } else {
    // Other references as usual.
    it
  }
}

// Configure lists.
#set enum(indent: 10pt, body-indent: 9pt)
#set list(indent: 10pt, body-indent: 9pt)

// Configure headings.
#set heading(numbering: "I.A.a)")
#show heading: it => {
  // Find out the final number of the heading counter.
  let levels = counter(heading).get()
  let deepest = if levels != () {
    levels.last()
  } else {
    1
  }

  set text(10pt, weight: 400)
  if it.level == 1 {
    // First-level headings are centered smallcaps.
    // We don't want to number the acknowledgment section.
    let is-ack = (
      it.body
        in (
          [Acknowledgment],
          [Acknowledgement],
          [Acknowledgments],
          [Acknowledgements],
          [Danksagung],
          [Danksagungen],
          [Declaration of Authenticity],
          [Declaration of Oath],
          [Eidesstattliche Erklärung],
        )
    )
    set align(center)
    set text(if is-ack { 10pt } else { 11pt })
    show: block.with(above: 15pt, below: 13.75pt, sticky: true)
    show: smallcaps
    if it.numbering != none and not is-ack {
      numbering("I.", deepest)
      h(7pt, weak: true)
    }
    it.body
  } else if it.level == 2 {
    // Second-level headings are run-ins.
    set text(style: "italic")
    show: block.with(spacing: 10pt, sticky: true)
    if it.numbering != none {
      numbering("A.", deepest)
      h(7pt, weak: true)
    }
    it.body
  } else [
    // Third level headings are run-ins too, but different.
    #if it.level == 3 {
      numbering("a)", deepest)
      [ ]
    }
    _#(it.body):_
  ]
}

// Style bibliography.
#show std.bibliography: set text(8pt)
#show std.bibliography: set block(spacing: 0.5em)
#set std.bibliography(title: text(10pt)[Verweise], style: "ieee")

#emph(text(weight: "bold")[Abstract -])
#text(weight: "bold")[#include "src/abstract.typ"]

#include "./src/000_naming.typ"
#include "./src/001_questions.typ"
#include "./src/002_methods.typ"
#include "./src/003_target_group.typ"
#include "./src/004_core_challenges.typ"
#include "./src/005_current_technologies.typ"
#include "./src/006_base_technologies.typ"
#include "./src/007_architecture.typ"
#include "./src/008_implementing_stream_service.typ"
#include "./src/009_proof_of_concept.typ"
#include "./src/010_costs.typ"
#include "./src/011_acceptance.typ"
#include "./src/012_discussion.typ"
#bibliography("refs.yaml")
#include "src/danksagung.typ"
#include "src/eidesstattliche-erklaerung.typ"
