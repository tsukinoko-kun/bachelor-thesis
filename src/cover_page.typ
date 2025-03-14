#set page(
  margin: (x: 2.5cm, y: 2.5cm),
  numbering: none,
)

#set text(size: 11pt)

#align(center)[
  #box(width: 8cm)[
    #image("img/hhn.jpg", width: 100%)
  ]

  #v(2cm)

  #text(size: 14pt, weight: "regular")[BACHELOR THESIS]

  #v(0.8cm)

  #text(size: 22pt, weight: "bold")[
    Development of a Self-Hostable
    #linebreak()
    Cloud Gaming Solution
  ]

  #v(1.5cm)

  #grid(
    columns: 1fr,
    rows: (auto, auto),
    gutter: 0.8cm,
    text(size: 13pt)[
      *Submitted in Partial Fulfillment of the Requirements for the Degree of*
      #linebreak()
      *Bachelor of Science in Software Engineering*
    ],

    text(size: 13pt)[
      *Hochschule Heilbronn*
      #linebreak()
      *University of Applied Sciences*
      #linebreak()
      *Fakultät IT*
    ]
  )

  #v(2cm)

  #grid(
    columns: (auto, auto),
    rows: (auto, auto, auto, auto),
    column-gutter: 0.5cm,
    row-gutter: 0.8cm,
    align: left,
    text(weight: "medium")[Author:], text()[Frank Mayer],
    text(weight: "medium")[Matrikelnummer:], text()[215965],
    text(weight: "medium")[Betreuung:], text()[Prof. Dr. Thomas Fankhauser],
    [], text()[Prof. Dr. rer. nat. Nicole Ondrusch],
    text(weight: "medium")[Abgabedatum:],
    text()[#datetime.today().display("[day].[month].[year]")],
  )
]
