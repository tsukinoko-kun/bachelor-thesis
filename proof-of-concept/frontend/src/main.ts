const video = document.getElementById('video') as HTMLVideoElement;
console.log("video element", video);

const ws = new WebSocket(`ws://${location.hostname}:8080/ws`);

let pc: RTCPeerConnection;

ws.onopen = async () => {
    pc = createPeerConnection();
    pc.addTransceiver('video', { direction: 'recvonly' });
    const offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    console.log("Local SDP offer:", offer.sdp);
    ws.send(JSON.stringify({ sdp: pc.localDescription }));
};

ws.onmessage = async (event) => {
    const msg = JSON.parse(event.data);
    if (msg.sdp) {
        console.log("Remote SDP answer:", msg.sdp.sdp);
        await pc.setRemoteDescription(new RTCSessionDescription(msg.sdp));
    } else if (msg.candidate) {
        await pc.addIceCandidate(new RTCIceCandidate(msg.candidate));
    }
};

function createPeerConnection() {
    const pc = new RTCPeerConnection();
    pc.ontrack = (event) => {
        console.log("ontrack", event);
        if (video.srcObject !== event.streams[0]) {
            video.srcObject = event.streams[0];
            console.log("video.srcObject", video.srcObject);
            video.muted = true;
            video.play();
        }
    };
    pc.onicecandidate = (event) => {
        if (event.candidate) {
            ws.send(JSON.stringify({ candidate: event.candidate }));
      }
    };
    return pc;
  }