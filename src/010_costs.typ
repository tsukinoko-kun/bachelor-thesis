= Kosten

== Berechnung der Datenrate

Beim WebRTC-Stream wurden folgende Datenraten in einsekündigen Intervallen gemessen:

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

Daraus lässt sich berechnen:

- Median: $12.52 frac("Mbit", "s")$
- Durchschnitt: $12.6985 frac("Mbit", "s")$
- Standardabweichung: $2.389 frac("Mbit", "s")$

$V_(frac("GB", "h")) = frac(18 * 10^6 frac("bit", "s")*3600 "s", 8 * 10^9 frac("bit", "GB")) = 8.1 frac("GB", "h")$


AWS Preise für outbound Daten: @aws-ec2-pricing-datatransfer

- Die ersten $10 frac("TB", "Monat")$ $0.09 frac("$", "GB")$
- Die nächsten $40 frac("TB", "Monat")$ $0.085 frac("$", "GB")$
- Die nächsten $100 frac("TB", "Monat")$ $0.07 frac("$", "GB")$
- Mehr als $150 frac("TB", "Monat")$ $0.05 frac("$", "GB")$

$C_(frac("$", "h")) = V_(frac("GB", "h")) * P_(frac("$", "GB")) = 8.1 * 0.09 = 0.729 frac("$", "h") approx 0.63 frac("€", "h")$

== Summe

- $€1.432 frac("€", "h")$ AWS EC2 g5.2xlarge in eu-central-1 @vantage-g5-2xlarge
- $0.63 frac("€", "h")$ Outbound Daten

*Gesamt: $C_(frac("€", "h")) = 1.432 + 0.63 = 1.495 frac("€", "h")$*

Bereits die EC2 G5 2XLarge Instanz kostet mehr als das Ziel von $1 frac("€", "h")$.
Selbst die kleinere G5 XLarge kostet $1.081 frac("€", "h")$. @aws-ec2-g5-instances

*Damit ist das Kostenziel nicht erreicht.*
