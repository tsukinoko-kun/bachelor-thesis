= Zielgruppe

Es wurde eine Umfrage an Videospiel-Entusiasten durchgeführt. An der Umfrage haben hauptsächlich Software-Engineering-Studenten teilgenommen, aber auch Personen aus anderen Berufs- und Altersgruppen. Insgesamt haben 35 Personen teilgenommen, wovon 32 aus Deutschland und drei aus den USA waren. Den teilnehmenden wurde kein Anreiz gegeben teilzunehmen und die Befragung fand über das online-Tool Blocksurvey statt.

80% der befragten Spieler gaben an, dass sie Videospiele auf einem Desktop PC spielen.

#figure(
  image("img/survey_devices.png"),
  caption: "Umfrage - Auf welchem Gerät spielst du Videospiele?",
)

94.3% gaben an, dass sie Videospiele spielen, die 60 GB oder großer sind. Bei 37.1% der befragten, sind die Spiele sogar über 100GB groß.

#figure(
  image("img/survey_size.png"),
  caption: "Umfrage - Wie groß sind die Spiele, die du spielst? (in GB)",
)

Die Mehrheit der Befragten gab an, sich für AAA-Spiele zu interessieren.

#figure(
  image("img/interest_aaa.png"),
  caption: "Umfrage - Interessierst du dich für AAA Games?",
)

Die meisten der Befragten haben bereits Cloud-Gaming-Lösungen verwendet. "Andere" war hier Google Stadia, dass 18.01.2023 abgeschaltet wurde. @stadia-faq-2023

#figure(
  image("img/survey_cloudgamingplattform.png"),
  caption: "Umfrage - Welchen Cloud Gaming Anbieter hast du bereits verwendet?",
)

Der wichtigste Punkt der Umfrage, ob die Befragten Spiele-Demos über Cloud Gaming spielen würden, anstatt sie auf den eigenen Computer herunterzuladen, wurde zu 68,6% mit Ja beantwortet. 11,4% gaben an, dass es darauf ankommt, wie viel Aufwand sie als Spieler dafür betreiben müssen (Registrierung, Warteschlange), es gab auch Bedenken über die Latenz.

#figure(
  image("img/survey_clouddemo.png"),
  caption: "Umfrage - Würdest du Demos über Cloud Gaming spielen, bevor du ein Spiel kaufst?",
)

Die Befragten gaben eine durchschnittliche Downloadgeschwindigeit von $325.4 frac("Mb", "s")$ an, der Median beträgt $105 frac("Mb", "s")$. Beim Ping wurde durchschnittlich 28,88 ms angegeben, der Median beträgt 16 ms.

Die Zielgruppe, die eine Untermenge aller Spieler darstellt, lässt sich aufgrund der Umfrage so zusammenfassen:

+ Es handelt sich überwiegend um Spieler am Desktop.
+ Interesse reicht von kleinen bis großen Spielen. Explizites Interesse an AAA-Spielen ist groß.
+ Es wurden bereits Cloud-Gaming-Lösungen verwendet.
+ Es besteht Interesse daran, die Spiele als Demo in der Cloud zu spielen.

Ziel dieser Bachelor-Thesis ist es, ein Konzept für eine _self-hostable_ Cloud Gaming-Lösung zu entwickeln.
Diese soll es Publishern und self-publishing-Studios ermöglichen, Demos ihrer Spiele unkompliziert anzubieten. Im Rahmen der Arbeit werden zunächst der aktuelle Stand der Technik und bestehende Lösungsansätze analysiert. Aufbauend darauf wird ein Konzept erarbeitet, das insbesondere auf die Herausforderungen im Bereich der Demo-Bereitstellung und des Schutzes geistigen Eigentums eingeht. Es werden existierende Lösungen für Teilprobleme verwendet, wenn solche existieren und auf den Anwendungsfall passen.
