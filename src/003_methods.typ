= Methodik und Vorgehensweise

Die Beantwortung der Forschungsfragen und die Entwicklung einer praxistauglichen Lösung folgten einem iterativen, dreiphasigen Vorgehen. Dieser explorative Prozess umfasste eine initiale Recherche, die Konzeption und anschließende Verwerfung eines ersten Architekturansatzes sowie die Ausarbeitung des finalen Lösungsdesigns, das in dieser Arbeit vorgestellt wird.

== Phase 1: Fundamentale Recherche und Anforderungsanalyse

Zu Beginn der Arbeit stand eine grundlegende Literatur- und Marktrecherche, um die technologischen Kernkomponenten und ihr Zusammenspiel im Kontext des Cloud-Gamings zu verstehen. Der Fokus lag hierbei auf der kritischen Schnittstelle zwischen Hardware und Software beim Rendern von Videospielen. Untersucht wurden insbesondere:

- *Die Grafikschnittstelle:* Eine Analyse der Funktionsweise und der Kommunikation zwischen Grafikprozessor (GPU), den zugehörigen Treibern und der Spiel-Engine.
- *Hardware-Anforderungen:* Eine Evaluierung der am Markt dominanten GPU-Hersteller, um die Mindestanforderungen für das flüssige Rendern moderner AAA-Titel zu definieren.

Diese erste Phase schuf die notwendige Wissensbasis, um fundierte Architekturkonzepte entwerfen und bewerten zu können.

== Phase 2: Evaluierung eines monolithischen Ansatzes

Aufbauend auf den ersten Erkenntnissen wurde ein monolithischer Architekturansatz als Hypothese formuliert. Die zentrale Idee bestand darin, mehrere Spielinstanzen ressourcensparend auf einem einzigen, leistungsstarken Host-System zu bündeln. Zur technischen Umsetzung wurden Virtualisierungstechnologien wie Container (z. B. Docker) und leichtgewichtige Micro-VMs (z. B. Firecracker) als mögliche Isolationsmechanismen in Betracht gezogen.

Die Untersuchung dieses Ansatzes offenbarte jedoch eine fundamentale technische Hürde: Die Rendering-Leistung einer einzelnen GPU ist in der Praxis auf eine, bei geringeren Anforderungen auf maximal zwei, grafisch anspruchsvolle Spielinstanzen beschränkt. Eine vertikale Skalierung durch das Hinzufügen weiterer GPUs in einem System (Multi-GPU-Setups) scheint für diesen Anwendungsfall ebenfalls nicht zielführend, da moderne Spiele und deren Engines diese Technologie kaum noch unterstützen und nicht auf die parallele Nutzung mehrerer Grafikkarten ausgelegt sind.

Aufgrund dieser unüberwindbaren Skalierungsproblematik, die eine wirtschaftliche und performante Bereitstellung für mehrere Nutzer gleichzeitig verhindert, wurde der monolithische Ansatz verworfen. Die Erkenntnis war, dass eine starre 1-zu-N-Beziehung (ein Host für N Spiele) im High-End-Gaming-Bereich nicht realisierbar ist.

== Phase 3: Strategische Neuausrichtung zum Serverless-Modell

Das Scheitern des monolithischen Konzepts machte eine grundlegende Neuausrichtung der Strategie erforderlich. In Abstimmung mit der Betreuung der Arbeit verlagerte sich der Fokus auf ein Serverless-Computing-Modell.

Das Kernprinzip dieses Ansatzes besteht darin, für jede Benutzersitzung eine dedizierte und kurzlebige Server-Instanz dynamisch bei Bedarf bereitzustellen. Sobald die Spieledemo beendet wird, wird die Instanz wieder vollständig entfernt. Dieses Modell löst die zuvor identifizierte Limitierung des monolithischen Designs auf:

- *Performance:* Jeder Nutzer erhält die exklusiven Ressourcen einer Instanz inklusive einer dedizierten GPU, was eine maximale und konsistente Performance sicherstellt.
- *Skalierbarkeit:* Das System skaliert horizontal, indem für jeden neuen Nutzer eine neue, unabhängige Instanz gestartet wird. Die Skalierungsgrenze wird somit nur durch die Kapazitäten des zugrundeliegenden Cloud-Providers bestimmt.

Dieser Paradigmenwechsel bildet die methodische Grundlage für das in den folgenden Kapiteln detailliert beschriebene Lösungsdesign.
