= Kosten

Dieses Kapitel widmet sich der Analyse der Betriebskosten, die pro Nutzer und Spielstunde anfallen. Die Kalkulation basiert auf den Preisen des gewählten Cloud-Providers AWS und den im Proof of Concept ermittelten Datenraten. Die Ergebnisse werden anschließend mit dem in Kapitel 4 definierten Wirtschaftlichkeitsziel von 1 € pro Stunde verglichen, um die ökonomische Machbarkeit des Konzepts zu bewerten.

== Analyse der Betriebskosten pro Spielstunde

Die laufenden Kosten einer Spielsitzung setzen sich im Wesentlichen aus zwei Komponenten zusammen: den Kosten für die gemietete Rechenleistung und den Kosten für die ausgehende Datenübertragung zum Nutzer.

=== Kosten für die Rechenleistung

Der primäre Kostentreiber ist die für jede Spielsitzung benötigte Recheninstanz. Wie in Kapitel 6 dargelegt, wurde die AWS EC2-Instanz vom Typ `g5.2xlarge` als technologische Basis gewählt, da sie die notwendige GPU-Leistung für High-End-Spiele bereitstellt. Die Kosten für diese On-Demand-Instanz in der AWS-Region `eu-central-1` (Frankfurt) belaufen sich auf $1.432 frac("€", "h")$. @vantage-g5-2xlarge

=== Kosten für die Datenübertragung

Ein weiterer signifikanter Kostenfaktor ist die ausgehende Datenübertragung (_Data Outbound_) vom AWS-Rechenzentrum zum Endnutzer. Um diesen Posten zu quantifizieren, wurde die während des im Proof of Concept (Kapitel 9) durchgeführten Testlaufs erzeugte Datenrate des WebRTC-Streams analysiert. Die Messungen, die in Intervallen von einer Sekunde erfolgten, zeigen eine variable Bitrate:

```
11.30 Mbit/s
13.42 Mbit/s
13.49 Mbit/s
11.99 Mbit/s
13.70 Mbit/s
13.26 Mbit/s
13.10 Mbit/s
12.22 Mbit/s
15.33 Mbit/s
17.00 Mbit/s
16.21 Mbit/s
18.16 Mbit/s
12.52 Mbit/s
10.67 Mbit/s
10.43 Mbit/s
9.74 Mbit/s
10.14 Mbit/s
10.80 Mbit/s
10.96 Mbit/s
9.53 Mbit/s
```

Für die weitere Kostenkalkulation wird ein konservativer Wert von $18 frac("Mbit", "s")$ angenommen. Dieser orientiert sich an den gemessenen Spitzenwerten und soll sicherstellen, dass auch grafisch intensive Spielszenen mit hoher Datenrate (viel Bewegung im Bild) in der Kalkulation abgedeckt sind. Daraus ergibt sich ein stündliches Datenvolumen von:

$V_(frac("GB", "h")) = frac(18 * 10^6 frac("bit", "s") * 3600 "s", 8 * 10^9 frac("bit", "GB")) = 8.1 frac("GB", "h")$

Die Kosten für ausgehenden Datenverkehr bei AWS sind gestaffelt. Für die Kalkulation wird der Preis der ersten Stufe herangezogen, der für die ersten 10 TB pro Monat gilt. @aws-ec2-pricing-datatransfer

- Die ersten $10 frac("TB", "Monat")$: $0.09 frac("$", "GB")$
- Die nächsten $40 frac("TB", "Monat")$: $0.085 frac("$", "GB")$
- Die nächsten $100 frac("TB", "Monat")$: $0.07 frac("$", "GB")$
- Mehr als $150 frac("TB", "Monat")$: $0.05 frac("$", "GB")$

Die stündlichen Kosten für die Datenübertragung berechnen sich somit wie folgt, wobei ein Umrechnungskurs von Dollar zu Euro berücksichtigt wird:

$C_(frac("$", "h")) = V_(frac("GB", "h")) * P_(frac("$", "GB")) = 8.1 * 0.09 = 0.729 frac("$", "h") approx 0.63 frac("€", "h")$

== Gesamtkosten und Wirtschaftlichkeitsprüfung

Die Gesamtkosten pro Spielstunde setzen sich aus den Kosten für die Recheninstanz und die Datenübertragung zusammen:

- Kosten für EC2-Instanz (`g5.2xlarge`): $1.432 frac("€", "h")$
- Kosten für Datenübertragung: $0.63 frac("€", "h")$

Daraus ergeben sich die gesamten Betriebskosten pro Stunde:

$C_("Gesamt") = 1.432 frac("€", "h") + 0.63 frac("€", "h") = 2.062 frac("€", "h")$

Das Ergebnis von rund $2.06 frac("€", "h")$ überschreitet das definierte Kostenziel von $1 frac("€", "h")$ um mehr als das Doppelte. Diese Diskrepanz verdeutlicht eine zentrale wirtschaftliche Hürde des Konzepts: Die Betriebskosten für eine einzelne High-End-Gaming-Sitzung in der Cloud sind erheblich.

Selbst bei der Wahl einer kleineren Instanz wie der `g5.xlarge`, deren Kosten bei etwa $1.081 frac("€", "h")$ liegen @aws-ec2-g5-instances, würde allein die Rechenleistung das Budget bereits überschreiten, ohne die Kosten für die Datenübertragung zu berücksichtigen.

*Das Kostenziel wird somit klar verfehlt.* Für einen wirtschaftlich tragfähigen Betrieb im Rahmen eines kostenfreien Demo-Modells müssten signifikante Einsparungen bei der Infrastruktur erzielt werden, beispielsweise durch die Nutzung von Spot-Instanzen oder die Aushandlung von Sonderkonditionen mit dem Cloud-Provider.
