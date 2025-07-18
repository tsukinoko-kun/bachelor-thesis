= Architektur

Zur Gewährleistung der geforderten Skalierbarkeit wurden verschiedene Ansätze für den Betrieb der Spieleserver evaluiert.

Der anfängliche Plan, dedizierte, physisch verfügbare Server zu nutzen, wurde verworfen.
Dieser Ansatz kann die erforderliche dynamische Skalierbarkeit nicht realistisch gewährleisten, da Hardware-Ressourcen nicht flexibel und zeitnah an den Bedarf angepasst werden können.

Eine höhere Skalierbarkeit ließe sich durch gemietete Server in einem Rechenzentrum realisieren.
Dieser Ansatz ist jedoch kostenineffizient, da die Hardware auch bei ausbleibender Nutzung vollständig bezahlt werden muss.

Als optimale Lösung wurde ein Serverless-Ansatz identifiziert, bei dem Rechenkapazitäten von einem Cloud-Provider wie AWS nur für die tatsächliche Nutzungsdauer angemietet werden.
Je mehr Spieler aktiv sind, desto mehr Serverinstanzen werden dynamisch provisioniert.
Bei Inaktivität entstehen keine Kosten für die ungenutzte Rechenleistung.
Die primäre Begrenzung dieses Modells stellen die Betriebskosten bei hoher Auslastung dar.
Zusätzlich ist zu beachten, dass AWS regionale Quotas für die maximale Anzahl gleichzeitig laufender EC2-Instanzen pro Account festlegt.
Eine Erhöhung dieser Limits ist auf Anfrage möglich, erfordert bei sehr hohem Bedarf jedoch eine direkte Abstimmung mit AWS, da die Kapazitäten der Rechenzentren nicht unbegrenzt sind. @aws-ec2-quotas

== Entwicklung

Der Entwurf der Architektur erfolgte nach einem "Backward Design"-Ansatz, ausgehend vom kritischsten Punkt: der direkten Verbindung zwischen Frontend und EC2-Instanz, über welche der Videospiel-Stream übertragen wird.
Um eine minimale Latenz zu erreichen, ist eine direkte Verbindung zwischen dem Frontend des Spielers und der EC2-Instanz essenziell, da diese die Anzahl der Intermediäre in der Kommunikationsstrecke minimiert. @fei1998measurements

Dies führt zur zentralen Frage der Instanziierung der EC2-Instanz.
Da der Start durch eine Aktion des Spielers im Frontend ausgelöst werden soll und AWS-Dienste stark auf einer ereignisgesteuerten Architektur (Event-driven Architecture) basieren, bietet sich die Verwendung einer Lambda-Funktion als Vermittler an.
Diese Funktion kann die Anfrage des Frontends entgegennehmen und den Start der EC2-Instanz initiieren.

Dieser Ansatz wirft zwei Folgeprobleme auf:

1. *Herstellung der Verbindung:* Wie erfährt das Frontend die IP-Adresse der EC2-Instanz, um eine Verbindung aufzubauen? Die startende Lambda-Funktion ist aufgrund ihrer kurzen, vorgesehenen Lebensdauer zu diesem Zeitpunkt bereits beendet.
2. *Bereitstellung des Abbilds:* Welches AMI soll für die EC2-Instanz verwendet werden und woher wird es bezogen?

Das Verbindungsproblem lässt sich durch einen Polling-Mechanismus lösen.
Das Frontend fragt periodisch eine zweite Lambda-Funktion an, um den Status der Instanz zu überprüfen.
Sobald die Instanz betriebsbereit ist, gibt diese Funktion die öffentliche IP-Adresse an das Frontend zurück.

Die Lösung für die Bereitstellung des Abbilds ist mehrschichtig.
Es muss ein Mechanismus etabliert werden, der für jedes Spiel ein spezifisches, vorkonfiguriertes AMI bereithält.
Zur Zuordnung von Spiel zu AMI eignet sich ein Key-Value-Store wie Amazon DynamoDB.
In diesem wird der eindeutige Name des Spiels als Schlüssel (Key) und die zugehörige AMI-ID als Wert (Value) gespeichert.

Die Erstellung der AMIs wird durch den EC2 Image Builder automatisiert.
Dieser Dienst startet eine temporäre EC2-Instanz und führt darauf ein Konfigurationsskript aus.
Das Skript installiert die erforderliche Software: die Streaming-Anwendung und das eigentliche Spiel.
Während die Streaming-Software aus diversen Quellen wie Paketmanagern oder S3 bezogen werden kann, stellt die Distribution des Spiels aufgrund seiner potenziell erheblichen Dateigröße eine Herausforderung dar.
Amazon S3 ist hierfür die geeignete Lösung, da der Dienst für die Speicherung und den Abruf großer Datenmengen optimiert ist. @abiodundesign

Der Prozess beginnt, wenn der Spielentwickler die Spieldateien in einen S3-Bucket hochlädt, was typischerweise im Rahmen einer CI/CD-Pipeline geschieht.
Dieser Upload-Vorgang löst via Amazon EventBridge automatisch den Start des Image-Builder-Prozesses aus.

== C4: Context

Das System interagiert mit zwei primären Akteuren: dem Spielentwickler und dem Spieler.
Der Entwickler stellt die Spielinhalte bereit, indem er sie auf die Plattform hochlädt.
Der Spieler nutzt die Plattform, um auf diese Inhalte zuzugreifen und das Spiel zu streamen.

#figure(image("img/c1.jpg"), caption: "C4-Modell - Context")

== C4: Container

Die Architektur basiert auf zwei zentralen, asynchronen Prozessen: der automatisierten Erstellung eines AMI und dem spielerinitiierten Start einer EC2-Instanz.

=== Automatisierte Erstellung des AMI

Der Prozess wird durch die Deponierung von Spiel-Binaries in einem designierten S3-Bucket initiiert, beispielsweise durch eine CI/CD-Pipeline oder einen manuellen Upload.
Die Erstellung des Objekts im S3-Bucket löst ein `Object Created`-Event aus, welches von einer Amazon EventBridge-Regel erfasst wird.
Simple Storage Service (S3) wurde aufgrund seiner Kosteneffizienz und der Fähigkeit, große Datenmengen zu verarbeiten, als Speicherort für die Binaries gewählt. @abiodundesign

EventBridge startet daraufhin eine EC2 Image Builder-Pipeline und übergibt die Metadaten des S3-Objekts, wie Bucket-Name und Objektschlüssel, als Parameter.
Die Pipeline instanziiert eine temporäre EC2-Build-Instanz basierend auf einem vordefinierten Rezept.
Innerhalb dieser Instanz wird ein Skript ausgeführt, das die übergebenen Parameter nutzt, um die Binaries aus dem S3-Bucket herunterzuladen und die notwendige Software (Spiel und Streaming-Software) zu installieren.

Nach erfolgreicher Konfiguration der Instanz erstellt der Image Builder-Service ein neues AMI.
Der Abschluss dieser Operation generiert ein `Image Creation Complete`-Event.
Dieses Event wird ebenfalls von EventBridge verarbeitet, welches eine Lambda-Funktion aufruft und die ID des neu erstellten AMIs übergibt.
Die Funktion persistiert diese AMI-ID zusammen mit dem zugehörigen Spielnamen in einer DynamoDB-Tabelle zur späteren Referenzierung.

=== Spielerinitiierter und asynchroner Instanz-Start

Ein Spieler initiiert den Start einer Spielsitzung über eine Frontend-Applikation.
Das Frontend sendet eine Anfrage an einen API-Gateway-Endpunkt, welcher die Anfrage an eine Lambda-Funktion weiterleitet.
Diese Funktion führt eine Abfrage in der DynamoDB aus, um die korrekte AMI-ID für das angeforderte Spiel zu ermitteln.

Mit dieser AMI-ID instruiert die Lambda-Funktion den Amazon EC2 Service, eine neue Instanz zu starten.
Der EC2-Service bestätigt die Initiierung asynchron und gibt eine `InstanceId` zurück.
Diese ID wird von der Lambda-Funktion über das API Gateway an das Frontend propagiert.

Aufgrund der Latenz beim Start einer EC2-Instanz implementiert das Frontend einen Polling-Mechanismus.
Es ruft periodisch einen zweiten API-Gateway-Endpunkt auf und übergibt dabei die erhaltene `InstanceId`.
Eine weitere Lambda-Funktion fragt den Status der EC2-Instanz ab.
Sobald die Instanz den Zustand "running" erreicht hat, liefert die Funktion die öffentliche IP-Adresse der Instanz zurück.
Nach Erhalt der Verbindungsdaten etabliert das Frontend eine direkte Verbindung zur EC2-Instanz, um eine minimale Latenz im Game-Stream zu gewährleisten. @fei1998measurements

#figure(
  image("img/c2.jpg"),
  caption: "C4-Modell - Container",
)
