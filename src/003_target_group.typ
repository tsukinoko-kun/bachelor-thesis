= Zielgruppe

Um eine nutzerzentrierte Lösung zu entwickeln, wurde eine Umfrage unter Videospiel-Enthusiasten durchgeführt. Den Teilnehmenden wurde das Konzept vorgestellt, Demos von Videospielen zukünftig kostenfrei über eine vom Publisher oder Entwickler bereitgestellte Cloud-Gaming-Plattform zu spielen, anstatt sie auf der eigenen Hardware installieren zu müssen.

Die Stichprobe umfasste 35 Personen, davon 32 aus Deutschland und drei aus den USA. Die Teilnehmerschaft setzte sich überwiegend aus Studierenden des Software-Engineerings sowie Personen anderer Berufs- und Altersgruppen zusammen. Die Teilnahme erfolgte freiwillig und ohne Anreize über das Online-Tool Blocksurvey.

Die Ergebnisse zeigen, dass 80% der Befragten vorwiegend einen Desktop-PC als Spielplattform nutzen.

#figure(
  image("img/survey_devices.png"),
  caption: "Umfrage - Auf welchem Gerät spielst du Videospiele?",
)

Hinsichtlich der Installationsgröße gaben 94.3% an, Spiele mit einem Speicherbedarf von 60 GB oder mehr zu nutzen. Bei 37.1% der Befragten überschreitet dieser sogar 100 GB.

#figure(
  image("img/survey_size.png"),
  caption: "Umfrage - Wie groß sind die Spiele, die du spielst? (in GB)",
)

Eine deutliche Mehrheit bekundete zudem Interesse an AAA-Spielen. Laut den Angaben auf der Vertriebsplattform Steam stellen diese Titel in der Regel die höchsten Anforderungen an die Hardware (CPU, GPU) und den Festplattenspeicher. @godofwarragnark @finalfantasyviirebirth @thelastofuspart2remastered

#figure(
  image("img/interest_aaa.png"),
  caption: "Umfrage - Interessierst du dich für AAA Games?",
)

Die Umfrage ergab weiterhin, dass die Mehrheit der Befragten bereits Erfahrungen mit Cloud-Gaming-Diensten gesammelt hat. Die Antwortoption "Andere" bezog sich dabei vornehmlich auf den Dienst Google Stadia, welcher zum 18.01.2023 eingestellt wurde. @stadia-faq-2023

#figure(
  image("img/survey_cloudgamingplattform.png"),
  caption: "Umfrage - Welchen Cloud Gaming Anbieter hast du bereits verwendet?",
)

Die von den Teilnehmern angegebene Internetverbindung weist eine durchschnittliche Download-Geschwindigkeit von $325.4 frac("Mb", "s")$ (Median: $105 frac("Mb", "s")$) und eine durchschnittliche Latenz (Ping) von 28.88 ms (Median: 16 ms) auf.

Die zentrale Fragestellung der Umfrage bezog sich auf die Bereitschaft, Spieledemos via Cloud-Gaming zu nutzen. Eine deutliche Mehrheit von 68.6% befürwortete diesen Ansatz gegenüber dem lokalen Download. Weitere 11.4% zeigten sich unter Vorbehalt zustimmend, wobei die Akzeptanz von Faktoren wie dem Nutzungsaufwand (z.B. Registrierung, Wartezeiten) und der technischen Qualität, insbesondere der Latenz, abhängt.

#figure(
  image("img/survey_clouddemo.png"),
  caption: "Umfrage - Würdest du Demos über Cloud Gaming spielen, bevor du ein Spiel kaufst?",
)

Basierend auf den Umfrageergebnissen lässt sich die Zielgruppe, eine Teilmenge der Gesamtspielerschaft, wie folgt charakterisieren:

+ Überwiegende Nutzung von Desktop-PCs als primäre Spielplattform.
+ Breites Interesse an Spielen unterschiedlicher Größe, mit einem explizit hohen Interesse an ressourcenintensiven AAA-Titeln.
+ Vorhandene Erfahrungen mit Cloud-Gaming-Diensten.
+ Hohe Bereitschaft, Spieledemos über Cloud-Gaming anstelle lokaler Installationen zu nutzen.

Das Ziel der vorliegenden Arbeit ist die Konzeption einer Cloud-Gaming-Lösung, die es Publishern sowie Self-Publishing-Entwicklern ermöglicht, Demos ihrer Spiele unkompliziert bereitzustellen. Hierfür wird zunächst der aktuelle Stand der Technik sowie bestehende Lösungsansätze analysiert. Aufbauend auf dieser Analyse wird ein Konzept entwickelt, das spezifische Herausforderungen wie die effiziente Bereitstellung von Demos und den Schutz des geistigen Eigentums adressiert. Dabei wird auf existierende Teillösungen zurückgegriffen, sofern diese für den Anwendungsfall geeignet sind.
