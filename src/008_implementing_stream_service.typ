= Implementierung des Streaming-Dienstes

Nachdem die übergeordnete Systemarchitektur definiert wurde, befasst sich dieses Kapitel mit der konkreten technischen Ausgestaltung des Streaming-Dienstes. Dieser bildet die Kernkomponente, die auf jeder EC2-Instanz ausgeführt wird, um eine einzelne Spielsitzung zu ermöglichen. Die Implementierung erfordert zunächst eine genaue Analyse der zu übertragenden Datenströme und die Auswahl geeigneter Protokolle und Kodierungsverfahren.

== Analyse der Datenströme

Die Kommunikation zwischen dem Server, auf dem das Spiel läuft, und dem Client des Nutzers umfasst mehrere Datenarten. In ausgehender Richtung, vom Server zum Client, müssen primär die Bild- und Audiodaten des Spiels übertragen werden. Optional können auch haptische Rückmeldungen, wie Gamepad-Vibrationen, gesendet werden. In der Gegenrichtung, vom Client zum Server, werden die Steuerungseingaben des Spielers übermittelt, die von Geräten wie Gamepads, Maus, Tastatur oder Touchscreens stammen können.

== Notwendigkeit der Datenkomprimierung

Im nächsten Schritt wird geprüft, ob eine Datenkomprimierung für die Übertragung erforderlich ist. Dabei ist zu berücksichtigen, dass der Komprimierungsprozess selbst Latenz verursacht, die in einem Echtzeitsystem minimiert werden muss. Eine Berechnung der unkomprimierten Datenmenge des Videostroms liefert hierfür eine Entscheidungsgrundlage.

Unter Annahme einer Full-HD-Auflösung (1920x1080 Pixel), des sRGB-Farbraums (3 Byte pro Pixel) und einer Bildwiederholrate von 60 Bildern pro Sekunde (FPS) ergibt sich für die reinen Bilddaten folgende Datenmenge:

$$ 1920 times 1080 times 3 = 6220800 frac("Byte", "Frame") approx 6 frac("MiB", "Frame") $$
$$ 6220800 frac("Byte", "Frame") times 60 frac("Frames", "s") = 373248000 frac("Byte", "s") approx 356 frac("MiB", "s") $$

Ein Vergleich dieses Werts mit den in der Umfrage ermittelten Bandbreiten der Zielgruppe macht deutlich, dass die unkomprimierten Bilddaten die verfügbaren Kapazitäten der meisten Nutzer bei Weitem übersteigen würden. Eine effiziente Datenkomprimierung ist daher unumgänglich.

Dabei muss jedoch zwischen den verschiedenen Datenarten unterschieden werden. Bild- und Audiodaten eignen sich gut für eine verlustbehaftete Komprimierung, da die menschliche Wahrnehmung für geringfügige Informationsverluste tolerant ist. Im Gegensatz dazu erfordern Steuerungseingaben und Vibrationsbefehle eine verlustfreie Übertragung, um die Integrität der Spieleraktionen zu sichern. Aufgrund ihres geringen Datenvolumens von nur wenigen Bytes pro Paket würde eine Komprimierung hier jedoch kaum einen Vorteil bieten. Stattdessen ist die Wahl eines effizienten Serialisierungsformats wie Protocol Buffers zielführender.

Die weitere Betrachtung konzentriert sich somit auf die Komprimierung und Übertragung der Bild- und Audiodaten. Die Wahl des Videocodecs wird dabei maßgeblich von der Client-Plattform, in diesem Fall dem Webbrowser, bestimmt. Gängige Browser unterstützen Codecs wie H.264 (AVC) @caniuse-mpeg4, AV1 @caniuse-av1 sowie VP8 und VP9 @caniuse-webm.

== Evaluierung von Übertragungsprotokollen

Die Wahl des Übertragungsprotokolls ist entscheidend für die Ende-zu-Ende-Latenz. Herkömmliche HTTP-basierte Protokolle wie HLS und DASH sind für diesen Anwendungsfall ungeeignet. Ihr Design, das auf der Übertragung von Videodaten in mehreren Sekunden langen Segmenten basiert, führt zu Latenzen, die für interaktives Gaming inakzeptabel sind @ioriver-low-latency @castr-video-latency. Nachfolgend werden daher Protokolle analysiert, die für Echtzeitanwendungen konzipiert sind.

=== WebRTC (Web Real-Time Communication)

WebRTC ist ein standardisiertes Framework, das nativ in modernen Webbrowsern implementiert ist und keine externen Bibliotheken auf der Client-Seite erfordert @webrtc-tech. Es nutzt primär UDP für eine schnelle Übertragung und ergänzt es um das Real-Time Transport Protocol (RTP), das essenzielle Funktionen wie Zeitstempel und Sequenznummern für die Mediensynchronisation bereitstellt @flussonic-webrtc. Durch den Aufbau von direkten Peer-to-Peer-Verbindungen minimiert WebRTC die Anzahl der Hops im Kommunikationspfad, was die Latenz unter idealen Bedingungen erheblich reduziert. Obwohl die fehlende Zustellungsgarantie von UDP in restriktiven NAT-Umgebungen zu Problemen führen kann @nat-traversal-webrtc, stellt WebRTC eine etablierte und leistungsfähige Lösung dar, die unter anderem auch beim Cloud-Gaming-Dienst Google Stadia zum Einsatz kam @di2021network.

=== SRT (Secure Reliable Transport)

Das SRT-Protokoll wurde für eine zuverlässige Videoübertragung über unzuverlässige Netzwerke entwickelt. Die dabei erzielten Latenzzeiten liegen jedoch typischerweise im Bereich von 300 ms bis 500 ms, was für den reaktionskritischen Anwendungsfall des Game-Streamings deutlich zu hoch ist @srt-ossrs.

=== MoQ (Media over QUIC) und RoQ (RTP over QUIC)

QUIC-basierte Protokolle wie MoQ und RoQ sind neuere Entwicklungen, die potenziell geringere Latenzen als WebRTC versprechen und damit für Game-Streaming sehr gut geeignet wären @gurel2023media @mejias2025streaming. Ihr Einsatz ist jedoch mit erheblichen Hürden verbunden: Sie sind noch experimentell, und es existieren keine standardisierten Browser-APIs, was die Implementierung auf Client-Seite deutlich erschwert.

=== Ergebnis der Evaluierung

Die Analyse der Protokolle führt zu einer klaren Entscheidung. SRT scheidet aufgrund seiner für interaktives Gaming ungeeigneten Latenzcharakteristik aus. Die Wahl reduziert sich somit auf einen pragmatischen Kompromiss zwischen der etablierten WebRTC-Technologie und den vielversprechenden, aber noch experimentellen QUIC-basierten Protokollen.

Obwohl Protokolle wie MoQ und RoQ potenziell geringere Latenzen als WebRTC bieten, ist ihre Implementierung mit erheblichem Mehraufwand und Risiko verbunden. Das Fehlen nativer Browser-APIs würde die Entwicklung eines eigenen Clients, idealerweise in WebAssembly, erfordern, um die Performance-Nachteile von JavaScript zu umgehen. Dies würde den Rahmen dieser Arbeit überschreiten und die Fehlersuche erschweren.

WebRTC stellt hingegen eine ausgereifte und praxiserprobte Lösung dar. Die native Integration in alle modernen Browser vereinfacht die Client-seitige Implementierung erheblich und reduziert potenzielle Fehlerquellen. Die Tatsache, dass ein großer Dienst wie Google Stadia auf diese Technologie setzte, unterstreicht ihre Eignung für den Anwendungsfall.

Aus diesen Gründen fällt die Wahl auf WebRTC. Es bietet die beste Balance aus geringer Latenz, breiter Kompatibilität und überschaubarem Implementierungsaufwand. Es ist jedoch anzumerken, dass sich diese Entscheidung in Zukunft ändern könnte, sobald die QUIC-basierten Protokolle und das zugehörige Tooling einen höheren Reifegrad erreichen.

== Komponentenarchitektur des Streaming-Dienstes

Basierend auf der Entscheidung für WebRTC lässt sich die Komponentenarchitektur des auf der EC2-Instanz laufenden Streaming-Dienstes ableiten. Das nachfolgende Diagramm visualisiert das Zusammenspiel der einzelnen Software-Komponenten, die für die Erfassung, Kodierung und Übertragung des Spiels verantwortlich sind.

#figure(
  image("img/c3.jpg"),
  caption: "C4-Modell: Komponenten des Streaming-Dienstes (C3)",
)

Die Architektur gliedert sich in mehrere logische Bausteine:

- *Spiele-Prozess:* Die eigentliche ausführbare Datei des Spiels, die auf der EC2-Instanz gestartet wird.
- *Video- und Audio-Capture:* Eine Komponente, die für die Aufnahme des Bildschirminhalts und des System-Audios zuständig ist. Wie im folgenden Kapitel detailliert wird, eignet sich hierfür ein flexibles Media-Framework wie GStreamer.
- *Hardware-Encoder:* Um die CPU der Instanz zu entlasten und eine geringe Kodierungslatenz zu gewährleisten, wird der Video-Stream direkt an den Hardware-Encoder der NVIDIA-GPU übergeben. Dieser komprimiert die Rohdaten in einen H.264-Stream.
- *WebRTC-Server:* Dies ist die zentrale Anwendung, die die WebRTC-Verbindung zum Client verwaltet. Sie empfängt den kodierten Videostream vom Encoder, paketiert ihn für die Übertragung via RTP und sendet ihn an den Client.
- *Data Channel Handler:* Innerhalb der WebRTC-Verbindung wird ein separater Datenkanal etabliert. Dieser empfängt die Steuerungseingaben (Maus, Tastatur) vom Client und leitet sie an das Betriebssystem der Instanz weiter, um das Spiel zu steuern.
- *Signaling-Server:* Obwohl nicht Teil der EC2-Instanz selbst, ist ein externer Signaling-Server notwendig, um die Metadaten für den Aufbau der Peer-to-Peer-Verbindung zwischen dem Client und dem WebRTC-Server auszutauschen.

Diese Komponentenarchitektur stellt sicher, dass die Verarbeitungspipeline vom Capturing bis zur Auslieferung hochoptimiert ist, um die Ende-zu-Ende-Latenz zu minimieren. Die konkrete Umsetzung dieser Komponenten wird im nachfolgenden Kapitel beschrieben.
