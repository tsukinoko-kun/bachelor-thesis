= Kernherausforderungen

Die Realisierung von Cloud-Gaming-Systemen steht vor einer Reihe signifikanter Herausforderungen, die im Folgenden detailliert erörtert werden.

== Umfangreiche Binärdateien

Aktuelle AAA-Titel weisen eine beträchtliche Größe von etwa 100 bis 200 GB pro Spiel auf:

- STAR WARS Jedi: Survivor™ (155 GB) @starwarsjedisurvivor
- Assassin’s Creed Shadows (115 GB) @assassinscreedshadows
- The Elder Scrolls IV: Oblivion Remastered (125 GB) @theelderscrollsoblivionremastered
- Black Myth: Wukong (130 GB) @blackmythwukong
- God of War Ragnarök (190 GB) @godofwarragnark
- FINAL FANTASY VII REBIRTH (155 GB) @finalfantasyviirebirth
- The Last of Us™ Part II Remastered (150 GB) @thelastofuspart2remastered
- Dragon Age™: The Veilguard (100 GB) @dragonagetheveilguard
- Cyberpunk 2077 (70 GB) @cyberpunk2077

Dies führt zu einer nicht unerheblichen Zeit für das einfache Kopieren der Spieldateien. Beispielsweise ergibt sich bei einer Bandbreite von $1 frac("Gb", "s")$ und Spieldaten von $100 "GB"$ eine Kopierzeit von $T("copy") = frac(100 "GB", 1 frac("Gb", s)) = 800s approx 13.3 "Minuten"$.

== Hardware-Performance

Jede Spielsession erfordert eine moderne GPU, beispielsweise eine RTX 6000 oder A10G, um AAA-Titel mit hohen Einstellungen flüssig darstellen zu können.

Eine empfohlene Grafikkarte ist beispielsweise die NVIDIA GeForce RTX 3060 @thelastofuspart2remastered. Diese Grafikkarte erreicht bei "The Last of Us™ Part II Remastered" mit KI-Features wie Frame Generation etwa 100 FPS @thelastofuspart2remasteredbenchmark, was ausreichend ist.

== Latenz und Bandbreite

Eine geringe Latenz ist entscheidend für ein reaktionsschnelles Spielerlebnis. Das End-to-End-Budget sollte ≲100 ms betragen. Die benötigte Videobandbreite liegt bei etwa 10 Mb/s für 1080p60-Streaming. Eine präzise Jitter-Kontrolle ist unerlässlich, um ein stabiles Streaming zu gewährleisten.

== Kosten pro Nutzer

Das Ziel ist, die Kosten pro Nutzer auf \(\$1\)–10 pro Stunde zu begrenzen. Die Testinfrastruktur sollte idealerweise "kostenlos" oder sehr kostengünstig sein.

== Skalierbarkeit

Die Skalierung auf O(200) gleichzeitige Sitzungen erfordert eine ausgeklügelte Orchestrierung, Autoscaling-Mechanismen und die Entscheidung zwischen gepoolten und sitzungsgebundenen Ressourcen.

== Persistenz

Spielstände müssen auch nach Beendigung einer Instanz erhalten bleiben. Dies erfordert robuste Speichermechanismen.

== Sicherheit und DRM

Es muss verhindert werden, dass Benutzer die Spieldateien aus dem Stream extrahieren können. Dies erfordert effektive Sicherheits- und DRM-Maßnahmen.

