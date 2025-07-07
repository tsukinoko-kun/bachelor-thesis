= Basistechnologien

Die Spiele werden auf AWS EC2 G5 laufen. Amazon betont hierfür die starke Leistung für 3D Anwendungen und die Internetverbindung. @aws-ec2-g5-instances Beides sind wichtige Faktoren für den Anwendungsfall dieser Arbeit. Die Option g5.2xlarge verfügt über 32GiB Arbeitsspeicher, 8 vCPUs (AMD EPYC 7R32 2.8GHz x86_64), Nvidia A10G (24 GiB Arbeitsspeicher), Netzwerkgeschwindigkeit bis zu $10frac("Gib", "s")$ und 450GiB NVME SSD. @vantage-g5-2xlarge Dies deckt alle Hardwareanforderungen ab, die zuvor festgestellt wurden.

In folgenden Kapiteln wird AWS verwendet, die geplante Architektur lässt sich aber auch mit anderen Serverless-Providern umsetzen.
