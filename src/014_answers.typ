= Beantwortung der Forschungsfragen

Dieses Kapitel beantwortet die Hauptforschungsfrage sowie die
untergeordneten Forschungsfragen auf Grundlage der in den Kapiteln zur
Methodik, Architektur, Implementierung, Kosten und Akzeptanz
gewonnenen Erkenntnisse.

== Ergebnis zur Hauptforschungsfrage

Die konzipierte Cloud-Gaming-Plattform muss serverseitig auf einem
Serverless-Modell mit kurzlebigen, pro Session dedizierten GPU-Instanzen
aufbauen. Jede Spielsitzung erhält eine eigene EC2 G5 Instanz mit
dedizierter NVIDIA GPU. Die Bereitstellung der Spielumgebung erfolgt
über ein vordefiniertes Amazon Machine Image. Das AMI wird automatisiert
mit EC2 Image Builder aus in S3 bereitgestellten Spieldateien erzeugt.
Die Zuordnung Spiel zu AMI wird in einem Key Value Store verwaltet
und bei Start über eine ereignisgesteuerte Kette aus API Gateway und
zwei AWS Lambda Funktionen aufgelöst. Der Verbindungsaufbau erfolgt
asynchron mit Polling bis zur Betriebsbereitschaft. Im Betrieb besteht
zwischen Client und Instanz eine direkte WebRTC Verbindung. Diese
Minimierung der Hops ist für die Latenz wesentlich @fei1998measurements.
Die Wahl von WebRTC ist wegen der Browserintegration und der Eignung
für Echtzeitübertragung belegt @webrtc-tech @di2021network.

Für Nutzer bedeutet dies sofortigen Zugang ohne Download und Installation.
Die Ende zu Ende Latenz bleibt im akzeptablen Rahmen. Das in der Arbeit
herangezogene Latenzbudget von bis zu 100 Millisekunden wird als
Orientierung bestätigt @choy2012brewing. Die in der Studie simulierte
Round Trip Time von 30 Millisekunden führte zwar zu messbar höherer
Eingabeverzögerung und geringfügig reduzierter Bildqualität, der
Spielspaß blieb jedoch weitgehend erhalten. Die Mehrheit der Befragten
bevorzugt Cloud Demos vor einem Download. Die Akzeptanz ist hoch.

Für Betreiber entstehen klare Implikationen. Die Plattform skaliert
horizontal, ist jedoch an regionale Quotas des Providers gebunden
@aws-ec2-quotas. Das Management großer Spieldateien bedarf einer
automatisierten Pipeline auf Basis von S3 und Image Builder. Die
laufenden Kosten pro Spielstunde wurden mit rund 2.06 Euro ermittelt.
Das definierte Ziel von 1 Euro wird damit deutlich verfehlt. Die
Wirtschaftlichkeit eines kostenfreien Demo Modells setzt signifikante
Kostensenkungen oder gesonderte Konditionen voraus. Schutz des geistigen
Eigentums ist als Voraussetzung für Publisher Kooperationen zu
gewährleisten.

== UFF 1: Geeignete Architekturmuster und Systemkomponenten

Die Untersuchung hat die monolithische Architektur verworfen. Der Grund
liegt in der praktischen Limitierung der GPU Auslastung auf eine bis zwei
anspruchsvolle Spielinstanzen. Eine wirtschaftliche 1 zu N Konsolidierung
ist im High End Segment nicht erreichbar. Multi GPU Setups sind für den
hier relevanten Anwendungsfall nicht zielführend. Der Wechsel zum
Serverless Modell ist daher folgerichtig.

Der tragfähige Architekturentwurf umfasst:

- kurzlebige EC2 G5 Instanzen pro Session mit dedizierter GPU
  @aws-ec2-g5-instances
- AMI Erzeugung per EC2 Image Builder auf Basis von S3 Uploads und
  EventBridge Triggern
- Zuordnung von Spiel zu AMI in DynamoDB
- spielerinitiierter Start über API Gateway und AWS Lambda mit
  asynchroner Statusabfrage
- direkte Medienverbindung Client zu Instanz für minimale Latenz
  @fei1998measurements
- Signaling Server für das WebRTC Handshake Verfahren
- Beachtung regionaler EC2 Quotas @aws-ec2-quotas

Diese Struktur folgt dem in der Arbeit angewandten Backward Design
Prinzip und adressiert Skalierbarkeit, Provisionierungszeit sowie
Kostentransparenz.

== UFF 2: Geringe Latenz bei hoher visueller Qualität

Die Evaluierung der Protokolle ergibt eine eindeutige Entscheidung zugunsten
von WebRTC. HLS und DASH sind wegen segmentbasierter Übertragung
untauglich. QUIC basierte Ansätze wie MoQ oder RoQ sind noch nicht
ausgereift und nicht breit verfügbar. WebRTC ist nativ im Browser
verankert und für Echtzeit geeignet @webrtc-tech @di2021network.

Die Umsetzung des Streaming Dienstes wurde mit GStreamer realisiert.
Die Videodaten werden hardwarebeschleunigt mit NVIDIA NVENC in H.264
kodiert und über RTP innerhalb der WebRTC Verbindung übertragen. Die
Client Eingaben werden über Data Channels verlustfrei und latenzarm
übermittelt. Die in der Arbeit dokumentierten Pipelines sind für Linux,
macOS und Windows spezifisch ausgelegt und auf niedrige Latenz
konfiguriert. Die gemessene variable Bitrate lag im Test bis etwa
18 Mbit pro Sekunde. Die daraus abgeleitete Datenmenge beträgt
rund 8.1 Gigabyte pro Stunde.

Im Akzeptanztest führte die simulierte Round Trip Time von 30 Millisekunden
zu einer wahrnehmbaren, aber moderaten Erhöhung der Eingabeverzögerung.
Die Bildqualität wurde etwas niedriger bewertet. Der Spielspaß blieb im
Mittel erhalten. Das postulierte Latenzbudget von bis zu 100 Millisekunden
wird damit eingehalten @choy2012brewing.

== UFF 3: Mehrwert und Hürden für Endnutzer

Der Mehrwert ist empirisch belegt.

- Mehrheitliche Präferenz für Cloud Demos gegenüber Download
  bei 68.6 Prozent. Weitere 11.4 Prozent sind zustimmend bei
  Bedingungen wie reibungsloser Zugang ohne umständliche Registrierung
  und geringer Latenz.
- Hohe Vertrautheit der Zielgruppe mit Cloud Gaming Diensten.
- Typische Bandbreiten und Latenzen der Zielgruppe liegen über den
  Mindestanforderungen. Der Median beträgt 105 Megabit pro Sekunde
  im Download und 16 Millisekunden Latenz.

Die Hürden sind klar umrissen.

- Eingabeverzögerung wird beim Streaming stärker wahrgenommen.
- Bildqualität fällt durch Kompression etwas ab.
- Zugangshürden wie Pflichtregistrierung würden die Akzeptanz mindern, sind aber nicht zwingend notwendig.

Trotz dieser Einschränkungen würden in beiden Testbedingungen sehr viele
Teilnehmende weiterspielen. Die Kaufwahrscheinlichkeit zeigte keinen
klaren Nachteil für das Streaming. Die Aussagekraft ist aufgrund der
Stichprobengröße begrenzt.

== UFF 4: Geschäftsmodelle und strategische Vorteile

Die Kostenanalyse quantifiziert die laufenden Kosten pro Stunde und
Spieler mit rund 2.06 Euro. Darin enthalten sind die On Demand Kosten
der Instanz und der ausgehende Datenverkehr @vantage-g5-2xlarge
@aws-ec2-pricing-datatransfer. Das anvisierte Kostenziel von 1 Euro wird
damit deutlich verfehlt. Auch eine kleinere G5 Variante überschreitet
das Budget bereits ohne Traffickosten @aws-ec2-g5-instances.

Für ein kostenfreies Demo Modell folgt daraus:

- Ohne signifikante Kostensenkung oder Sonderkonditionen ist ein rein
  kostenloses Angebot für den Betreiber wirtschaftlich nicht tragfähig.
- Die Wirtschaftlichkeit hängt maßgeblich von der Konversionsrate ab.
  Die Arbeit bewertet keine realen Konversionsdaten.
- Schutz des geistigen Eigentums ist als Mindestvoraussetzung für die
  Kooperation mit Publishern umzusetzen. Da Spieler nur das Spiel spielen
  können, ohne Zugriff auf die Spieldaten, ist diese Voraussetzung erfüllt.
  Ohne Probleme kann die Steuerung auf das Spiel begrenzt werden.

Ein strategischer Vorteil für Anbieter kann in der hohen Nutzerakzeptanz
des sofortigen Zugangs liegen. Eine Quantifizierung jenseits der in der
Arbeit erhobenen Daten erfolgt nicht.

== Würdigung der Arbeitshypothesen

- Monolithische Architektur als ausreichend. Falsifiziert.
- WebRTC als geeignetes Streaming Framework. Bestätigt.
- Hauptvorteil für Nutzer liegt in sofortiger Verfügbarkeit. Bestätigt.
  Registrierungspflichten sind als Hürde belegt.
- Kostenloses Demo Modell mit Konversion als Geschäftsgrundlage.
  Tragfähigkeit unter On Demand Annahmen nicht gegeben, da das
  Kostenziel verfehlt wird.
- Akzeptanz und Nutzungshäufigkeit unterscheiden sich nicht signifikant.
  Für die Akzeptanz liegen positive Indikationen vor. Zur Häufigkeit
  enthält die Arbeit keine belastbaren Daten.

== Grenzen der Aussagekraft

Die Umfrage zur Zielgruppe umfasst 35 Personen. Der Akzeptanztest
umfasst 10 Personen und wurde lokal mit einer simulierten Netzwerklatenz
durchgeführt. Ein produktiver Test auf EC2 fand nicht statt. Die
Ergebnisse sind daher als Indikation zu verstehen. Eine Generalisierung
erfolgt nicht.
