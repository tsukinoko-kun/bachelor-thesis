= Akzeptanz

== Latenz

Die gemessene Latenz von Heilbronn zum AWS-Rechenzentrum in Frankfurt (EU Central 1) beträgt:

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

- Median: 14.392 ms
- Durchschnitt: 15.229 ms
- Standardabweichung: 1.644 ms

Die Datenrate von etwa $13 frac("Mbit", "s")$ liegt weit unter der maximalen Link‑Kapazität und sollte keine Router‑Puffer füllen. Daher ist zu erwarten, dass die RTT nicht von der Datenrate $13 frac("Mbit", "s")$ beeinträchtigt wird.

Man kann also die vereinfachte Annahme treffen, dass die RTT etwa 30 ms beträgt.

Daher wird ein Akzeptanztest durchgeführt, der die Bedingungen von Streaming zu AWS EU Central 1 nachstellt ohne das volle Cloud-Setup zu benötigen.

== Testumgebung

Das Proof-of-Concept Programm wird lokal (zwei PCs im selben Netzwerk mit STUN/TURN server für lokales Netzwerk) ausgeführt und die Latenz wird künstlich per Network Link Conditioner @network-link-conditioner auf etwa 30 ms erhöht.

Testpersonen spielen zwei mal drei Minuten Cyberpunk 2077.
Alle Testpersonen spielen einmal mit dem Streaming-Client (oben beschriebenes Setup) und einmal lokal ohne Streaming. Die Reihenfolge ist dabei zufällig und es wird nicht gesagt, ob gerade lokal oder per Stream gespielt wird. In beiden Fällen werden dieselben Peripheriegeräte (Maus, Tastatur, Bildschirm) verwendet. Per KVM-Switch wird zwischen den Beiden PCs umgeschaltet, ohne dass die Teilnehmer sehen welcher PC gerade verwendet wird.

In beiden Fällen läuft das Spiel auf einem MacBook Pro M4 Max mit 16-core CPU und 64GB unified memory.
Die Gruppe, die mit Streaming spielt, verwendet dabei einen Windows Laptop mit AMD Ryzen 5 5500U und integrierter Radeon RX Vega 7 GPU.

Alle Tests werden am selben Ort aber an unterschiedlichen Zeiten und Tagen durchgeführt.

Es wird per Videoaufzeichnung die Anzahl besiegter Gegner gezählt.

Einstiegserklärung für Teilnehmer: #quote[
  Du spielst zwei kurze Abschnitte aus Cyberpunk 2077, je 3 Minuten. Die Reihenfolge ist zufällig. Spiel bitte so wie üblich. Nach jedem Abschnitt kommen kurze Fragen. Es gibt keine richtigen oder falschen Antworten. Wenn technische Probleme auftauchen, sag mir Bescheid.
]

== Zwischenfragen nach jedem Abschnitt

+ Wie wahrscheinlich ist es, dass du das Spiel kaufen würdest, wenn die Vollversion jetzt verfügbar wäre?
  Skala 1–5
  1 = sehr unwahrscheinlich, 5 = sehr wahrscheinlich
+ Wie stark hat dich die Eingabeverzögerung (Input‑Lag / Steuergefühl) während dieses Abschnitts gestört?
  Skala 1–5
  1 = überhaupt nicht, 5 = sehr stark
+ Wie würdest du die Bildqualität bewerten (Schärfe, Artefakte, Ruckeln)?
  Skala 1–5
  1 = sehr schlecht, 5 = sehr gut
+ Wie viel Spaß hattest du in diesem Abschnitt?
  Skala 1–5
  1 = gar keinen Spaß, 5 = sehr viel Spaß
+ Würdest du nach diesem Abschnitt weiterspielen?
  Ja / Nein

== Abschlussfragebogen nach beiden Abschnitten

+ Welcher Abschnitt war für dich insgesamt am angenehmsten / am kaufentscheidendsten?
  Abschnitt 1 / Abschnitt 2 / Keine Präferenz
  Hinweis: Abschnittsnummern entsprechen der Reihenfolge, die du gespielt hast.
+ In welchem Abschnitt wärst du am ehesten bereit gewesen, das Spiel zu kaufen?
  Abschnitt 1 / Abschnitt 2 / Keine Präferenz
+ Hast du schon Erfahrung mit Cloud‑Gaming (z. B. Stadia, Geforce Now, etc.)?
  Ja / Nein

== Ergebnisse

Es haben 10 Testpersonen teilgenommen.

Links ist lokal, rechts ist per Stream.

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
  caption: "Besiegte Gegner (hoher = besser)",
)

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
  caption: "Kaufwahrscheinlichkeit (hoher = besser)",
)

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
  caption: "Einschätzung Eingabeverzögerung (hoher = schlechter)",
)

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
  caption: "Einschätzung Bildqualität (hoher = besser)",
)

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
  caption: "Spielspaß (hoher = besser)",
)

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
  caption: "Testpersonen will weiter spielen (hoher = besser)",
)

== Ergebnis

Alle Tester haben den Test abgeschlossen.

Durch die Testergebnisse kann man zu dem Schluss gelangen, dass das Streaming das Spielerlegnis leicht beeinträchtigt.
Die Metriken liegen sehr nahe beieinander. Der offensichtlichste Unterschied liegt bei der Einschätzung für Bildqualität und Latenz. Das war zu erwarten, da diese beim Streaming objektiv schlechter sind als beim lokalen Spiel.

Das Ziel dieses Tests ist es aber herauszufinden, ob das das Spielerlebnis mit Streaming negativ beeinträchtigt. Der Unterschied ist minimal aber sichtbar.

Unerwartet ist, dass beim Streaming eine höhere Kaufwahrscheinlichkeit angegeben wurde. Dafür hat der Autor keine Erklärung. Durch die geringe Teilnehmerzahl kann man hier zu dem Schluss gelangen, dass die fehlende Statistische Signifikanz zu dem unerklärlichen Ergebnis geführt hat, da das gespiente Spiel viele zufällige Elemente beinhaltet.
