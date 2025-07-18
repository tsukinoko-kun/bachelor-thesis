= Methodik und Vorgehensweise

Um eine fundierte und praxistaugliche Lösung zu entwickeln, wurde eine iterative und explorative Vorgehensweise gewählt. Der Prozess gliedert sich in drei wesentliche Phasen: eine initiale Recherchephase, die Konzeption und Verwerfung eines ersten Architekturansatzes sowie die Entwicklung eines finalen Lösungsdesigns.

== Phase 1: Fundamentale Recherche und Anforderungsanalyse

Zu Beginn der Arbeit wurde eine grundlegende Literatur- und Marktrecherche durchgeführt, um die technologischen Kernkomponenten und deren Zusammenspiel zu verstehen. Der Fokus lag auf der Schnittstelle zwischen Hardware und Software im Kontext des Renderings von Videospielen. Untersucht wurden insbesondere:

- Die Grafikschnittstelle: Analyse der Funktionsweise und Kommunikation zwischen Grafikprozessor (GPU), zugehörigen Treibern und der Spiel-Engine.
- Hardware-Anforderungen: Evaluierung der am Markt verfügbaren GPU-Herstellern, um die Mindestanforderungen für das flüssige Rendern moderner Spieletitel zu definieren.

Diese Phase schuf die notwendige Wissensbasis, um erste Architekturkonzepte zu entwerfen.

== Phase 2: Evaluierung eines monolithischen Ansatzes

Basierend auf den ersten Erkenntnissen wurde ein monolithischer Architekturansatz formuliert. Die zentrale Idee bestand darin, mehrere Spielinstanzen ressourcensparend auf einem einzigen, leistungsstarken Host-System zu bündeln. Zur technischen Umsetzung wurden Virtualisierungstechnologien wie Container (z. B. Docker) und leichtgewichtige Micro-VMs (z. B. Firecracker) als mögliche Isolationsmechanismen evaluiert.

Die Untersuchung dieses Ansatzes deckte jedoch eine fundamentale technische Limitierung auf:
Die Rendering-Leistung einer einzelnen GPU ist in der Praxis auf eine, bei geringeren Anforderungen auf maximal zwei, grafisch anspruchsvolle Spielinstanzen beschränkt. Eine vertikale Skalierung durch das Hinzufügen weiterer GPUs in einem System (Multi-GPU-Setups) ist für diesen Anwendungsfall ebenfalls nicht zielführend, da moderne Spiele und deren Engines diese Technologie kaum noch unterstützen und nicht auf die parallele Nutzung mehrerer Grafikkarten ausgelegt sind.

Aufgrund dieser nicht überwindbaren Skalierungsproblematik, die eine wirtschaftliche und performante Bereitstellung für mehrere Nutzer gleichzeitig verhindert, wurde dieser monolithische Ansatz verworfen. Die Erkenntnis war, dass eine starre 1-zu-N-Beziehung (ein Host für N Spiele) im High-End-Gaming-Bereich nicht realisierbar ist.

== Phase 3: Strategische Neuausrichtung zum Serverless-Modell

Als Konsequenz aus den gewonnenen Erkenntnissen und in Abstimmung mit der Betreuung der Arbeit wurde die Strategie neu ausgerichtet. Der Fokus verlagerte sich auf ein Serverless-Computing-Modell.

Das Kernprinzip dieses Ansatzes besteht darin, für jede Benutzersitzung eine dedizierte und kurzlebige Server-Instanz dynamisch bei Bedarf bereitzustellen. Sobald die Spieledemo beendet wird, wird die Instanz wieder vollständig entfernt. Dieses Modell löst die zuvor identifizierte Limitierung des monolithischen Designs auf elegante Weise:
- Performance: Jeder Nutzer erhält die exklusiven Ressourcen einer Instanz inklusive einer dedizierten GPU, was eine maximale Performance sicherstellt.
- Skalierbarkeit: Das System skaliert horizontal, indem für jeden neuen Nutzer eine neue, unabhängige Instanz gestartet wird. Die Skalierungsgrenze wird somit nur durch die Kapazitäten des zugrundeliegenden Cloud-Providers bestimmt.

Dieser Ansatz bildet die Grundlage für das in den folgenden Kapiteln detailliert beschriebene Lösungsdesign.
