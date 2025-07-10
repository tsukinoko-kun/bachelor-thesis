== Architektur

=== Context

Der Entwickler und der Spieler verwenden die Game-Streaming-Plattform.
Der Entwickler lädt das Spiel hoch und der Spieler greift indirekt darauf zu.

Beide Nutzer

#figure(image("img/c1.jpg"), caption: "C4-Modell - Context")

=== Container
==== Automatisierte Erstellung des Amazon Machine Image (AMI)
Der Prozess wird durch die Deponierung von Programm-Binaries durch ein CI/CD-System oder manuellen Upload in einem designierten S3 Bucket initiiert. Die Erstellung des Objekts im S3 Bucket generiert ein `Object Created` Event, welches von einer Amazon EventBridge Regel erfasst wird.

Simple Storage Service (S3) wurde zum Speichern der Programm-Binaries wegen seiner Kosteneffizienz und der Fähigkeit, große Datenmengen zu verarbeiten, ausgewählt. @abiodundesign

#figure(
  image("img/c2.jpg"),
  caption: "C4-Modell - Container",
  placement: auto,
  scope: "parent",
)

EventBridge triggert daraufhin den Start einer EC2 Image Builder Pipeline. Die Metadaten des S3-Objekts, wie Bucket-Name und Objektschlüssel, werden als Parameter an die Pipeline übergeben. Die Pipeline instanziiert eine temporäre EC2-Build-Instanz basierend auf einem vordefinierten Rezept. Innerhalb dieser Instanz wird ein Skript ausgeführt, das die übergebenen Parameter nutzt, um die Binaries aus dem S3 Bucket herunterzuladen und die Software zu installieren.

Nach erfolgreicher Konfiguration der Instanz erstellt der Image Builder Service ein neues Amazon Machine Image (AMI). Der Abschluss dieser Operation generiert ein `Image Creation Complete` Event. Dieses Event wird ebenfalls von EventBridge verarbeitet, welches eine Lambda-Funktion aufruft und die ID des neu erstellten AMIs übergibt. Die Funktion persistiert diese AMI-ID zusammen mit dem zugehörigen Programmnamen in einer DynamoDB zur späteren Referenzierung.

==== Benutzerinitiierter und asynchroner Instanz-Start

Ein Benutzer initiiert den Start einer Programmausführung über eine Frontend-Applikation. Das Frontend sendet eine Anfrage an einen API Gateway Endpunkt, welcher die Anfrage an eine Lambda-Funktion weiterleitet. Diese Funktion führt eine Abfrage gegen die DynamoDB aus, um die korrekte AMI-ID für den angeforderten Programmnamen zu ermitteln.

Mit dieser AMI-ID instruiert die Lambda-Funktion den Amazon EC2 Service, eine neue Instanz zu starten. Der EC2-Service bestätigt die Initiierung asynchron und gibt eine `InstanceId` zurück. Diese ID wird von der Lambda-Funktion über das API Gateway an das Frontend propagiert.

Aufgrund der Latenz beim Start einer EC2-Instanz implementiert das Frontend einen Polling-Mechanismus. Es ruft periodisch einen zweiten API-Gateway-Endpunkt auf und übergibt dabei die erhaltene `InstanceId`. Eine Lambda-Funktion fragt den Status der EC2-Instanz ab. Sobald die Instanz den Zustand "running" erreicht hat, liefert die Funktion die öffentliche IP-Adresse zurück. Nach Erhalt der Verbindungsdaten etabliert das Frontend eine direkte Verbindung zur EC2-Instanz.
