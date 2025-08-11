= Architektur

Die Konzeption der Systemarchitektur muss den in den vorangegangenen Kapiteln identifizierten Kernherausforderungen, insbesondere der Skalierbarkeit und Kosteneffizienz, Rechnung tragen. Nach der Evaluierung verschiedener Betriebsmodelle wurde ein Serverless-Ansatz als optimale Lösung identifiziert.

Die anfängliche Überlegung, dedizierte, physisch vorhandene Server zu nutzen, wurde verworfen. Ein solcher Ansatz kann die erforderliche dynamische Skalierbarkeit nicht gewährleisten, da Hardware-Ressourcen nicht flexibel und zeitnah an einen schwankenden Bedarf angepasst werden können. Eine höhere Flexibilität ließe sich zwar durch gemietete Server in einem Rechenzentrum erreichen, doch wäre dieses Modell kostenineffizient, da die Hardware auch bei ausbleibender Nutzung vollständig bezahlt werden müsste.

Der gewählte Serverless-Ansatz umgeht diese Nachteile, indem Rechenkapazitäten bei einem Cloud-Provider wie AWS nur für die tatsächliche Nutzungsdauer angemietet werden. Je mehr Spieler aktiv sind, desto mehr Serverinstanzen werden dynamisch provisioniert. Bei Inaktivität entstehen keine Kosten für ungenutzte Rechenleistung. Die primäre Begrenzung dieses Modells stellen die Betriebskosten bei hoher Auslastung dar. Zudem ist zu beachten, dass Cloud-Anbieter wie AWS regionale Quotas für die maximale Anzahl gleichzeitig laufender EC2-Instanzen pro Account festlegen. Eine Erhöhung dieser Limits ist zwar auf Anfrage möglich, erfordert bei sehr hohem Bedarf jedoch eine direkte Abstimmung mit dem Anbieter, da die Kapazitäten der Rechenzentren nicht unbegrenzt sind. @aws-ec2-quotas

== Architekturentwurf nach dem "Backward Design"-Prinzip

Der Entwurf der Architektur folgte einem "Backward Design"-Ansatz. Die Entwicklung begann beim kritischsten Punkt des Systems: der direkten Verbindung zwischen dem Frontend des Spielers und der EC2-Instanz, über welche der Videospiel-Stream übertragen wird. Um eine minimale Latenz zu erreichen, ist eine direkte Verbindung essenziell, da sie die Anzahl der Intermediäre in der Kommunikationsstrecke minimiert. @fei1998measurements

Aus dieser Anforderung ergibt sich die zentrale Frage, wie die EC2-Instanz bedarfsgesteuert erzeugt wird. Da der Start durch eine Aktion des Spielers im Frontend ausgelöst werden soll und AWS-Dienste stark auf einer ereignisgesteuerten Architektur (Event-driven Architecture) basieren, bietet sich die Verwendung einer Lambda-Funktion als Vermittler an. Diese kann die Anfrage des Frontends entgegennehmen und den Start der EC2-Instanz initiieren.

Dieser Ansatz wirft jedoch zwei unmittelbare Folgeprobleme auf:

1. *Herstellung der Verbindung:* Wie erfährt das Frontend die IP-Adresse der neu gestarteten EC2-Instanz, um eine Verbindung aufzubauen? Die initiierende Lambda-Funktion ist aufgrund ihrer kurzen, vorgesehenen Lebensdauer zu diesem Zeitpunkt bereits beendet.
2. *Bereitstellung des Spiel-Images:* Welches Amazon Machine Image (AMI) soll für die EC2-Instanz verwendet werden und woher wird es bezogen?

Das Verbindungsproblem lässt sich durch einen Polling-Mechanismus lösen. Das Frontend fragt periodisch eine zweite Lambda-Funktion an, um den Status der Instanz zu überprüfen. Sobald die Instanz betriebsbereit ist, gibt diese Funktion die öffentliche IP-Adresse an das Frontend zurück.

Die Lösung für die Bereitstellung des Images ist mehrschichtig. Es muss ein Mechanismus etabliert werden, der für jedes Spiel ein spezifisches, vorkonfiguriertes AMI bereithält. Zur Zuordnung von Spiel zu AMI eignet sich ein Key-Value-Store wie Amazon DynamoDB. In diesem wird der eindeutige Name des Spiels als Schlüssel (Key) und die zugehörige AMI-ID als Wert (Value) gespeichert.

Die Erstellung der AMIs selbst wird durch den EC2 Image Builder automatisiert. Dieser Dienst startet eine temporäre EC2-Instanz und führt darauf ein Konfigurationsskript aus, das die erforderliche Software (die Streaming-Anwendung und das eigentliche Spiel) installiert. Während die Streaming-Software aus diversen Quellen wie Paketmanagern oder einem S3-Bucket bezogen werden kann, stellt die Distribution des Spiels aufgrund seiner erheblichen Dateigröße eine Herausforderung dar. Amazon S3 ist hierfür die geeignete Lösung, da der Dienst für die Speicherung und den Abruf großer Datenmengen optimiert ist. @abiodundesign

Der gesamte Prozess wird idealerweise durch eine CI/CD-Pipeline angestoßen: Ein Spielentwickler lädt die Spieldateien in einen S3-Bucket hoch, was via Amazon EventBridge automatisch den Image-Builder-Prozess auslöst.

== C4-Modell: Systemkontext und Container

Die nachfolgenden Diagramme visualisieren die Architektur nach dem C4-Modell. Der Systemkontext zeigt die Interaktion der beiden primären Akteure (Spielentwickler und Spieler) mit der Plattform.

#figure(image("img/c1.jpg"), caption: "C4-Modell: Systemkontext (C1)")

Die Container-Ansicht detailliert die Architektur, die auf zwei zentralen, asynchronen Prozessen basiert: der automatisierten Erstellung eines AMI und dem spielerinitiierten Start einer EC2-Instanz.

=== Prozess 1: Automatisierte Erstellung des AMI

Der Prozess wird durch das Hochladen von Spiel-Binaries in einen designierten S3-Bucket initiiert. Dieses `Object Created`-Event wird von einer Amazon EventBridge-Regel erfasst. EventBridge startet daraufhin eine EC2 Image Builder-Pipeline und übergibt die Metadaten des S3-Objekts (Bucket-Name, Objektschlüssel) als Parameter. Die Pipeline instanziiert eine temporäre EC2-Build-Instanz, auf der ein Skript die Binaries aus S3 herunterlädt und zusammen mit der Streaming-Software installiert.

Nach erfolgreicher Konfiguration erstellt der Image Builder ein neues AMI. Der Abschluss dieser Operation generiert ein `Image Creation Complete`-Event, das wiederum von EventBridge verarbeitet wird. EventBridge ruft eine Lambda-Funktion auf, die die ID des neuen AMIs zusammen mit dem Spielnamen in einer DynamoDB-Tabelle für die spätere Verwendung ablegt.

=== Prozess 2: Spielerinitiierter und asynchroner Instanz-Start

Ein Spieler initiiert eine Spielsitzung über das Frontend. Dieses sendet eine Anfrage an einen API-Gateway-Endpunkt, der die Anfrage an eine Lambda-Funktion weiterleitet. Diese Funktion fragt die DynamoDB-Tabelle ab, um die korrekte AMI-ID für das angeforderte Spiel zu ermitteln.

Mit dieser AMI-ID instruiert die Lambda-Funktion den EC2-Service, eine neue Instanz zu starten. Da dieser Prozess asynchron verläuft, gibt der EC2-Service umgehend eine `InstanceId` zurück, die über das API Gateway an das Frontend propagiert wird.

Aufgrund der systembedingten Latenz beim Start einer EC2-Instanz implementiert das Frontend einen Polling-Mechanismus. Es ruft periodisch einen zweiten API-Gateway-Endpunkt auf und übergibt dabei die erhaltene `InstanceId`. Eine weitere Lambda-Funktion prüft den Status der EC2-Instanz. Sobald die Instanz den Zustand "running" erreicht hat, liefert die Funktion die öffentliche IP-Adresse zurück. Nach Erhalt dieser Information etabliert das Frontend eine direkte Verbindung zur EC2-Instanz, um eine minimale Latenz im Game-Stream zu gewährleisten. @fei1998measurements

#figure(
  image("img/c2.jpg"),
  caption: "C4-Modell: Container (C2)",
)
