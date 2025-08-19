= Stand der Technik

Um die in dieser Arbeit entwickelte Architektur in den aktuellen technologischen Kontext einzuordnen, werden nachfolgend etablierte Ansätze und Schlüsseltechnologien im Bereich des Cloud-Gamings analysiert. Der Fokus liegt dabei auf den für die Bereitstellung von High-End-Spielen relevanten Aspekten: Streaming-Protokolle, Virtualisierung der Server-Infrastruktur und Techniken zur Leistungssteigerung.

== Streaming-Protokolle und Transporttechnologien

Die Wahl des Übertragungsprotokolls ist entscheidend für die Latenz und damit für das Spielerlebnis. Etablierte Dienste setzen hier auf bewährte Technologien. So nutzte beispielsweise Google Stadia eine Kombination der Codecs H.264 und VP9, die über WebRTC übertragen wurden. Nvidia GeForce Now hingegen sendet einen H.264-Stream über das Real-Time Transport Protocol (RTP), typischerweise auf Basis eines UDP-Sockets, um die Übertragungsgeschwindigkeit zu maximieren @di2021network. Anbieter wie Shadow geben dem Nutzer sogar die Wahl zwischen UDP für geringere Latenz und TCP für eine höhere Zuverlässigkeit der Verbindung @shadow-streaming.

Als neuere Entwicklung gewinnen Protokolle, die auf QUIC basieren, im Echtzeit-Streaming an Bedeutung. Sie versprechen zwar weitere Latenzverbesserungen, befinden sich jedoch noch in einer vergleichsweise frühen Phase und sind in der Breite noch nicht etabliert @streaming-protocols. Das Fehlen eines einheitlichen Standards für die Medienübertragung über QUIC stellt eine zusätzliche Hürde dar.

== Virtualisierung und GPU-Management

Serverseitig basiert die Bereitstellung von Spielinstanzen in der Regel auf Virtualisierung. Sowohl Nvidia GeForce Now als auch das inzwischen eingestellte Google Stadia setzten auf virtuelle Maschinen (VMs), um die Spiele für die Nutzer auszuführen. GeForce Now verwendet dabei kurzlebige, für die jeweilige Spielsitzung erstellte VMs @drweb-geforce-now. Google verfolgte einen etwas anderen Ansatz mit einer eigenen Virtualisierungsschicht. Diese ermöglichte es Stadia-Instanzen, direkt und ohne Umweg über das öffentliche Internet miteinander zu kommunizieren, was insbesondere bei Multiplayer-Spielen Latenzvorteile bot @google-stadia.

Eine zentrale Herausforderung stellt die effiziente Zuweisung von GPU-Leistung dar. Google Stadia löste dies durch speziell angefertigte AMD-Grafikkarten, die mithilfe der Vulkan-API ein Multi-GPU-Setup so virtualisieren konnten, dass es für die Spiel-Engine wie eine einzige, sehr leistungsstarke GPU erschien. Damit wurde die oft fehlende Multi-GPU-Unterstützung moderner Spiele umgangen @google-stadia.

NVIDIA adressiert die GPU-Virtualisierung mit seiner vGPU-Technologie, die auch bei GeForce Now zum Einsatz kommt. Diese erlaubt es, eine physische GPU in mehrere virtuelle GPUs aufzuteilen und diese verschiedenen VMs zuzuweisen. Allerdings hat NVIDIA diese Funktionalität historisch auf spezialisierte und hochpreisige Rechenzentrum-GPUs beschränkt und entsprechende Lizenzen vorausgesetzt. Für Betreiber kleinerer Setups oder auf Basis von Consumer-Hardware ist die Partitionierung einer einzelnen GPU für mehrere VMs daher technisch und wirtschaftlich kaum umsetzbar @proxmox-gpu-isolation-thread.

== Leistungssteigernde GPU-Technologien von NVIDIA

Unabhängig von der Virtualisierung sind moderne GPU-Technologien entscheidend, um die für High-End-Spiele erforderliche Grafikleistung zu erzielen. NVIDIA stellt eine Reihe von Schlüsseltechnologien zur Verfügung, die maßgeblich zur Leistungssteigerung bei grafisch anspruchsvollen Spielen beitragen und somit die Hardware-Anforderungen adressieren.

=== Multi Frame Generation

Multi Frame Generation ist ein fortschrittliches Verfahren zur Synthese von Bildern, das darauf abzielt, die wahrgenommene Bildwiederholrate (Framerate) signifikant zu erhöhen. Im Gegensatz zur Generierung eines einzelnen Zwischenbildes, wie es bei früheren Implementierungen der Fall war, ist diese Technik in der Lage, mehrere Bilder zwischen zwei von der Game-Engine gerenderten Frames zu interpolieren. Unter Verwendung von Bewegungsvektoren, optischen Flussfeldern und temporalen Daten aus vorangegangenen Bildern rekonstruiert ein neuronales Netzwerk eine Sequenz von Zwischenbildern. Das primäre Ziel ist die Erzeugung einer als extrem flüssig wahrgenommenen Bewegung, die weit über die native Renderleistung der Hardware hinausgeht, insbesondere in CPU-limitierten Szenarien. @dlss4

=== Transformer-basierte Ray Reconstruction

Die Transformer-basierte Ray Reconstruction (TRR) ist eine Methode zur Rauschunterdrückung (Denoising) und Detailrekonstruktion von Ray-Tracing-Effekten, die auf einer Transformer-Architektur basiert. Anstelle von konventionellen Faltungsnetzwerken (CNNs) nutzt TRR die Fähigkeit von Transformern, globale Bildkontexte und langreichweitige Abhängigkeiten zwischen Pixeln zu analysieren. Dadurch kann das Modell fehlende oder verrauschte Lichtinformationen (z. B. Reflexionen, Schatten, globale Beleuchtung) mit höherer Genauigkeit und Kohärenz wiederherstellen. Dies resultiert in einer visuell präziseren und artefaktärmeren Darstellung von Ray-Tracing-Effekten im Vergleich zu früheren Denoising-Verfahren. @dlss4

=== Transformer-basierte Super Resolution

Transformer-basiertes Super Resolution (TSR) beschreibt den Prozess der Hochskalierung eines niedrig aufgelösten Bildes auf eine höhere Zielauflösung mittels eines Transformer-Modells. Ähnlich wie bei der Ray Reconstruction nutzt diese Technik die Stärke von Transformern bei der Erfassung globaler Kontexte. Durch die Analyse von niedrig aufgelösten Eingabebildern, Bewegungsvektoren und historischer Bilddaten rekonstruiert das neuronale Netzwerk ein hochaufgelöstes Bild. Der Vorteil gegenüber CNN-basierten Ansätzen liegt in der potenziell überlegenen Rekonstruktion von feinen Texturen und komplexen Mustern sowie einer verbesserten temporalen Stabilität, da das Modell logische Zusammenhänge über größere Bildbereiche hinweg herstellen kann. @dlss4

=== Reflex Frame Warp

Reflex Frame Warp ist eine Latenzkompensationstechnik, die speziell für den Einsatz mit Frame-Generation-Verfahren entwickelt wurde. Die durch die Interpolation von Bildern entstehende zusätzliche Latenz wird durch dieses Verfahren aktiv reduziert. Unmittelbar bevor ein generiertes Bild an den Monitor gesendet wird, erfasst das System die aktuellsten Eingabedaten des Nutzers (z. B. Mausbewegungen). Basierend auf diesen Daten wird das bereits fertiggestellte Bild minimal verzerrt ("warped"), um die Darstellung an die letzte bekannte Spieleraktion anzugleichen. Dieser Prozess korrigiert die Diskrepanz zwischen der angezeigten Bildinformation und der Intention des Spielers und reduziert somit die wahrgenommene "Input-to-Photon"-Latenz. @dlss4
