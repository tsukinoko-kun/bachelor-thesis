= Zielgruppe

Die Entwicklung einer erfolgreichen Technologieplattform setzt ein Verständnis der potenziellen Nutzer voraus. Dieses Kapitel widmet sich daher der Definition und Analyse der Zielgruppe für die konzipierte Cloud-Gaming-Lösung. Um ein empirisches Fundament für die nutzerzentrierte Auslegung der Systemarchitektur zu schaffen, wurde eine Umfrage unter Videospiel-Enthusiasten durchgeführt. Den Teilnehmenden wurde das Konzept vorgestellt, Demos von High-End-Spielen kostenfrei über eine Cloud-Plattform zu nutzen, anstatt sie lokal installieren zu müssen.

Die Stichprobe umfasste 35 Personen, mehrheitlich aus Deutschland (32) und ergänzt durch Teilnehmer aus den USA (3). Die Teilnahme erfolgte freiwillig über das Online-Tool Blocksurvey. Die Gruppe setzte sich primär aus Studierenden des Software-Engineerings sowie weiteren Personen unterschiedlicher Berufs- und Altersgruppen zusammen. Es ist anzumerken, dass diese Stichprobengröße keine repräsentative Aussage für die gesamte Spielerschaft zulässt. Die Ergebnisse liefern jedoch wertvolle qualitative Einblicke und deuten auf Tendenzen innerhalb einer technikaffinen Nutzergruppe hin.

Die Umfrageergebnisse zeichnen ein klares Bild der Spielgewohnheiten. Mit 80 % der Befragten, die vorwiegend einen Desktop-PC als Spielplattform nutzen, verortet sich die Zielgruppe klar im Segment der PC-Spieler.

#figure(
  image("img/survey_devices.png"),
  caption: "Umfrage: Auf welchem Gerät spielst du Videospiele?",
)

Dieses Bild wird durch das hohe Interesse an AAA-Spielen untermauert, welche bekanntermaßen die höchsten Anforderungen an Hardware und Speicherplatz stellen.

#figure(
  image("img/interest_aaa.png"),
  caption: "Umfrage: Interessierst du dich für AAA-Spiele?",
)

Die Präferenz für High-End-Titel spiegelt sich direkt im Speicherbedarf wider. Eine überwältigende Mehrheit von 94.3 % installiert Spiele, die 60 GB oder mehr belegen; bei über einem Drittel sind es sogar mehr als 100 GB. Dies unterstreicht die Relevanz von zwei zentralen Nachteilen traditioneller Demos: lange Downloadzeiten und erheblicher Speicherplatzbedarf.

#figure(
  image("img/survey_size.png"),
  caption: "Umfrage: Wie groß sind die Spiele, die du spielst? (in GB)",
)

Die Vertrautheit mit Cloud-Gaming ist in der untersuchten Gruppe bereits hoch. Die Mehrheit hat Dienste wie GeForce Now oder das inzwischen eingestellte Google Stadia genutzt, was auf eine grundsätzliche Offenheit gegenüber Streaming-Lösungen hindeutet.

#figure(
  image("img/survey_cloudgamingplattform.png"),
  caption: "Umfrage: Welchen Cloud-Gaming-Anbieter hast du bereits verwendet?",
)

Zudem scheinen die technischen Voraussetzungen für ein qualitativ hochwertiges Streaming-Erlebnis mehrheitlich gegeben zu sein. Die von den Teilnehmenden angegebene Internetverbindung weist eine mediane Download-Geschwindigkeit von $105 frac("Mb", "s")$ und eine mediane Latenz von 16 ms auf. Diese Werte liegen deutlich über den üblichen Mindestanforderungen für Cloud-Gaming.

Die zentrale Fragestellung der Umfrage zielte auf die Akzeptanz von Spieledemos via Cloud-Gaming ab. Das Ergebnis ist eindeutig: Eine klare Mehrheit von 68.6 % würde eine solche Lösung dem herkömmlichen Download vorziehen.

#figure(
  image("img/survey_clouddemo.png"),
  caption: "Umfrage: Würdest du Demos über Cloud-Gaming spielen, bevor du ein Spiel kaufst?",
)

Weitere 11.4 % zeigen sich zustimmend, knüpfen ihre Bereitschaft jedoch an Bedingungen. Als entscheidende Faktoren wurden hier ein reibungsloser Zugang (etwa ohne umständliche Registrierung) und eine überzeugende technische Qualität, insbesondere eine geringe Latenz, genannt. Diese Vorbehalte sind als direkte Anforderungen an das Systemdesign zu verstehen.

Basierend auf diesen Ergebnissen lässt sich die Kernzielgruppe wie folgt charakterisieren: Es handelt sich um technikaffine PC-Spieler mit einem starken Interesse an grafisch aufwendigen AAA-Titeln. Sie sind mit den Herausforderungen großer Spieldateien und hoher Hardware-Anforderungen vertraut und haben mehrheitlich bereits Erfahrung mit Cloud-Gaming-Diensten gesammelt. Die hohe Bereitschaft, Demos direkt zu streamen, anstatt sie herunterzuladen, deutet auf einen pragmatischen Wunsch nach sofortigem Zugang und der Umgehung von Installationshürden hin.

Dieses Nutzerprofil bestätigt die grundlegende Annahme der Arbeit: Es existiert ein relevanter Bedarf für eine niederschwellige Möglichkeit, High-End-Spiele auszuprobieren. Die im Folgenden vorgestellte Architektur ist darauf ausgelegt, genau diese Anforderungen (insbesondere sofortige Verfügbarkeit, hohe Performance und geringe Latenz) zu adressieren.
