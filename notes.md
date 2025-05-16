Below is a compact summary of the theory you’ll need.  It is organized to answer each of your thesis questions.

1. Core Challenges  
– Large binaries: AAA titles ≈100 GiB each ⇒ naïve copy time  
  $$T_{\rm copy}\;=\;\frac{100\cdot2^{30}\times8}{B}$$  
  e.g. at \(B=1\) Gb/s ⇒ \(T_{\rm copy}\approx14\) min.  
– Hardware perf.: each session needs a modern GPU (e.g. RTX 6000/A10G) to render high‐settings AAA.  
– Low-latency video+input: end-to-end budget ≲100 ms, video BW ≈10 Mb/s for 1080p60, jitter control.  
– Cost per user: target \(\$1\)–10/hr; testing infra must be “free” or very cheap.  
– Scalability: O(200) concurrent sessions → orchestration, autoscaling, pooled vs per-session resources.  
– Persistence: saves must survive instance termination.  
– Security/DRM: users mustn’t extract game files from the stream.

2. “Obvious” Tasks  
– Provision GPU-accelerated VMs on demand  
– Install OS, GPU drivers, streaming server (Sunshine)  
– Expose per-instance IP/ports, secure network (SGs, VPC)  
– Authenticate users, map them to sessions  
– Tear down idle sessions (cost control)

3. Design Options  
A. GPU instance  
 • per-session on-demand vs Spot  
 • types: g4dn (T4), g5 (A10G), custom bare-metal (RTX)  
B. Game data staging  
 • direct S3 copy (slow)  
 • EBS-AMI or snapshot (lazy-load over NVMe)  
 • shared FS (EFS/FSx)  
C. Streaming protocol  
 • Sunshine (GameStream), WebRTC, proprietary  
D. Save-games  
 • S3 sync on start/end vs NFS (EFS)  
E. Orchestration  
 • custom agent + AWS APIs vs Kubernetes/Gamelift/etc.

4. Our Chosen Architecture  
– Base AMI: Ubuntu 22.04 + NVIDIA 525.x + Sunshine + orchestration agent  
– Dev:  
  • Control-plane on t3.micro (free tier)  
  • Functional tests on local Win11+Sunshine; optional g4dn.xlarge Spot (~€0.08/hr)  
– Prod (eu-north-1):  
  • 1:1 GPU→session, instance=g5.xlarge (1×A10G, 4 vCPU, 16 GiB), Spot≈€0.30/hr (~\$0.33)  
  • Storage=gp3 EBS (1 000 MiB/s, <1 ms latency via NVMe/Nitro), created from per-game snapshot  
– Startup (~2–3 min):  
  1) RunInstances(AMI), CreateVolume(from snapshot), Attach  
  2) mount, agent health-check, start Sunshine → client connect  
– Save-games: S3 sync on start/end; fallback to EFS if sub-ms random writes needed  
– Spot shutdown: agent polls IMDSv2 → “terminate” notice (~120 s) → warn user via stream  
– Autoscale: login→scale-out, logout/idle→scale-in

5. Why These Choices?  
– g5.xlarge/A10G gives full AAA-high settings at 1080p60 ≲\$1/hr; Spot slashes cost further.  
– gp3 EBS uses NVMe protocol, meets SSD throughput/IOPS without expensive io2.  
– AMI pre-bake ensures driver compatibility across test/prod GPUs (T4↔A10G).  
– Snapshot-based volumes avoid 100 GiB copy per session; lazy fetch minimizes startup delay.  
– Sunshine is proven low-latency, cross-platform, simple to deploy.  
– S3 sync is serverless, trivial to implement; EFS only if save patterns demand it.  
– IMDSv2 hook gives clean interruption warning, preserving UX.
