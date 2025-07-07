= Kernherausforderungen

Die Realisierung von Cloud-Gaming-Systemen steht vor einer Reihe signifikanter Herausforderungen, die im Folgenden detailliert erörtert werden.

== Umfangreiche Binärdateien

Aktuelle AAA-Titel weisen eine beträchtliche Größe von etwa 100 bis 200 GB pro Spiel auf:

- STAR WARS Jedi: Survivor (155 GB) @starwarsjedisurvivor
- Assassin’s Creed Shadows (115 GB) @assassinscreedshadows
- The Elder Scrolls IV: Oblivion Remastered (125 GB) @theelderscrollsoblivionremastered
- Black Myth: Wukong (130 GB) @blackmythwukong
- God of War Ragnarök (190 GB) @godofwarragnark
- FINAL FANTASY VII REBIRTH (155 GB) @finalfantasyviirebirth
- The Last of Us Part II Remastered (150 GB) @thelastofuspart2remastered
- Dragon Age: The Veilguard (100 GB) @dragonagetheveilguard
- Cyberpunk 2077 (70 GB) @cyberpunk2077

Dies führt zu einer nicht unerheblichen Zeit für das einfache Kopieren der Spieldateien. Beispielsweise ergibt sich bei einer Bandbreite von $1 frac("Gb", "s")$ und Spieldaten von $100 "GB"$ eine Kopierzeit von $T("copy") = frac(100 "GB", 1 frac("Gb", "s")) = 800s approx 13.3 "Minuten"$.

Wenn ein Spieler in Deutschland ein Spiel von Steam herunterlädt, geschieht das durchschnittlich mit $79.1 frac("Mb", "s")$ @steam-download-stats, was bei einer Spielgröße von $100 "GB"$ eine Kopierzeit von $T("copy") = frac(100 "GB", 79.1 frac("Mb", "s")) approx 10113.8s approx 2.8 "Stunden"$ entspricht.

Bei kleineren Spielen fällt dieses Problem weg, sie werden daher für dieses Problem nicht weiter behandelt.

== Hardware-Performance

Jede Spiel-Session erfordert eine moderne GPU, beispielsweise eine RTX 6000 oder A10G, um AAA-Titel mit hohen Einstellungen flüssig darstellen zu können.

Eine empfohlene Grafikkarte (für Endnutzer) ist beispielsweise die NVIDIA GeForce RTX 3060 @thelastofuspart2remastered. Diese Grafikkarte erreicht bei "The Last of Us Part II Remastered" mit KI-Features wie Frame Generation @dlss4 etwa 100 FPS @thelastofuspart2remasteredbenchmark, was ausreichend ist.

Nvidia Hardware ist bei AAA-Spielen zu bevorzugen, da die Konkurrenz (AMD und Intel) in absehbarer Zukunft nicht am High-End-Markt interessiert ist. @alcorn-2024-amd-strategy @jaykihn0-2025-x-post

Nvidia bietet aktuell folgende Technologien an, die für gute Performance bei grafisch anspruchsvollen Spielen sorgen:

=== Multi Frame Generation

Multi Frame Generation ist ein fortschrittliches Verfahren zur Synthese von Bildern, das darauf abzielt, die wahrgenommene Bildwiederholrate (Framerate) signifikant zu erhöhen. Im Gegensatz zur Generierung eines einzelnen Zwischenbildes, wie es bei früheren Implementierungen der Fall war, ist diese Technik in der Lage, mehrere Bilder zwischen zwei von der Game-Engine gerenderten Frames zu interpolieren. Unter Verwendung von Bewegungsvektoren, optischen Flussfeldern und temporalen Daten aus vorangegangenen Bildern rekonstruiert ein neuronales Netz eine Sequenz von Zwischenbildern. Das primäre Ziel ist die Erzeugung einer extrem flüssigen Bewegungswahrnehmung, die weit über die native Renderleistung der Hardware hinausgeht, insbesondere in CPU-limitierten Szenarien. @dlss4

=== Transformer-basierte Ray Reconstruction

Die Transformer-basierte Ray Reconstruction (TRR) ist eine Methode zur Rauschunterdrückung (Denoising) und Detailrekonstruktion von Ray-Tracing-Effekten, die auf einer Transformer-Architektur basiert. Anstelle von konventionellen Faltungsnetzwerken (CNNs) nutzt TRR die Fähigkeit von Transformern, globale Bildkontexte und langreichweitige Abhängigkeiten zwischen Pixeln zu analysieren. Dadurch kann das Modell fehlende oder verrauschte Lichtinformationen (z.B. Reflexionen, Schatten, globale Beleuchtung) mit höherer Genauigkeit und Kohärenz wiederherstellen. Das Resultat ist eine visuell präzisere und artefaktärmere Darstellung von Ray-Tracing-Effekten im Vergleich zu früheren Denoising-Verfahren. @dlss4

=== Transformer-basierte Super Resolution

Transformer-basiertes Super Resolution (TSR) beschreibt den Prozess der Hochskalierung eines niedrig aufgelösten Bildes auf eine höhere Zielauflösung mittels eines Transformer-Modells. Ähnlich wie bei der Ray Reconstruction nutzt diese Technik die Stärke von Transformern bei der Erfassung globaler Kontexte. Durch die Analyse von niedrig aufgelösten Eingabebildern, Bewegungsvektoren und historischer Bilddaten rekonstruiert das neuronale Netz ein hochaufgelöstes Bild. Der Vorteil gegenüber CNN-basierten Ansätzen liegt in der potenziell überlegenen Rekonstruktion von feinen Texturen und komplexen Mustern sowie einer verbesserten temporalen Stabilität, da das Modell logische Zusammenhänge über größere Bildbereiche hinweg herstellen kann. @dlss4

=== Reflex Frame Warp

Reflex Frame Warp ist eine Latenzkompensationstechnik, die speziell für den Einsatz mit Frame-Generation-Verfahren entwickelt wurde. Die durch die Interpolation von Bildern entstehende zusätzliche Latenz wird durch dieses Verfahren aktiv reduziert. Unmittelbar bevor ein generiertes Bild an den Monitor gesendet wird, erfasst das System die aktuellsten Eingabedaten des Nutzers (z.B. Mausbewegungen). Basierend auf diesen Daten wird das bereits fertiggestellte Bild minimal verzerrt ("warped"), um die Darstellung an die letzte bekannte Spieleraktion anzugleichen. Dieser Prozess korrigiert die Diskrepanz zwischen der angezeigten Bildinformation und der Intention des Spielers und reduziert somit die wahrgenommene "Input-to-Photon"-Latenz. @dlss4

== Latenz und Bandbreite

Eine geringe Latenz ist entscheidend für ein reaktionsschnelles Spielerlebnis. Das End-to-End-Budget sollte ≲100 ms betragen. @choy2012brewing

== Kosten pro Nutzer

Da es das Ziel ist, Demos über Cloud Gaming anzubieten, werden die Konsumenten kein Geld dafür bezahlen. Für die Betreiber muss es also so günstig wie möglich sein, damit sie Gewinn erwirtschaften.

Ein Ziel von \$1 pro Stunde pro Spieler wird für die Machbarkeitsanalyse frei gewählt um eine grobe Einschätzung zu bekommen. Die Betreiber müssten selbst kalkulieren wie viele Spieler sie an den Demos haben was das komplette Spiel kostet und wie viele Spieler sich von der Demo überzeugen lassen, um das volle Spiel zu kaufen.

== Skalierbarkeit

Schaut man sich eine erfolgreiche Demo, wie die von Stellar Blade (89,18% positive Bewertungen auf Steam) an, lässt sich feststellen, dass die Plattform auf etwa 25000 gleichzeitig aktive Spieler skalieren können muss. @steamdb-2025-stellar-blade-charts

#figure(
  image("img/steam_players_stellarblade_demo.svg"),
  caption: [Stellar Blade Demo - Gleichzeitig aktive Spieler auf Steam @steamdb-2025-stellar-blade-charts],
)

== Sicherheit und DRM

Es muss verhindert werden, dass Benutzer die Spieldateien extrahieren und verwenden können.
