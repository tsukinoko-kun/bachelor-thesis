Demos sind im Gaming-Markt eine relevante Möglichkeit,
Spieler vom Kauf eines Videospiels zu überzeugen. @steamdb-2025-stellar-blade-charts
Diese Arbeit beschäftigt sich mit der Möglichkeit,
Demos von Videospielen mit der modernen Technologie der Cloud-Gaming zu verbinden.

Sowohl Demos, als auch Cloud-Gaming stehen für Zugänglichkeit.
Beide haben aber unterschiedliche Ziele.
Demos sind Marketing und wollen etwas verkaufen.
Cloud-Gaming ist ein Produkt, das unabhängig von Videospielen verkauft wird.
In dieser Arbeit wird also untersucht, ob sich diese Ziele zusammenführen lassen.

= Forschungsfragen

Den Ausgangspunkt dieser Arbeit bildet die Untersuchung der konzeptionellen und technischen Machbarkeit einer spezialisierten Cloud-Gaming-Plattform für Spieledemos. Aus dieser übergreifenden Zielsetzung leitet sich die folgende Hauptforschungsfrage (HFF) ab:

#box(width: 100%, inset: 8pt, stroke: 1pt)[
  *HFF: Wie muss eine Cloud-Gaming-Plattform architektonisch und technologisch konzipiert sein, um High-End-Spieledemos performant auf Low-End-Geräten bereitzustellen, und welche Implikationen ergeben sich daraus für Nutzer sowie Betreiber?*
]

Zur systematischen Beantwortung dieser Frage wird die Untersuchung in die folgenden untergeordneten Forschungsfragen (UFF) gegliedert:

- *UFF 1: Welche Architekturmuster und Systemkomponenten eignen sich, um eine auf die Bereitstellung von Spieledemos für leistungsschwache Endgeräte spezialisierte Cloud-Gaming-Plattform zu realisieren?*
- *UFF 2: Wie lässt sich durch die Kombination spezifischer Streaming-Protokolle, Codecs und Infrastrukturtechnologien eine geringe Latenz bei gleichzeitig hoher visueller Qualität für die Übertragung von Spieledemos sicherstellen?*
- *UFF 3: Worin besteht der Mehrwert einer solchen Plattform für Endnutzer im Vergleich zu traditionellen Download-Demos, und welche technischen sowie nutzerzentrierten Hürden könnten einer breiten Akzeptanz entgegenstehen?*
- *UFF 4: Welche Geschäftsmodelle erscheinen für den Betrieb einer Cloud-Gaming-Plattform für Spieledemos tragfähig, und welche strategischen Vorteile könnten sich daraus für Spieleentwickler und Publisher ergeben?*

== Hypothesen

Ausgehend von einer ersten Einschätzung der Problemstellung und vor Beginn der systematischen Recherche wurden die folgenden Arbeitshypothesen formuliert. Diese dienten als anfängliche Leitlinien für die Untersuchung und wurden im Verlauf der Arbeit kritisch geprüft.

- Eine monolithische Architektur, bei der mehrere Spielinstanzen auf einem einzelnen, leistungsstarken Server betrieben werden, stellt eine ausreichende und einfach zu verwaltende Lösung dar.
- Das etablierte Protokoll WebRTC eignet sich aufgrund seiner weiten Verbreitung und der Fokussierung auf Echtzeitkommunikation gut für das Streaming der Spieledemos mit geringer Latenz.
- Der Hauptvorteil für Nutzer liegt in der Eliminierung von Wartezeiten durch Downloads und der Unabhängigkeit von Hardwareanforderungen. Eine Hürde könnte jedoch die Notwendigkeit zur Installation zusätzlicher Software oder zur Erstellung eines Benutzerkontos sein.
- Ein tragfähiges Geschäftsmodell muss auf einer kostenlosen Bereitstellung der Demos für Endnutzer basieren. Die Wirtschaftlichkeit der Plattform hängt somit maßgeblich von der Konversionsrate ab und könnte aus Betreibersicht als kostenintensive Marketingmaßnahme ohne direkten Profit betrachtet werden.
- Die Akzeptanz und Nutzungshäufigkeit von Cloud-Gaming-Demos wird sich nicht signifikant von der etablierter, lokal installierter Demos unterscheiden.
