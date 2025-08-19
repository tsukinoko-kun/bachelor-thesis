= Akzeptanz

Nachdem die technische Machbarkeit und die wirtschaftlichen Rahmenbedingungen der Plattform analysiert wurden, widmet sich dieses Kapitel der Nutzerakzeptanz. Eine hohe Akzeptanz ist entscheidend für den Erfolg des Konzepts, da eine als unzureichend empfundene technische Qualität potenzielle Käufer eher abschrecken als überzeugen würde. Im Mittelpunkt der Untersuchung steht daher die Frage, wie sich die durch das Streaming bedingten Kompromisse bei Latenz und Bildqualität auf das subjektive Spielerlebnis auswirken.

== Latenz als kritischer Faktor

Die Ende-zu-Ende-Latenz ist einer der wichtigsten Parameter für die Qualität eines Cloud-Gaming-Dienstes. Um eine realistische Grundlage für die Akzeptanztests zu schaffen, wurde zunächst die Netzwerklatenz zwischen einem typischen Nutzerstandort (Heilbronn) und dem anvisierten AWS-Rechenzentrum in Frankfurt (`eu-central-1`) gemessen.

```shell
$ ping -c 20 ec2.eu-central-1.amazonaws.com
64 bytes from 52.94.137.27: icmp_seq=0 ttl=243 time=14.198 ms
64 bytes from 52.94.137.27: icmp_seq=1 ttl=243 time=13.348 ms
64 bytes from 52.94.137.27: icmp_seq=2 ttl=243 time=16.855 ms
64 bytes from 52.94.137.27: icmp_seq=3 ttl=243 time=13.408 ms
64 bytes from 52.94.137.27: icmp_seq=4 ttl=243 time=16.714 ms
64 bytes from 52.94.137.27: icmp_seq=5 ttl=243 time=16.627 ms
64 bytes from 52.94.137.27: icmp_seq=6 ttl=243 time=18.547 ms
64 bytes from 52.94.137.27: icmp_seq=7 ttl=243 time=16.562 ms
64 bytes from 52.94.137.27: icmp_seq=8 ttl=243 time=16.681 ms
64 bytes from 52.94.137.27: icmp_seq=9 ttl=243 time=13.874 ms
64 bytes from 52.94.137.27: icmp_seq=10 ttl=243 time=13.389 ms
64 bytes from 52.94.137.27: icmp_seq=11 ttl=243 time=14.309 ms
64 bytes from 52.94.137.27: icmp_seq=12 ttl=243 time=13.560 ms
64 bytes from 52.94.137.27: icmp_seq=13 ttl=243 time=14.392 ms
64 bytes from 52.94.137.27: icmp_seq=14 ttl=243 time=14.096 ms
64 bytes from 52.94.137.27: icmp_seq=15 ttl=243 time=14.071 ms
64 bytes from 52.94.137.27: icmp_seq=16 ttl=243 time=13.314 ms
64 bytes from 52.94.137.27: icmp_seq=17 ttl=243 time=17.408 ms
64 bytes from 52.94.137.27: icmp_seq=18 ttl=243 time=16.579 ms
64 bytes from 52.94.137.27: icmp_seq=19 ttl=243 time=16.652 ms
```

Die Messung ergibt eine mediane Round-Trip-Time (RTT) von 14.4 ms und einen Durchschnittswert von 15.2 ms. Unter der Annahme, dass die Datenrate des Streams von rund $13 frac("Mbit", "s")$ die Router-Puffer nicht signifikant belastet, kann von einer stabilen Netzwerklatenz ausgegangen werden. Für den nachfolgenden Test wird daher eine RTT von ca. 30 ms als realistische, leicht konservative Annahme für die Verbindung zwischen Client und Server zugrunde gelegt.

== Studiendesign und Durchführung

Um die Nutzerakzeptanz unter kontrollierten Bedingungen zu evaluieren, wurde ein verblindeter Test mit 10 Teilnehmenden durchgeführt. Jede Person spielte zwei dreiminütige Abschnitte des Spiels _Cyberpunk 2077_. Die Reihenfolge der beiden Testbedingungen war dabei zufällig:

1. *Lokales Spielerlebnis:* Das Spiel lief direkt auf einem leistungsstarken Host-Rechner (MacBook Pro M4 Max).
2. *Streaming-Erlebnis:* Das Spiel lief auf demselben Host-Rechner, wurde aber mittels des im Proof of Concept entwickelten Dienstes auf einen leistungsschwächeren Client-Laptop (AMD Ryzen 5 5500U) gestreamt.

Um die zuvor ermittelte Netzwerklatenz zu simulieren, wurde die Verbindung zwischen Host und Client mithilfe eines Network Link Conditioners @network-link-conditioner künstlich auf eine RTT von 30 ms gedrosselt. Die Teilnehmenden wussten nicht, welche der beiden Bedingungen gerade aktiv war. Ein KVM-Switch ermöglichte einen nahtlosen Wechsel zwischen den Systemen, wobei dieselben Peripheriegeräte (Maus, Tastatur, Monitor) verwendet wurden.

Nach jedem der beiden Abschnitte wurden die Teilnehmenden gebeten, ihre Erfahrung anhand einer Fünf-Punkte-Likert-Skala zu bewerten. Erhoben wurden die Kaufwahrscheinlichkeit, die Störung durch Eingabeverzögerung, die wahrgenommene Bildqualität und der allgemeine Spielspaß. Als objektive Leistungskennzahl wurde die Anzahl der besiegten Gegner erfasst.

== Auswertung der Ergebnisse

Die erhobenen Daten wurden mittels Boxplots visualisiert, um die Verteilung der Bewertungen für das lokale (links) und das gestreamte (rechts) Spielerlebnis zu vergleichen.

#import "@preview/lilaq:0.4.0" as lq

#figure(
  lq.diagram(
    lq.boxplot(
      (9, 8, 7, 11, 5, 10, 5, 12, 8, 8),
    ),
    lq.boxplot(
      (6, 5, 9, 8, 9, 11, 8, 9, 7, 6),
      x: 2,
    ),
  ),
  caption: "Besiegte Gegner (höher = besser)",
)

Die objektive Leistung, gemessen an der Anzahl besiegter Gegner, scheint beim Streaming leicht geringer auszufallen. Der Median der besiegten Gegner ist im Streaming-Szenario niedriger, was auf eine mögliche Beeinträchtigung der Reaktionsfähigkeit durch die Latenz hindeuten könnte.

#figure(
  lq.diagram(
    lq.boxplot(
      (5, 4, 4, 5, 3, 5, 3, 5, 2, 4),
    ),
    lq.boxplot(
      (4, 3, 5, 4, 4, 4, 1, 4, 5, 5),
      x: 2,
    ),
  ),
  caption: "Kaufwahrscheinlichkeit (höher = besser, Skala 1-5)",
)

Unerwarteterweise zeigt sich bei der Kaufwahrscheinlichkeit kein klarer Nachteil für das Streaming. Die Mediane beider Gruppen liegen auf demselben Niveau. Dieses Ergebnis sollte jedoch aufgrund der geringen Stichprobengröße mit Vorsicht interpretiert werden.

#figure(
  lq.diagram(
    lq.boxplot(
      (1, 1, 1, 1, 2, 1, 1, 1, 2, 1),
    ),
    lq.boxplot(
      (2, 2, 3, 2, 2, 2, 2, 4, 3, 2),
      x: 2,
    ),
  ),
  caption: "Einschätzung Eingabeverzögerung (höher = schlechter, Skala 1-5)",
)

Wie zu erwarten war, wurde die Eingabeverzögerung beim Streaming als störender empfunden. Der Median der Bewertung liegt hier bei 2, während er beim lokalen Spielen bei 1 liegt, was einer kaum wahrnehmbaren Latenz entspricht.

#figure(
  lq.diagram(
    lq.boxplot(
      (5, 5, 5, 5, 5, 5, 5, 4, 5, 5),
    ),
    lq.boxplot(
      (5, 4, 4, 5, 4, 5, 4, 5, 4, 4),
      x: 2,
    ),
  ),
  caption: "Einschätzung Bildqualität (höher = besser, Skala 1-5)",
)

Auch die Bildqualität wurde beim Streaming erwartungsgemäß etwas schlechter bewertet. Die durch die Videokompression entstehenden Artefakte und die geringere Schärfe führen zu einem niedrigeren Medianwert (4) im Vergleich zum lokalen Spielerlebnis (5).

#figure(
  lq.diagram(
    lq.boxplot(
      (5, 4, 4, 5, 3, 5, 4, 5, 5, 4),
    ),
    lq.boxplot(
      (4, 2, 3, 4, 5, 5, 5, 4, 5, 4),
      x: 2,
    ),
  ),
  caption: "Spielspaß (höher = besser, Skala 1-5)",
)

Trotz der messbaren technischen Nachteile scheint der subjektive Spielspaß kaum beeinträchtigt zu werden. Die Mediane beider Gruppen liegen sehr nahe beieinander, was darauf hindeutet, dass die negativen Effekte nicht ausreichten, um das grundlegende Vergnügen am Spiel signifikant zu schmälern.

#figure(
  lq.diagram(
    xaxis: (
      ticks: ("Lokal", "Stream")
        .map(rotate.with(-45deg, reflow: true))
        .map(align.with(right))
        .enumerate(),
      subticks: none,
    ),
    lq.bar(
      range(2),
      (8, 9),
    ),
  ),
  caption: "Anzahl der Testpersonen, die weiterspielen würden",
)

Dieses Bild bestätigt sich bei der Frage, ob die Teilnehmenden nach dem Abschnitt weiterspielen würden. In beiden Gruppen war die Bereitschaft hierzu sehr hoch und nahezu identisch.

== Interpretation und Fazit

Die Ergebnisse des Akzeptanztests zeichnen ein differenziertes Bild. Einerseits führt die Streaming-Lösung zu objektiv messbaren und subjektiv wahrgenommenen Einbußen bei der Leistung, der Eingabeverzögerung und der Bildqualität. Diese Nachteile waren aufgrund der technischen Gegebenheiten zu erwarten.

Andererseits deuten die zentralen Metriken für die Nutzererfahrung (der Spielspaß und die Bereitschaft, weiterzuspielen) darauf hin, dass diese Einbußen das Gesamterlebnis nicht entscheidend beeinträchtigen. Für den Anwendungsfall einer kurzen Spieledemo scheint die erreichte Qualität "gut genug" zu sein, um einen positiven Eindruck des Spiels zu vermitteln.

Das unerwartete Ergebnis bei der Kaufwahrscheinlichkeit lässt sich angesichts der geringen Teilnehmerzahl und der zufälligen Elemente im Spielgeschehen am ehesten als statistisches Rauschen interpretieren und besitzt keine Aussagekraft.

Zusammenfassend lässt sich festhalten, dass die entwickelte Streaming-Lösung eine hohe Nutzerakzeptanz erwarten lässt. Die Vorteile des sofortigen Zugangs ohne Download und Installation scheinen die leichten technischen Kompromisse für die Dauer einer Demo-Session aufzuwiegen. Dies stützt die Hypothese, dass eine solche Plattform einen echten Mehrwert für Spieler bieten kann.
