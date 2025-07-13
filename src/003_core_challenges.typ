= Kernherausforderungen

Die Implementierung und der Betrieb von Cloud-Gaming-Plattformen sind mit
signifikanten Herausforderungen verbunden, welche in diesem Kapitel
systematisch analysiert werden.

== Latenz und Bandbreite

Eine der fundamentalsten Herausforderungen für Cloud-Gaming ist die
Gewährleistung einer geringen Ende-zu-Ende-Latenz, die für ein
reaktionsfähiges und immersives Spielerlebnis entscheidend ist. In der
Fachliteratur wird ein Latenzbudget von $≲100 "ms"$ als Obergrenze für eine
akzeptable Nutzererfahrung angesehen @choy2012brewing. Das Einhalten dieses
Budgets erfordert eine hochoptimierte Übertragungsstrecke vom Rechenzentrum
zum Endgerät.

== Hardware-Performance

Jede serverseitige Spielinstanz eines AAA-Titels erfordert eine
leistungsstarke Grafikkarte (GPU), um eine Darstellung mit hohen
Grafikeinstellungen und flüssigen Bildwiederholraten zu ermöglichen. Hierfür
kommen typischerweise Rechenzentrum-GPUs wie die NVIDIA RTX 6000 oder A10G zum
Einsatz.

Als Referenz für die Leistungsanforderungen auf Endnutzerseite dient
beispielsweise die für _The Last of Us Part II Remastered_ empfohlene NVIDIA
GeForce RTX 3060 @thelastofuspart2remastered. Diese erreicht in Kombination
mit KI-gestützten Technologien wie Frame Generation @dlss4 Bildraten von circa
100 FPS @thelastofuspart2remasteredbenchmark, was ein flüssiges Spielerlebnis
sicherstellt.

Im High-End-Segment für AAA-Spiele liegt der technologische Fokus aktuell auf
Hardware von NVIDIA. Berichten zufolge konzentrieren sich Wettbewerber wie AMD
und Intel strategisch auf andere Marktsegmente, weshalb NVIDIA-Technologien
für die hier betrachteten Anwendungsfälle von besonderer Relevanz sind
@alcorn-2024-amd-strategy @jaykihn0-2025-x-post.

NVIDIA stellt eine Reihe von Schlüsseltechnologien zur Verfügung, die
maßgeblich zur Leistungssteigerung bei grafisch anspruchsvollen Spielen
beitragen und somit die Hardware-Anforderungen adressieren:

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

== Umfangreiche Binärdateien

Eine logistische Herausforderung stellt das Management der Spieldateien dar.
Moderne AAA-Titel erreichen Dateigrößen im Bereich von 100 bis 200 Gigabyte
(GB), wie die folgende Auswahl verdeutlicht:

- _STAR WARS Jedi: Survivor_ (155 GB) @starwarsjedisurvivor
- _Assassin’s Creed Shadows_ (115 GB) @assassinscreedshadows
- _The Elder Scrolls IV: Oblivion Remastered_ (125 GB) @theelderscrollsoblivionremastered
- _Black Myth: Wukong_ (130 GB) @blackmythwukong
- _God of War Ragnarök_ (190 GB) @godofwarragnark
- _FINAL FANTASY VII REBIRTH_ (155 GB) @finalfantasyviirebirth
- _The Last of Us Part II Remastered_ (150 GB) @thelastofuspart2remastered
- _Dragon Age: The Veilguard_ (100 GB) @dragonagetheveilguard
- _Cyberpunk 2077_ (70 GB) @cyberpunk2077

Diese Datenmengen führen zu erheblichen Zeitaufwänden bei der
Datenübertragung, beispielsweise bei der initialen Bereitstellung der Spiele
auf den Servern. Bei einer serverseitigen Anbindung mit einer Bandbreite von
$1 frac("Gb", "s")$ resultiert die Übertragung eines 100-GB-Spiels in einer
Kopierzeit von:
$ T("copy") = frac(100 "GB", 1 frac("Gb", "s")) = 800s approx 13.3 "Minuten" $

Zum Vergleich: Der Download eines solchen Spiels durch einen Endnutzer in
Deutschland mit einer durchschnittlichen Geschwindigkeit von
$79.1 frac("Mb", "s")$ @steam-download-stats würde circa 2.8 Stunden dauern:
$
  T("copy") = frac(100 "GB", 79.1 frac("Mb", "s")) approx 10113.8s approx 2.8 "Stunden"
$

Da der Fokus dieser Arbeit auf grafisch anspruchsvollen AAA-Titeln liegt,
werden Spiele mit geringerem Speicherbedarf, bei denen diese Problematik
weniger ausgeprägt ist, in der weiteren Analyse nicht berücksichtigt.

== Skalierbarkeit

Die Cloud-Gaming-Plattform muss eine hohe Skalierbarkeit aufweisen, um
Lastspitzen bei der Veröffentlichung populärer Spieledemos abfangen zu
können. Die Analyse erfolgreicher Demos liefert hierfür wichtige
Anhaltspunkte. So erreichte beispielsweise die Demo zu _Stellar Blade_
Spitzenwerte von rund 25.000 gleichzeitig aktiven Spielern allein auf der
Plattform Steam @steamdb-2025-stellar-blade-charts. Die Infrastruktur muss
demnach für eine solche Nutzerzahl ausgelegt sein, um einen stabilen Betrieb
zu gewährleisten.

#figure(
  image("img/steam_players_stellarblade_demo.svg"),
  caption: [
    _Stellar Blade_ Demo – Gleichzeitig aktive Spieler auf Steam
    @steamdb-2025-stellar-blade-charts
  ],
)

== Kosten pro Nutzer

Ein zentraler Aspekt für die Wirtschaftlichkeit des Betreibermodells sind die
Kosten pro Nutzer. Da das anvisierte Geschäftsmodell auf kostenfreien
Spieledemos basiert, entfällt eine direkte Monetarisierung des Spielvorgangs.
Die Rentabilität muss stattdessen durch nachgelagerte Konversionen, also den
Kauf der Vollversion durch von der Demo überzeugte Spieler, erzielt werden.
Dies erfordert eine strikte Kontrolle der laufenden Betriebskosten.

Für die nachfolgende Machbarkeitsanalyse wird eine Zielgröße für die
Betriebskosten von \$1 pro Stunde und Spieler als Referenzwert definiert. Eine
detaillierte Wirtschaftlichkeitsberechnung durch den Betreiber müsste
Faktoren wie die erwartete Anzahl an Demo-Nutzern, die Konversionsrate zum
Kauf der Vollversion sowie eventuelle Lizenzkosten miteinbeziehen.

== Sicherheit und DRM

Schließlich ist die Gewährleistung der Sicherheit und des Schutzes geistigen
Eigentums eine wesentliche Anforderung. Es müssen effektive Mechanismen des
Digital Rights Management (DRM) implementiert werden, um zu verhindern, dass
Nutzer die Spieldateien von der Plattform extrahieren und unautorisiert
weiterverwenden. Dies dient dem Schutz der Rechte der Spieleentwickler und
Publisher und ist eine Grundvoraussetzung für deren Kooperation.
