= Kernherausforderungen

Die Realisierung einer Cloud-Gaming-Plattform für High-End-Spieledemos ist mit einer Reihe technischer, logistischer und wirtschaftlicher Herausforderungen konfrontiert. Dieses Kapitel analysiert die zentralen Hürden, die für die Konzeption der Systemarchitektur maßgeblich sind.

== Latenz und Bandbreite

Eine der fundamentalsten Hürden für Cloud-Gaming ist die Gewährleistung einer geringen Ende-zu-Ende-Latenz. Jede Millisekunde Verzögerung zwischen der Eingabe des Spielers und der visuellen Rückmeldung auf dem Bildschirm kann die Immersion stören und bei schnellen Spielen über Erfolg oder Misserfolg entscheiden. In der Fachliteratur wird ein Latenzbudget von $≲100 "ms"$ als Obergrenze für eine akzeptable Nutzererfahrung angesehen @choy2012brewing. Das Einhalten dieses Budgets erfordert eine hochoptimierte Übertragungsstrecke vom Rechenzentrum zum Endgerät des Nutzers.

== Hardware-Performance

Um moderne AAA-Titel in hohen Grafikeinstellungen und mit flüssigen Bildraten darzustellen, benötigt jede serverseitige Spielinstanz eine dedizierte, leistungsstarke Grafikkarte (GPU). Hierfür kommen typischerweise Rechenzentrum-GPUs wie die NVIDIA RTX 6000 oder A10G zum Einsatz.

Als Referenz für die Leistungsanforderungen dient beispielsweise die für _The Last of Us Part II Remastered_ auf Endnutzerseite empfohlene NVIDIA GeForce RTX 3060 @thelastofuspart2remastered. In Kombination mit KI-gestützten Technologien wie Frame Generation @dlss4 erreicht diese Karte Bildraten von rund 100 FPS, was ein flüssiges Spielerlebnis sicherstellt @thelastofuspart2remasteredbenchmark.

Es scheint, dass sich der technologische Fokus im High-End-Segment für AAA-Spiele derzeit auf Hardware von NVIDIA konzentriert. Berichten zufolge richten Wettbewerber wie AMD und Intel ihre Strategie auf andere Marktsegmente aus, weshalb NVIDIA-Technologien für die hier betrachteten Anwendungsfälle von besonderer Relevanz sind @alcorn-2024-amd-strategy @jaykihn0-2025-x-post.

== Umgang mit großen Spieldateien

Eine erhebliche logistische Herausforderung stellt das Management der Spieldateien dar. Moderne AAA-Titel erreichen Dateigrößen, die oft zwischen 100 und 200 Gigabyte (GB) liegen, wie die folgende Auswahl verdeutlicht:

- _STAR WARS Jedi: Survivor_ (155 GB) @starwarsjedisurvivor
- _Assassin’s Creed Shadows_ (115 GB) @assassinscreedshadows
- _The Elder Scrolls IV: Oblivion Remastered_ (125 GB) @theelderscrollsoblivionremastered
- _Black Myth: Wukong_ (130 GB) @blackmythwukong
- _God of War Ragnarök_ (190 GB) @godofwarragnark
- _FINAL FANTASY VII REBIRTH_ (155 GB) @finalfantasyviirebirth
- _The Last of Us Part II Remastered_ (150 GB) @thelastofuspart2remastered
- _Dragon Age: The Veilguard_ (100 GB) @dragonagetheveilguard
- _Cyberpunk 2077_ (70 GB) @cyberpunk2077

Diese Datenmengen führen zu beträchtlichen Zeitaufwänden bei der Datenübertragung, etwa bei der initialen Bereitstellung der Spiele auf den Servern. Bei einer serverseitigen Anbindung mit einer Bandbreite von $1 frac("Gb", "s")$ dauert die Übertragung eines 100-GB-Spiels bereits über 13 Minuten:
$T("copy") = frac(100 "GB", 1 frac("Gb", "s")) = 800s approx 13.3 "Minuten"$

Zum Vergleich: Der Download desselben Spiels durch einen Endnutzer in Deutschland mit einer durchschnittlichen Geschwindigkeit von $79.1 frac("Mb", "s")$ @steam-download-stats würde circa 2,8 Stunden in Anspruch nehmen:
$T("copy") = frac(100 "GB", 79.1 frac("Mb", "s")) approx 10113.8s approx 2.8 "Stunden"$

Da der Fokus dieser Arbeit auf grafisch anspruchsvollen AAA-Titeln liegt, werden Spiele mit geringerem Speicherbedarf, bei denen diese Problematik weniger ausgeprägt ist, in der weiteren Analyse nicht berücksichtigt.

== Skalierbarkeit

Die Veröffentlichung einer populären Spieledemo kann zu plötzlichen und massiven Lastspitzen führen. Die Plattformarchitektur muss daher in der Lage sein, flexibel zu skalieren, um Tausenden von Spielern gleichzeitig Zugang zu gewähren. Die Analyse erfolgreicher Demos liefert hierfür wichtige Anhaltspunkte. So erreichte beispielsweise die Demo zu _Stellar Blade_ allein auf der Plattform Steam Spitzenwerte von rund 25.000 gleichzeitig aktiven Spielern @steamdb-2025-stellar-blade-charts. Die Infrastruktur muss für solche Nutzerzahlen ausgelegt sein, um einen stabilen Betrieb zu gewährleisten.

#figure(
  image("img/steam_players_stellarblade_demo.svg"),
  caption: [
    _Stellar Blade_ Demo - Gleichzeitig aktive Spieler auf Steam
    @steamdb-2025-stellar-blade-charts
  ],
)

== Kosten pro Nutzer

Ein zentraler Aspekt für die Wirtschaftlichkeit ist die Kontrolle der Kosten pro Nutzer. Da das anvisierte Geschäftsmodell auf kostenfreien Demos beruht, findet keine direkte Monetarisierung der Spielzeit statt. Die Rentabilität der Plattform hängt somit von nachgelagerten Konversionen ab, also dem Kauf der Vollversion durch Spieler, die von der Demo überzeugt wurden. Dies erfordert eine strikte Kontrolle der laufenden Betriebskosten.

Für die später folgende Machbarkeitsanalyse wird eine Zielgröße für die Betriebskosten von 1 € pro Stunde und Spieler als Referenzwert definiert. Eine detaillierte Wirtschaftlichkeitsberechnung durch den Betreiber müsste weitere Faktoren wie die erwartete Anzahl an Demo-Nutzern, die Konversionsrate zum Kauf der Vollversion sowie eventuelle Lizenzkosten miteinbeziehen.

== Sicherheit und DRM

Der Schutz des geistigen Eigentums ist eine unabdingbare Voraussetzung für die Zusammenarbeit mit Spieleentwicklern und Publishern. Die Plattform muss effektive Mechanismen des Digital Rights Management (DRM) implementieren, um zu verhindern, dass Spieldateien von den Servern extrahiert und unautorisiert verbreitet werden. Dies sichert die Rechte der Urheber und schafft die notwendige Vertrauensbasis für eine Kooperation.
