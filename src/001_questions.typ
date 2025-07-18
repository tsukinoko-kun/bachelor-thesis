= Forschungsfragen

Die vorliegende Arbeit verfolgt das Ziel, die Konzeption und Realisierbarkeit einer spezialisierten Cloud-Gaming-Plattform für Spieledemos zu untersuchen. Aus dieser Zielsetzung leitet sich die folgende Hauptforschungsfrage (HFF) ab:

#box(width: 100%, inset: 8pt, stroke: 1pt)[
  *HFF: Wie muss eine Cloud-Gaming-Plattform architektonisch und technologisch konzipiert sein, um High-End-Spieledemos performant auf Low-End-Geräten bereitzustellen, und welche Implikationen ergeben sich daraus für Nutzer sowie Betreiber?*
]

Zur systematischen Beantwortung dieser übergeordneten Frage werden die folgenden untergeordneten Forschungsfragen (UFF) untersucht:

- *UFF 1: Welche Architekturmuster und Systemkomponenten eignen sich für die Realisierung einer spezialisierten Cloud-Gaming-Plattform, die auf die Bereitstellung von Spieledemos für leistungsschwache Endgeräte optimiert ist?*

- *UFF 2: Durch welche Kombination von Streaming-Protokollen, Codecs und Infrastrukturtechnologien kann eine geringe Latenz und eine hohe visuelle Qualität bei der Übertragung von Spieledemos sichergestellt werden?*

- *UFF 3: Welchen Mehrwert bietet eine solche Plattform für Endnutzer im Vergleich zu traditionellen Download-Demos, und welche technischen sowie nutzerzentrierten Hürden müssen für eine hohe Akzeptanz überwunden werden?*

- *UFF 4: Welche betriebswirtschaftlichen Geschäftsmodelle sind für den Betrieb einer Cloud-Gaming-Plattform für Spieledemos tragfähig und welche strategischen Vorteile ergeben sich daraus für Spieleentwickler und Publisher?*

== Hypothesen

Vor jeglicher Recherche, stellte der Autor folgende Hypothesen auf:

- Ein großer Server sollte reichen, um mehrere Spiele gleichzeitig zu betreiben. Monolithische Architektur ist übersichtlich und einfach zu deployen.
- WebRTC ist bekannt und weit verbreitet. Es ist eine gute Wahl für Low-Latency-Videostreaming.
- Nutzer müssten mit Cloud-Gaming-Demos nicht auf Downloads warten und müssten die Hardwareanforderungen der Spiele nicht beachten. Nutzer sind davon abgeschreckt, zusätzliche Software installieren zu müssen oder sich einen Account anzulegen.
- So eine Plattform muss kostenlos angeboten werden, um genutzt zu werden, da sie auf dem als kostenlos verbreiteten Prinzip von Demos basiert. Das wird als zusätzliche, teure Werbemaßnahme bedeuten, dass die Plattform nicht wirtschaftlich ist (abhängig von der Konvertierungsrate).
- Spieler werden diese Cloud-Gaming-Demos nicht mehr nutzen als die aktuell verbreiteten, lokal installierten Demos.
