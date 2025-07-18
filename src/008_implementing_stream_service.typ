= Implementierung des Streaming-Dienstes

== Analyse der Datenströme

Zunächst wird analysiert, welche Datenarten zwischen dem Streaming-Dienst und dem Frontend ausgetauscht werden müssen. Diese lassen sich in ausgehende und eingehende Datenströme kategorisieren:

- *Ausgehende Daten (Server zu Client):*
  - Bilddaten
  - Audiodaten
  - Gamepad-Vibration (optional)

- *Eingehende Daten (Client zu Server):*
  - Steuerungseingaben (Gamepad, Maus, Tastatur, Touchscreen etc.)

== Notwendigkeit der Datenkomprimierung

Im nächsten Schritt ist zu klären, ob eine Datenkomprimierung für die Übertragung erforderlich ist. Dabei ist zu berücksichtigen, dass der Komprimierungsprozess Latenz verursacht, welche für ein Echtzeitsystem minimiert werden muss. Zur Klärung dieser Frage wird die unkomprimierte Datenmenge des Videostroms berechnet.

Für die Berechnung werden folgende Parameter angenommen: eine Auflösung von Full-HD (1920 x 1080 Pixel), der sRGB-Farbraum (3 Byte pro Pixel) und eine Bildwiederholfrequenz von 60 Bildern pro Sekunde (FPS). Daraus ergibt sich für die reinen Bilddaten folgende Datenmenge:

$1920 * 1080 * 3 = 6220800 frac("Byte", "Frame") approx 6 frac("MiB", "Frame")$

$6220800 frac("Byte", "Frame") * 60 frac("Frames", "s") = 373248000 frac("Byte", "s") approx 356 frac("MiB", "s")$

Ein Vergleich dieses Wertes mit den in der Umfrage ermittelten verfügbaren Bandbreiten der Zielgruppe zeigt, dass bereits die unkomprimierten Bilddaten die Kapazitäten der meisten Nutzer überschreiten. Daraus folgt zwingend die Notwendigkeit einer Datenkomprimierung.

Anschließend muss differenziert werden, welche Daten komprimiert werden sollen. Bild- und Audiodaten eignen sich für eine verlustbehaftete Komprimierung, da geringfügige Informationsverluste von der menschlichen Wahrnehmung kaum bemerkt werden.

Im Gegensatz dazu erfordern die Steuerungseingaben des Spielers sowie die Befehle für die Gamepad-Vibration eine verlustfreie Übertragung, um die Integrität der Aktionen zu gewährleisten. Beide Datenarten weisen jedoch ein sehr geringes Volumen von nur wenigen Bytes pro Übertragung auf. Eine Komprimierung würde hier nur einen marginalen Nutzen erbringen oder wäre aufgrund der geringen Datenmenge pro Paket ineffektiv. Anstelle einer Komprimierung ist hier die Wahl eines effizienten Serialisierungsformats wie Protocol Buffers vorteilhafter.

Folglich konzentriert sich die weitere Betrachtung auf die Übertragung der Bild- und Audiodaten.
Alle anderen Daten werden unkomprimiert, jedoch effizient serialisiert, übertragen.
Wie das Video kodiert werden kann, hängt vom Client ab.
Browser unterstützen üblicherweise H.264 (AVC) @caniuse-mpeg4, AV1 @caniuse-av1, VP8, und VP9 @caniuse-webm.

== Evaluierung von Übertragungsprotokollen

Herkömmliche HTTP-basierte Protokolle wie HTTP Live Streaming (HLS) und Dynamic Adaptive Streaming over HTTP (DASH) führen aufgrund ihres grundlegenden Designs, bei dem Videodaten in größeren, diskreten Segmenten gesendet werden, häufig zu höheren Latenzzeiten. @ioriver-low-latency So sind typische HLS-Segmente mindestens 2 Sekunden lang und können, wenn sie gruppiert werden, zu effektiven Latenzzeiten von 6 Sekunden oder mehr führen. @castr-video-latency

Nachfolgend werden verschiedene Übertragungsprotokolle analysiert und hinsichtlich ihrer Eignung für die definierten Anforderungen des Cloud-Gaming-Dienstes bewertet.

=== WebRTC (Web Real-Time Communication)

WebRTC ist ein standardisiertes Protokoll, das nativ in modernen Webbrowsern implementiert ist und dort keine externen Bibliotheken erfordert. @webrtc-tech
Es nutzt in erster Linie das UDP wegen seiner inhärenten Geschwindigkeit. Ergänzend zu UDP wird das RTP (Real-Time Transport Protocol) verwendet, um wesentliche Funktionen für Medienströme hinzuzufügen, darunter Zeitstempel, Sequenzierung und Zustellungsüberwachung, die für die Synchronisierung entscheidend sind. @flussonic-webrtc
UDP bietet zwar eine hohe Geschwindigkeit, aber die fehlende Zustellungsgarantie kann in sehr restriktiven NAT-Umgebungen (Network Address Translation) zu Problemen führen. @nat-traversal-webrtc
WebRTC stellt Peer-to-Peer-Verbindungen zwischen kommunizierenden Geräten her. Diese Architektur minimiert die Anzahl der in den Kommunikationspfad involvierten Hops, was die Latenzzeit unter idealen Netzwerkbedingungen erheblich reduziert. @webrtc-tech

Es stellt eine solide Möglichkeit für Game-Streaming dar und wurde auch beim Game-Streaming-Dienst Google Stadia eingesetzt. @di2021network

=== SRT (Secure Reliable Transport)

Latenz von 300 ms bis 500 ms ist zu viel für Game-Streaming. @srt-ossrs

=== MoQ (Media over QUIC) und RoQ (RTP over QUIC)

QUIC basierte Protokolle wie MoQ und RoQ versprechen geringere Latenzen als WebRTC und sind damit perfekt für Game-Streaming geeignet, sie sind jedoch noch sehr experimentell und es gibt keine APIs in Browsern, was die Implementierung deutlich aufwändiger macht. @gurel2023media @mejias2025streaming

=== Ergebnis

SRT bietet eine zu hohe Latenz für Cloud-Gaming-Szenarien.

WebRTC ist sehr komplex aber eine gute und weit verbreitete Lösung.
Dass der Client bereits als Browser-APIs verfügbar ist, erleichtert die Implementierung und reduziert Fehlerquellen.
Dass sich Google für dieses Protokoll entschieden hat, zeigt, dass es eine gute Wahl ist.

QUIC ist vergleichsweise neu und die darauf basierenden Protokolle sind viel effizienter als WebRTC.
Die Neuheit ist es auch, was es schwieriger macht, diese Protokolle zu implementieren.
Dieser Arbeit fehlen die Ressourcen, um die neuen, QUIC basierten Protokolle umsetzen zu können.
Dadurch, dass sowohl Server, als auch Client implementiert werden müssen, ist vor allem zu Beginn der Implementierung nicht klar, ob Probleme am Client oder Server liegen.
Ein performanter Client müsste zudem in WebAssembly implementiert werden, um die zwangsläufige Latenz von JavaScript zu umgehen.
Die naheliegendsten Programmiersprachen für diesen Client wären Rust, Zig und C (keine Garbage Collection).

Die Wahl fällt aufgrund der angebrachten Punkte auf WebRTC.
Sobald mehr Tooling für QUIC verfügbar ist, würde sich das aber ändern.

== Architektur

#figure(
  image("img/c3.jpg"),
  caption: "C4-Modell - Component",
)
