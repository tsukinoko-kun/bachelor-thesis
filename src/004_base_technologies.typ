= Basistechnologien

Für den Betrieb der Spiele-Server kommen EC2 G5-Instanzen von AWS zum Einsatz. Diese Wahl begründet sich durch die vom Hersteller hervorgehobene Eignung für rechenintensive 3D-Anwendungen sowie die leistungsfähige Netzwerkanbindung. @aws-ec2-g5-instances Beide Aspekte sind für den in dieser Arbeit beschriebenen Anwendungsfall von entscheidender Bedeutung.

Konkret wird die Instanzvariante g5.2xlarge genutzt, welche mit 32 GiB Arbeitsspeicher, acht virtuellen CPUs (AMD EPYC 7R32 mit 2.8 GHz), einer Nvidia A10G Grafikkarte (24 GiB Speicher), einer 450 GiB NVMe-SSD und einer Netzwerkbandbreite von bis zu $10 frac("Gib", "s")$ ausgestattet ist. @vantage-g5-2xlarge Diese Spezifikationen erfüllen die zuvor definierten Hardwareanforderungen vollständig.

Obwohl in den folgenden Kapiteln AWS als beispielhafter Cloud-Anbieter verwendet wird, ist die konzipierte Architektur prinzipiell auch mit den Diensten anderer Serverless-Provider realisierbar.
