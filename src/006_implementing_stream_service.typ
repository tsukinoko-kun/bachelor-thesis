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
Wie das Video kodiert wird, hängt vom Client ab.
Browser unterstützen üblicherweise H.264 (AVC) @caniuse-mpeg4, AV1 @caniuse-av1, VP8, und VP9 @caniuse-webm.

== Evaluierung von Übertragungsprotokollen

Nachfolgend werden verschiedene Übertragungsprotokolle analysiert und hinsichtlich ihrer Eignung für die definierten Anforderungen des Cloud-Gaming-Dienstes bewertet.

=== WebRTC (Web Real-Time Communication)

WebRTC ist ein standardisiertes Protokoll, das nativ in modernen Webbrowsern implementiert ist und keine externen Bibliotheken erfordert.

- Es nutzt STUN/TURN-Server, um Verbindungen auch durch Firewalls und NAT-Gateways (Network Address Translation) herzustellen.
- Die Synchronisation von Audio- und Videoströmen wird durch das zugrundeliegende Real-time Transport Protocol (RTP) und das zugehörige Kontrollprotokoll RTCP automatisch sichergestellt.
- Es ermöglicht eine native bidirektionale Kommunikation für Video, Audio und beliebige Daten.
- Der initiale Verbindungsaufbau, das sogenannte Signaling, muss über einen separaten Kanal (z. B. WebSockets) selbst implementiert werden.
@webrtc-tech

=== SRT (Secure Reliable Transport)

SRT ist ein Open-Source-Protokoll für die Videoübertragung mit geringer Latenz, das häufig im Broadcast-Bereich eingesetzt wird.

- Bietet eine hohe Zuverlässigkeit auch in instabilen Netzwerken.
- Ist primär für Unicast- und Broadcast-Szenarien konzipiert und für interaktives Gaming weniger optimiert, da für die Eingabedaten oft ein separater Kanal erforderlich ist.
- Weist unter idealen Netzwerkbedingungen eine tendenziell höhere Latenz als WebRTC oder MoQ auf.
@rao2024optimizing

=== MoQ (Media over QUIC)

Media over QUIC ist ein neues, auf QUIC basierendes Protokoll (Standardisierung für 2025 angestrebt), das für Media-Streaming mit extrem niedriger Latenz optimiert ist.

- Es verwendet ein Publisher/Subscriber-Modell, das über Relays skaliert, und unterstützt dedizierte Streams für Medien- und Steuerungsdaten.
- Ermöglicht durch QUIC-Multiplexing und einen schnellen Verbindungsaufbau extrem niedrige Latenzen im Bereich von 2 bis 50 ms.
- Die bidirektionale Übertragung von Eingabe- und Zusatzdaten ist über dedizierte Streams möglich, die mit den Video- und Audiodaten synchronisiert werden.
- Befindet sich noch in der Entwicklung (Stand 2025). Obwohl bereits gute Open-Source-Implementierungen existieren, hat es noch nicht die Reife von WebRTC erreicht.
- Setzt eine QUIC-fähige Infrastruktur voraus, die insbesondere in älteren Browsern oder restriktiven Unternehmensnetzwerken nicht immer gegeben ist.
@gurel2023media

=== RoQ (RTP over QUIC)

RTP over QUIC ist eine Erweiterung, die das bewährte Real-Time Protocol (RTP) mit den Vorteilen von QUIC kombiniert, um Streaming mit geringer Latenz zu realisieren.

- Erreicht niedrige Latenzen von ca. 50 ms und gewährleistet eine gute Synchronisation durch die Verwendung von RTP-Timestamps.
- Unterstützt die Übertragung bidirektionaler Daten, wie z. B. Steuerungseingaben, über QUIC-Streams, die mit den Mediendaten integriert werden können.
- Bietet durch die Staukontrolle (Congestion Control) von QUIC eine gute Resilienz gegenüber Netzwerkproblemen.
- Ist als Protokoll weniger etabliert als WebRTC.
- Die Übertragung unkomprimierter Daten erfordert Anpassungen und ist nicht so nahtlos integriert wie bei den Data-Channels von WebRTC.
@mejias2025streaming

=== Ergebnis

SRT bietet eine zu hohe Latenz für Cloud-Gaming-Szenarien.

WebRTC ist sehr komplex aber eine gute und weit verbreitete Lösung.

QUIC ist vergleichsweise neu und die darauf basierenden Protokolle sind viel effizienter als WebRTC.
Ein großer Nachteil ist, dass für QUIC ein SSL-Zertifikat benötigt wird.

MoQ ist noch ein IETF-Draft, also kein final verabschiedeter Standard.
Die Spezifikationen können sich noch ändern.
Das Ökosystem an Tools, fertigen Bibliotheken und Dokumentation ist klein.

RoQ (RTP over QUIC) ist nich umsetzbar, da QUIC noch nicht weit verbreitet ist.
Nicht einmal der aktuelle Curl-Release unterstützt HTTP3.

MoQ kann in der Zukunft zum perfekten Protokoll für Cloud-Gaming werden, aktuell ist es aber aufgrund des Draft-Statuses noch experimentell.
Zudem kommen hier die selben Probleme wie mit RoQ zum Ausdruck.
