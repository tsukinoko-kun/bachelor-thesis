= Proof of Concept

Zur Validierung des im vorherigen Kapitel konzipierten Streaming-Dienstes wurde ein Proof of Concept (PoC) implementiert. Dieses Kapitel dokumentiert die technische Umsetzung der Kernkomponenten, die für eine latenzarme Übertragung des Spielgeschehens verantwortlich sind. Der Fokus liegt dabei auf der Auswahl des Media-Frameworks, der plattformspezifischen Konfiguration der Video-Pipeline und der Übertragung von Steuerungseingaben.

#let anchor(dest, label) = {
  text(fill: blue)[#link(dest)[#emph(underline(label))]]
}

Source Code: #anchor("https://gitlab.com/tsukinoko-kun/bachelor-thesis-poc", [gitlab.com/tsukinoko-kun/bachelor-thesis-poc])

Mirror: #anchor("https://github.com/tsukinoko-kun/bachelor-thesis-poc", [github.com/tsukinoko-kun/bachelor-thesis-poc])

== Videoaufzeichnung und Stream-Kodierung

Eine zentrale Anforderung ist die Fähigkeit, den Bildschirminhalt oder ein spezifisches Anwendungsfenster mitsamt Ton zuverlässig aufzuzeichnen und für das Streaming zu kodieren. Zwei etablierte Open-Source-Frameworks kommen für diese Aufgabe infrage: #link("https://ffmpeg.org/")[FFmpeg] und #link("https://gstreamer.freedesktop.org/")[GStreamer].

Während FFmpeg für seine umfassende Unterstützung einer breiten Palette von Formaten und Codecs bekannt ist @ffmpeg-formats, liegt der Designfokus von GStreamer auf der Erstellung modularer, latenzarmer Multimedia-Pipelines und der tiefen Integration von Hardware-Beschleunigung @gstreamer-vs-ffmpeg. Da für den anvisierten Anwendungsfall des Cloud-Gamings die Minimierung der Latenz von entscheidender Bedeutung ist und die breite Formatunterstützung von FFmpeg nicht benötigt wird, fiel die Wahl auf GStreamer.

== Plattformspezifische Pipeline-Konfiguration

Um die bestmögliche Performance zu erzielen, ist die Nutzung von Hardware-Beschleunigung für die Videokodierung unerlässlich. Dies erfordert die Erstellung spezifischer GStreamer-Pipelines, die auf die jeweiligen Grafik-APIs und Treiber der Zielbetriebssysteme (Linux, macOS, Windows) zugeschnitten sind.

Zur Ermittlung der optimalen Parameter für die GStreamer-Elemente wurde ein auf der offiziellen GStreamer-Dokumentation trainiertes Retrieval-Augmented Generation (RAG) Modell auf Basis von Gemini 2.5 Pro konsultiert. Die Fragestellung zielte auf die bestmögliche Konfiguration für einen Low-Latency-Stream ab, der für moderne Webbrowser als Client-Plattform bestimmt ist. Die daraus resultierenden Vorschläge dienten als Grundlage für die hier vorgestellten Pipelines.

Die Auswahl der korrekten Pipeline erfolgt zur Kompilierzeit basierend auf dem Zielbetriebssystem. Unter Linux wird zur Laufzeit zusätzlich geprüft, ob Wayland oder X11 als Display-Server aktiv ist.

=== Linux

==== X11
Die Pipeline für X11 nutzt `ximagesrc` zur Erfassung des Bildschirminhalts. Die Option `use-damage=false` wird gesetzt, da Hardware-Encoder wie `nvh264enc` vollständige Frames erwarten und keine partiellen Updates verarbeiten können. Ein Caps-Filter (`video/x-raw,framerate=60/1`) erzwingt eine konstante Bildrate von 60 FPS.

Die nachfolgenden Elemente `videoconvert` und `nvideoconvert` übernehmen die CPU- und GPU-seitige Konvertierung des Bildmaterials in das für den NVIDIA-Hardware-Encoder erforderliche NVMM-Speicherformat. Der Encoder `nvh264enc` wird mit Parametern konfiguriert, die auf eine hohe Qualität bei minimaler Latenz abzielen (`preset=low-latency-hq`, `tune=zerolatency`). Der Rate-Control-Modus `cbr-ld-hq` (Constant Bitrate, Low Delay, High Quality) sorgt für einen stabilen Videostream mit einer Zielbitrate von $12000 frac("kb", "s")$.

Schließlich bereiten `h264parse` und `rtph264pay` den H.264-Stream für die Übertragung über RTP vor, indem sie ihn paketieren und regelmäßig Konfigurationsdaten (SPS/PPS) senden. Das `appsink`-Element mit dem Namen `rtpsink` dient als Endpunkt der Pipeline und übergibt die RTP-Pakete an die Go-Anwendung zur Weiterleitung via WebRTC.

```
ximagesrc use-damage=false !
video/x-raw,framerate=60/1 !
videoconvert !
nvideoconvert !
'video/x-raw(memory:NVMM),width=1920,height=1080' !
nvh264enc preset=low-latency-hq tune=zerolatency rc-mode=cbr-ld-hq bitrate=12000 !
h264parse !
rtph264pay config-interval=1 pt=96 !
appsink name=rtpsink
```

==== Wayland
Unter Wayland wird `pipewiresrc` als standardisierte Quelle für die Bildschirmaufnahme verwendet. Abgesehen von diesem Eingabeelement ist die restliche Pipeline identisch zu der für X11, da die nachfolgende Verarbeitung auf der GPU stattfindet und vom Display-Server unabhängig ist.

```
pipewiresrc !
video/x-raw,format=BGRx,framerate=60/1 !
videoconvert !
nvideoconvert !
'video/x-raw(memory:NVMM),width=1920,height=1080' !
nvh264enc preset=low-latency-hq tune=zerolatency rc-mode=cbr-ld-hq bitrate=12000 !
h264parse !
rtph264pay config-interval=1 pt=96 !
appsink name=rtpsink
```

=== macOS
Auf macOS kommt die `avfvideosrc`-Quelle zum Einsatz, die auf dem nativen AVFoundation-Framework basiert. Die Auflösung wird mittels `videoscale` auf eine Standardauflösung von 1920x1080 Pixel skaliert.

Die Hardware-Kodierung erfolgt durch `vtenc_h264_hw`, den Encoder des Apple VideoToolbox-Frameworks. Die Parameter `realtime=true` und `allow-frame-reordering=false` sind entscheidend, um interne Puffer zu minimieren und die Latenz zu reduzieren. Die Zielbitrate wird auf $10000 frac("kb", "s")$ gesetzt. Die restlichen Elemente der Pipeline entsprechen denen der Linux-Version.

```
avfvideosrc capture-screen=true !
video/x-raw,framerate=60/1 !
videoscale !
video/x-raw,width=1920,height=1080 !
vtenc_h264_hw realtime=true allow-frame-reordering=false bitrate=10000 max-keyframe-interval=60 !
h264parse !
rtph264pay config-interval=1 pt=96 !
appsink name=rtpsink
```

=== Windows
Für Windows wird die `d3d11screencapturesrc` verwendet, eine performante Quelle, die direkt auf der Direct3D-11-API aufsetzt und die Bilddaten im GPU-Speicher belässt. Dies macht eine explizite Konvertierung wie bei der X11-Pipeline überflüssig und reduziert die CPU-Last.

Das `d3d11convert`-Element sorgt für die notwendige Farbformatkonvertierung innerhalb des D3D11-Speichers. Ab dem `nvh264enc`-Encoder ist die Pipeline wieder identisch zur Linux-Variante, da sie auf den plattformübergreifenden NVIDIA-Treiber aufsetzt.

```
d3d11screencapturesrc !
'video/x-raw(memory:D3D11Memory), framerate=60/1,width=1920,height=1080' !
d3d11convert !
nvh264enc preset=low-latency-hq tune=zerolatency rc-mode=cbr-ld-hq bitrate=12000 !
h264parse !
rtph264pay config-interval=1 pt=96 !
appsink name=rtpsink
```

== Übertragung der Steuerungseingaben

Für die Übertragung der Spielereingaben (Maus und Tastatur) vom Client zum Server werden die von WebRTC bereitgestellten Data Channels genutzt @webrtc-data-channels. Diese ermöglichen den Versand beliebiger Daten parallel zum Audio- und Videostream. Sie können für eine geringe Latenz konfiguriert werden (unzuverlässig und ungeordnet), was für die Übermittlung von Eingabedaten ideal ist. Sollte der Aufbau eines Data Channels, beispielsweise aufgrund restriktiver Netzwerk-Firewalls, fehlschlagen, wird als Fallback-Lösung eine WebSocket-Verbindung etabliert.

== Fokus des Proof of Concept und Testumgebung

Um die Komplexität des PoC zu reduzieren und sich auf die Validierung der Kernfunktionalität – die latenzarme Videoübertragung – zu konzentrieren, wurden bewusst einige Vereinfachungen vorgenommen. Auf das Streaming von Audiodaten sowie auf die Möglichkeit, die Aufnahme auf ein einzelnes Anwendungsfenster zu beschränken, wurde verzichtet. Diese Funktionen sind für die grundsätzliche Machbarkeitsprüfung nicht essenziell.

Die Tests wurden in einer heterogenen Umgebung durchgeführt, die ein typisches Nutzungsszenario widerspiegelt. Als Server diente ein MacBook Pro (M4 Max, 16-Core CPU, 64 GB RAM), während als Client ein Windows-Laptop mit einer AMD Ryzen 5 5500U CPU und integrierter Radeon RX Vega 7 GPU zum Einsatz kam. Diese Konfiguration dient als Grundlage für die im folgenden Kapitel beschriebenen Akzeptanztests.
