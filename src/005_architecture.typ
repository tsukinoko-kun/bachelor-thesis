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

=== Context

#figure(image("img/c1.jpg"), caption: "C4-Modell - Context", placement: auto)
Der Entwickler und der Spieler verwenden die Game-Streaming-Plattform.
Der Entwickler lädt das Spiel hoch und der Spieler greift indirekt darauf zu.

=== Container

==== Automatisierte Erstellung des Amazon Machine Image (AMI)

Der Prozess wird durch die Deponierung von Programm-Binaries durch ein CI/CD-System oder manuellen Upload in einem designierten S3 Bucket initiiert. Die Erstellung des Objekts im S3 Bucket generiert ein `Object Created` Event, welches von einer Amazon EventBridge Regel erfasst wird.

Simple Storage Service (S3) wurde zum Speichern der Programm-Binaries wegen seiner Kosteneffizienz und der Fähigkeit, große Datenmengen zu verarbeiten, ausgewählt. @abiodundesign

EventBridge triggert daraufhin den Start einer EC2 Image Builder Pipeline. Die Metadaten des S3-Objekts, wie Bucket-Name und Objektschlüssel, werden als Parameter an die Pipeline übergeben. Die Pipeline instanziiert eine temporäre EC2-Build-Instanz basierend auf einem vordefinierten Rezept. Innerhalb dieser Instanz wird ein Skript ausgeführt, das die übergebenen Parameter nutzt, um die Binaries aus dem S3 Bucket herunterzuladen und die Software zu installieren.

Nach erfolgreicher Konfiguration der Instanz erstellt der Image Builder Service ein neues Amazon Machine Image (AMI). Der Abschluss dieser Operation generiert ein `Image Creation Complete` Event. Dieses Event wird ebenfalls von EventBridge verarbeitet, welches eine Lambda-Funktion aufruft und die ID des neu erstellten AMIs übergibt. Die Funktion persistiert diese AMI-ID zusammen mit dem zugehörigen Programmnamen in einer DynamoDB zur späteren Referenzierung.

#figure(
  image("img/c2.jpg"),
  caption: "C4-Modell - Container",
  placement: auto,
  // scope: "parent",
)

==== Spielerinitiierter und asynchroner Instanz-Start

Ein Benutzer initiiert den Start einer Programmausführung über eine Frontend-Applikation. Das Frontend sendet eine Anfrage an einen API Gateway Endpunkt, welcher die Anfrage an eine Lambda-Funktion weiterleitet. Diese Funktion führt eine Abfrage gegen die DynamoDB aus, um die korrekte AMI-ID für den angeforderten Programmnamen zu ermitteln.

Mit dieser AMI-ID instruiert die Lambda-Funktion den Amazon EC2 Service, eine neue Instanz zu starten. Der EC2-Service bestätigt die Initiierung asynchron und gibt eine `InstanceId` zurück. Diese ID wird von der Lambda-Funktion über das API Gateway an das Frontend propagiert.

Aufgrund der Latenz beim Start einer EC2-Instanz implementiert das Frontend einen Polling-Mechanismus. Es ruft periodisch einen zweiten API-Gateway-Endpunkt auf und übergibt dabei die erhaltene `InstanceId`. Eine Lambda-Funktion fragt den Status der EC2-Instanz ab. Sobald die Instanz den Zustand "running" erreicht hat, liefert die Funktion die öffentliche IP-Adresse zurück. Nach Erhalt der Verbindungsdaten etabliert das Frontend eine direkte Verbindung zur EC2-Instanz.
