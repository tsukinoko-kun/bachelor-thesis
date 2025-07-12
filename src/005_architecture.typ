== Architektur

Anfangs wurde der Plan verfolgt, die Spiele auf eigenen, physisch verfügbaren Servern zu betreiben.
Dieser Ansatz wurde jedoch verworfen, da es damit nicht realistisch umsetzbar ist, die geforderte Skalierbarkeit zu gewährleisten.

Die hohe Skalierbarkeit lässt sich mithilfe von gemieteten Servern in einem Rechenzentrum wie Hetzner realisieren,
was aber kostenineffizient ist, da bei diesem Ansatz die Hardware auch bezahlt werden muss, wenn sie nicht aktiv genutzt wird.

Ein weiterer Ansatz ist Serverless,
wobei die Server von einem Cloud-Provider wie AWS nur für die tatsächliche Betriebszeit gemietet werden.
Je mehr Spieler gleichzeitig spielen wollen, desto mehr Server werden genutzt.
Wenn keine Spieler aktiv sind, sind auch keine Server mehr aktiv.
Die einzige realistische Grenze bei diesem Ansatz sind die Betriebskosten.
Hierbei ist es wichtig zu beachten, das AWS Quotas für die Anzahl der EC2-Instanzen eines Accounts und einer Region festlegt.
Eine Erhöhung dieser Quotas kann angefragt werden, jedoch sind die AWS-Rechenzentren nicht unendlich groß und
sehr hohe Quotas erfordern direkte Zusammenarbeit mit AWS. @aws-ec2-quotas

=== Entwicklung

Die Architektur wurde vom Ende zum Anfang entworfen, also ausgehend von der Frontend-EC2-Verbindung.

Das Frontend muss direkt mit der EC2-Instanz verbunden werden.
Für die geringstmögliche Latenz soll so wenig wie möglich zwischen diesen beiden Parteien liegen. @fei1998measurements

Die erste Frage, die sich hier stellt, ist, wie die EC2-Instanz gestartet wird.
Da AWS auf Event-driven-architecture ausgelegt ist und ein Spieler die EC2-Instanz indirekt über ein Frontend anstoßen soll, ist es naheliegend, dass zwischen dem Frontend und der EC2 mindestens eine Lambda liegt.
Über eine Lambda, kann die EC2-Instanz gestartet werden.
Das führt zu zwei weiteren Fragen:

- Wie wird die Verbindung zwischen Frontend und EC2-Instanz hergestellt? Die Lambda, welche die EC2-Instanz gestartet hat, ist dann bereits heruntergefahren, da eine Lambda nur eine sehr kurze Lebensdauer haben sollte.
- Woher kommt das AMI für die EC2-Instanz?

Das erste Problem ist einfach zu lösen: Eine Zweite Lambda kann vom Frontend regelmäßig angestoßen werden, um zu prüfen, ob die Instanz bereit ist und die öffentliche IP-Adresse zurückzugeben.

Das zweite Problem ist komplizierter.
Ein AMI muss vorbereitet werden und bereitstehen.
Zudem muss bekannt sein, welches AMI für welches Spiel genutzt werden soll.

Um herauszufinden, welches AMI für ein bestimmtes Spiel genutzt werden soll, ist ein Key-Value-Store naheliegend, welcher einen eindeutigen Namen des Spiels als Schlüssel und die ID des AMI als Wert beinhaltet.

Ein AMI muss vom einem ImageBuilder gebaut werden.
Dieses startet eine EC2-Instanz, auf welcher ein Skript ausgeführt wird, welches die Instanz in den gewünschten Zustand bringt (Alle Programme installiert und Einstellungen vornimmt).
Es müssen zwei Programme installiert werden: Game streaming und das Spiel.
Das Game streaming Programm kann aus verschiedenen Quellen heruntergeladen werden (Package manager, Version Control Forge, S3, ...).
Das Spiel ist schwieriger, da es extrem groß sein kann.
S3 ist hierfür eine gute Wahl, da es für genau diese großen Dateien ausgelegt ist. @abiodundesign

Der Eigentümer des Spielt (Entwickler, Publisher, ...) muss das Spiel in S3 hochladen.
Dies wird wahrscheinlich über eine CI-Pipeline erfolgen, die Details sind für diese Arbeit aber nicht weiter relevant.
Das hochladen triggert den ImageBuilder über eine EventBridge.

=== C4: Context

#figure(image("img/c1.jpg"), caption: "C4-Modell - Context", placement: auto)

Der Entwickler und der Spieler verwenden die Game-Streaming-Plattform.
Der Entwickler lädt das Spiel hoch und der Spieler greift indirekt darauf zu.

=== C4: Container

#figure(
  image("img/c2.jpg"),
  caption: "C4-Modell - Container",
  placement: auto,
  // scope: "parent",
)

==== Automatisierte Erstellung des Amazon Machine Image (AMI)

Der Prozess wird durch die Deponierung von Programm-Binaries durch ein CI/CD-System oder manuellen Upload in einem designierten S3 Bucket initiiert. Die Erstellung des Objekts im S3 Bucket generiert ein `Object Created` Event, welches von einer Amazon EventBridge Regel erfasst wird.

Simple Storage Service (S3) wurde zum Speichern der Programm-Binaries wegen seiner Kosteneffizienz und der Fähigkeit, große Datenmengen zu verarbeiten, ausgewählt. @abiodundesign

EventBridge triggert daraufhin den Start einer EC2 Image Builder Pipeline. Die Metadaten des S3-Objekts, wie Bucket-Name und Objektschlüssel, werden als Parameter an die Pipeline übergeben. Die Pipeline instanziiert eine temporäre EC2-Build-Instanz basierend auf einem vordefinierten Rezept. Innerhalb dieser Instanz wird ein Skript ausgeführt, das die übergebenen Parameter nutzt, um die Binaries aus dem S3 Bucket herunterzuladen und die Software zu installieren.

Nach erfolgreicher Konfiguration der Instanz erstellt der Image Builder Service ein neues Amazon Machine Image (AMI). Der Abschluss dieser Operation generiert ein `Image Creation Complete` Event. Dieses Event wird ebenfalls von EventBridge verarbeitet, welches eine Lambda-Funktion aufruft und die ID des neu erstellten AMIs übergibt. Die Funktion persistiert diese AMI-ID zusammen mit dem zugehörigen Programmnamen in einer DynamoDB zur späteren Referenzierung.

==== Spielerinitiierter und asynchroner Instanz-Start

Ein Benutzer initiiert den Start einer Programmausführung über eine Frontend-Applikation. Das Frontend sendet eine Anfrage an einen API Gateway Endpunkt, welcher die Anfrage an eine Lambda-Funktion weiterleitet. Diese Funktion führt eine Abfrage gegen die DynamoDB aus, um die korrekte AMI-ID für den angeforderten Programmnamen zu ermitteln.

Mit dieser AMI-ID instruiert die Lambda-Funktion den Amazon EC2 Service, eine neue Instanz zu starten. Der EC2-Service bestätigt die Initiierung asynchron und gibt eine `InstanceId` zurück. Diese ID wird von der Lambda-Funktion über das API Gateway an das Frontend propagiert.

Aufgrund der Latenz beim Start einer EC2-Instanz implementiert das Frontend einen Polling-Mechanismus. Es ruft periodisch einen zweiten API-Gateway-Endpunkt auf und übergibt dabei die erhaltene `InstanceId`. Eine Lambda-Funktion fragt den Status der EC2-Instanz ab. Sobald die Instanz den Zustand "running" erreicht hat, liefert die Funktion die öffentliche IP-Adresse zurück. Nach Erhalt der Verbindungsdaten etabliert das Frontend eine direkte Verbindung zur EC2-Instanz.
