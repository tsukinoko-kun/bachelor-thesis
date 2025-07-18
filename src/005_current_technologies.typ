= Stand der Technik

Google Stadia verwendete H.264 und VP9 über WebRTC. Nvidia GeForce Now sendet H.264 über einen RTP-Stream durch ein UDP Sockert. @di2021network Shadow lässt den User über UDP und TCP im Client entscheiden. @shadow-streaming

Neuere Protokolle, die auf QUIC basieren, gewinnen im Echtzeit-Streaming an Bedeutung, sind aber noch in der Minderheit. @streaming-protocols Zudem können verschiedene Protokolle mit QUIC genutzt werden, hier mangelt es noch an einem etablierten Standard.

Nvidia GeForce Now verwendet kurzlebige VMs. @drweb-geforce-now

Auch Google Stadia basiert auf VMs. Google verwendet aber eine eigene Virtualisierungs-Layer. Zudem können Stadia-Inctances direkt (ohne über das Internet gehen zu müssen) miteinander kommunizieren, was einen großen Vorteil bei Multiplayer-Spielen bietet. @google-stadia

Google Stadia verwendet custom GPUs von AMD, die ein Multi-GPU-Setup hinter der Vulkan-API so virtualisieren, dass ein Spiel die Leistung mehrerer GPUs nutzen kann, ohne dass die Engine das unterstützt. Für die Engine sieht es so aus wie eine große GPU. @google-stadia

NVIDIA hat die vGPU-Funktionalität, welche bei GeForce Now eingesetzt wird, auf Consumer-Grafikkarten historisch eingeschränkt, was es für einzelne Benutzer oder kleinere Setups schwierig macht, eine einzelne GPU auf mehrere VMs zu partitionieren, ohne spezialisierte Rechenzentrum-GPUs und die damit verbundenen Lizenzen. @proxmox-gpu-isolation-thread

== Nvidia GPU Technologien

NVIDIA stellt eine Reihe von Schlüsseltechnologien zur Verfügung, die
maßgeblich zur Leistungssteigerung bei grafisch anspruchsvollen Spielen
beitragen und somit die Hardware-Anforderungen adressieren.

=== Multi Frame Generation

Multi Frame Generation ist ein fortschrittliches Verfahren zur Synthese von
Bildern, das darauf abzielt, die wahrgenommene Bildwiederholrate (Framerate)
signifikant zu erhöhen. Im Gegensatz zur Generierung eines einzelnen
Zwischenbildes, wie es bei früheren Implementierungen der Fall war, ist diese
Technik in der Lage, mehrere Bilder zwischen zwei von der Game-Engine
gerenderten Frames zu interpolieren. Unter Verwendung von Bewegungsvektoren,
optischen Flussfeldern und temporalen Daten aus vorangegangenen Bildern
rekonstruiert ein neuronales Netzwerk eine Sequenz von Zwischenbildern. Das
primäre Ziel ist die Erzeugung einer als extrem flüssig wahrgenommenen
Bewegung, die weit über die native Renderleistung der Hardware hinausgeht,
insbesondere in CPU-limitierten Szenarien. @dlss4

=== Transformer-basierte Ray Reconstruction

Die Transformer-basierte Ray Reconstruction (TRR) ist eine Methode zur
Rauschunterdrückung (Denoising) und Detailrekonstruktion von
Ray-Tracing-Effekten, die auf einer Transformer-Architektur basiert. Anstelle
von konventionellen Faltungsnetzwerken (CNNs) nutzt TRR die Fähigkeit von
Transformern, globale Bildkontexte und langreichweitige Abhängigkeiten
zwischen Pixeln zu analysieren. Dadurch kann das Modell fehlende oder
verrauschte Lichtinformationen (z.B. Reflexionen, Schatten, globale
Beleuchtung) mit höherer Genauigkeit und Kohärenz wiederherstellen. Dies
resultiert in einer visuell präziseren und artefaktärmeren Darstellung von
Ray-Tracing-Effekten im Vergleich zu früheren Denoising-Verfahren. @dlss4

=== Transformer-basierte Super Resolution

Transformer-basiertes Super Resolution (TSR) beschreibt den Prozess der
Hochskalierung eines niedrig aufgelösten Bildes auf eine höhere
Zielauflösung mittels eines Transformer-Modells. Ähnlich wie bei der Ray
Reconstruction nutzt diese Technik die Stärke von Transformern bei der
Erfassung globaler Kontexte. Durch die Analyse von niedrig aufgelösten
Eingabebildern, Bewegungsvektoren und historischer Bilddaten rekonstruiert
das neuronale Netzwerk ein hochaufgelöstes Bild. Der Vorteil gegenüber
CNN-basierten Ansätzen liegt in der potenziell überlegenen Rekonstruktion von
feinen Texturen und komplexen Mustern sowie einer verbesserten temporalen
Stabilität, da das Modell logische Zusammenhänge über größere Bildbereiche
hinweg herstellen kann. @dlss4

=== Reflex Frame Warp

Reflex Frame Warp ist eine Latenzkompensationstechnik, die speziell für den
Einsatz mit Frame-Generation-Verfahren entwickelt wurde. Die durch die
Interpolation von Bildern entstehende zusätzliche Latenz wird durch dieses
Verfahren aktiv reduziert. Unmittelbar bevor ein generiertes Bild an den
Monitor gesendet wird, erfasst das System die aktuellsten Eingabedaten des
Nutzers (z.B. Mausbewegungen). Basierend auf diesen Daten wird das bereits
fertiggestellte Bild minimal verzerrt ("warped"), um die Darstellung an die
letzte bekannte Spieleraktion anzugleichen. Dieser Prozess korrigiert die
Diskrepanz zwischen der angezeigten Bildinformation und der Intention des
Spielers und reduziert somit die wahrgenommene "Input-to-Photon"-Latenz.
@dlss4

