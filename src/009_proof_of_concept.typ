= Proof of Concept

Im folgenden wird ein Proof of Concept des Streaming Services mit WebRTC implementiert.

== Videoaufzeichnung und Stream-Kodierung

Gängige Tools für diesen Zweck sind: #link("https://ffmpeg.org/")[FFmpeg] und #link("https://gstreamer.freedesktop.org/")[GStreamer].

Diese Arbeit benötigt ein Tool, dass verlässlich den kompletten Bildschirm oder ein einzelnes Fenster mit Ton aufnehmen kann.

Während FFmpeg auf eine große Menge an unterstützten Formaten ausgelegt ist @ffmpeg-formats, ist GStreamer auf geringe Latenz und Hardware Acceleration ausgelegt @gstreamer-vs-ffmpeg.

Mit dem Zeil die geringstmögliche Latenz zu erzielen, wurde GStreamer gewählt.
Die vielen Formate, die FFmpeg unterstützt, wurden nicht benötigt.

== Plattformoptimierung

Um Hardware Acceleration nutzen zu können, müssen für jede Plattform unterschiedliche Optionen für GStreamer mitgegeben werden.
Die genaue Bedeutung kann in der Dokumentation von GStreamer nachgelesen werden.

Die Parameter wurden ausgewählt, indem ein Gemini 2.5 Pro RAG (Retrieval-Augmented Generation) mit der Dokumentation von GStreamer erstellt und nach optimalen Einstellungen für den Anwendungsfall Low-Latency-Stream mit modernen Browsern als Zielplattform gefragt wurde.

Das Betriebssystem (Linux, Mac, Windows) wird über conditional-compilation ausgewählt.
Auf Linux wird zur Laufzeit bestimmt, ob Wayland oder X11 verwendet wird.

=== Linux

==== X11

*ximagesrc* ist eine X11-Quelle, die ein Bild von dem X11-Display erfasst.
Damage wird nicht verwendet, weil Hardware-Encoder wie nvh264enc komplette Frames erwarten.

*video/x-raw,framerate=60/1* ist ein Caps-Filter, der unkomprimierte, Rohe Frames mit 60Hz ausgibt.

*videoconvert* ist eine CPU-basierte Farb- und Format-Konvertierung (z.B. BGRx → I420).

*nvideoconvert* ist eine NVIDIA-spezifische Konvertierung ins “NVMM”-Speicherformat (für Hardware-Encoder).

*video/x-raw(memory:NVMM),width=1920,height=1080* kodiert den im NVIDIA-Video-Memory (NVMM) vorliegenden Videostream zu Full HD (1920x1080) um.

*nvh264enc* ist ein NVIDIA-spezifischer Encoder, der einen H.264-Stream ausgibt.
*preset=low-latency-hq* optimiert für hohe Qualität bei möglichst geringer Latenz.
*tune=zerolatency* verhindert B-Frame Reordering/Buffern.
*rc-mode=cbr-ld-hq* CBR (Constant Bitrate), Low Delay, High Quality.
*bitrate=12000* setzt die Zielbitrate auf $12000 frac("kb", "s")$.

*h264parse* Parsen und ggf. Neuformatieren (Announce von SPS/PPS, NALU-Größen etc.).

*rtph264pay* RTP-Packetizer für H.264.
*config-interval=1* Sendet SPS/PPS (Decoder-Konfigurationsdaten) alle 1 Sekunde neu.
*pt=96* Dynamischer RTP-Payload-Type 96.

*udpsink* UDP-Output.
*host=127.0.0.1* Ziel-IP für den Stream.
*port=5004* Ziel-Port für den Stream.

```
ximagesrc use-damage=false !
video/x-raw,framerate=60/1 !
videoconvert !
nvideoconvert !
'video/x-raw(memory:NVMM),width=1920,height=1080' !
nvh264enc preset=low-latency-hq tune=zerolatency rc-mode=cbr-ld-hq bitrate=12000 !
h264parse !
rtph264pay config-interval=1 pt=96 !
udpsink host=127.0.0.1 port=5004
```

==== Wayland

*pipewiresrc* ist die standard Wayland-Quelle.

*video/x-raw,format=BGRx,framerate=60/1* ist ein Caps-Filter, der unkomprimierte, Rohe Frames mit 60Hz ausgibt.

Ab hier ist die Pipeline wie bei X11 beschrieben.

```
pipewiresrc !
video/x-raw,format=BGRx,framerate=60/1 !
videoconvert !
nvideoconvert !
'video/x-raw(memory:NVMM),width=1920,height=1080' !
nvh264enc preset=low-latency-hq tune=zerolatency rc-mode=cbr-ld-hq bitrate=12000 !
h264parse !
rtph264pay config-interval=1 pt=96 !
udpsink host=127.0.0.1 port=5004
```

=== Mac

*avfvideosrc* AVFoundation-Source auf macOS, nimmt den Bildschirm auf.

*video/x-raw,framerate=60/160/1* ist ein Caps-Filter, der unkomprimierte, Rohe Frames mit 60Hz ausgibt.

*videoscale* CPU-basiertes Skalieren des Bildes.

*video/x-raw,width=1920,height=1080* Setzt die Ausgabeauflösung auf 1920×1080 Pixel.

*vtenc_h264_hw* Apple VideoToolbox H.264 Hardware-Encoder.
*realtime=true* Optimiert für minimale Latenz (verringert interne Pufferung).
*allow-frame-reordering=false* Deaktiviert B-Frame-Reihenfolge → nur I- und P-Frames → weniger Decoder-Delay.
*bitrate=10000* setzt die Zielbitrate auf $10000 frac("kb", "s")$.
*max-keyframe-interval=60* Maximal alle 60 Frames ein Keyframe (bei 60 fps → 1 Keyframe/s).

Ab hier wie bei Linux X11 beschrieben.

```
avfvideosrc capture-screen=true !
video/x-raw,framerate=60/1 !
videoscale !
video/x-raw,width=1920,height=1080 !
vtenc_h264_hw realtime=true allow-frame-reordering=false bitrate=10000 max-keyframe-interval=60 !
h264parse !
rtph264pay config-interval=1 pt=96 !
udpsink host=127.0.0.1 port=5004
```

=== Windows

*d3d11screencapturesrc* Direct3D-11–basierte Bildschirmquelle unter Windows.
Liefert Frames direkt aus der GPU in D3D11-Speicher

*video/x-raw(memory:D3D11Memory),framerate=60/160/1,width=1920,height=1080* ist ein Caps-Filter, der unkomprimierte, Rohe Frames mit 60Hz ausgibt.

*d3d11convert* Konvertiert D3D11-Oberflächen (Farbformat/Pixel-Layout) in ein Format, das downstream weiterverarbeitet werden kann.

Ab hier wie bei Linux X11 beschrieben.

```
d3d11screencapturesrc !
video/x-raw(memory:D3D11Memory),framerate=60/1,width=1920,height=1080 !
d3d11convert !
nvh264enc preset=low-latency-hq tune=zerolatency rc-mode=cbr-ld-hq bitrate=12000 !
h264parse !
rtph264pay config-interval=1 pt=96 !
udpsink host=127.0.0.1 port=5004
```
