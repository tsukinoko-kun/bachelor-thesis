const video = document.getElementById("video") as HTMLVideoElement;
const eventLog = document.getElementById("event-log") as HTMLDivElement;
console.log("video element", video);

const ws = new WebSocket(`ws://${location.hostname}:8080/ws`);

let pc: RTCPeerConnection;

ws.onopen = async () => {
  pc = createPeerConnection();
  pc.addTransceiver("video", { direction: "recvonly" });
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
      setupInputCapture();
    }
  };
  pc.onicecandidate = (event) => {
    if (event.candidate) {
      ws.send(JSON.stringify({ candidate: event.candidate }));
    }
  };
  return pc;
}

interface InputEvent {
  type:
    | "mouse_move"
    | "mouse_click"
    | "mouse_release"
    | "key_press"
    | "key_release";
  data: any;
  timestamp: number;
}

function logEvent(inputEvent: InputEvent) {
  const eventDiv = document.createElement("div");
  eventDiv.className = "event-log";

  const typeSpan = document.createElement("span");
  typeSpan.className = "event-type";
  typeSpan.textContent = inputEvent.type;

  const dataSpan = document.createElement("span");
  dataSpan.className = "event-data";
  dataSpan.textContent = ` ${JSON.stringify(inputEvent.data)}`;

  eventDiv.appendChild(typeSpan);
  eventDiv.appendChild(dataSpan);

  eventLog.insertBefore(eventDiv, eventLog.firstChild);

  // Keep only last 20 events
  while (eventLog.children.length > 20) {
    eventLog.removeChild(eventLog.lastChild!);
  }
}

function setupInputCapture() {
  let lastMouseX = 0;
  let lastMouseY = 0;
  let isFirstMove = true;

  // Mouse events
  video.addEventListener("mousemove", (e) => {
    if (isFirstMove) {
      lastMouseX = e.clientX;
      lastMouseY = e.clientY;
      isFirstMove = false;
      return;
    }

    const deltaX = e.clientX - lastMouseX;
    const deltaY = e.clientY - lastMouseY;
    
    lastMouseX = e.clientX;
    lastMouseY = e.clientY;

    logEvent({
      type: "mouse_move",
      data: { deltaX, deltaY },
      timestamp: Date.now(),
    });
  });

  video.addEventListener("mousedown", (e) => {
    e.preventDefault();
    const rect = video.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    const y = (e.clientY - rect.top) / rect.height;

    logEvent({
      type: "mouse_click",
      data: {
        button: e.button,
        x: Math.round(x * 1000) / 1000,
        y: Math.round(y * 1000) / 1000,
      },
      timestamp: Date.now(),
    });
  });

  video.addEventListener("mouseup", (e) => {
    e.preventDefault();
    const rect = video.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    const y = (e.clientY - rect.top) / rect.height;

    logEvent({
      type: "mouse_release",
      data: {
        button: e.button,
        x: Math.round(x * 1000) / 1000,
        y: Math.round(y * 1000) / 1000,
      },
      timestamp: Date.now(),
    });
  });

  // Prevent context menu
  video.addEventListener("contextmenu", (e) => {
    e.preventDefault();
  });

  // Keyboard events - need to focus the video element
  video.tabIndex = 0;
  video.focus();

  video.addEventListener("keydown", (e) => {
    e.preventDefault();

    logEvent({
      type: "key_press",
      data: {
        key: e.key,
        code: e.code,
        keyCode: e.keyCode,
        location: e.location,
        ctrlKey: e.ctrlKey,
        shiftKey: e.shiftKey,
        altKey: e.altKey,
        metaKey: e.metaKey,
      },
      timestamp: Date.now(),
    });
  });

  video.addEventListener("keyup", (e) => {
    e.preventDefault();

    logEvent({
      type: "key_release",
      data: {
        key: e.key,
        code: e.code,
        keyCode: e.keyCode,
        location: e.location,
        ctrlKey: e.ctrlKey,
        shiftKey: e.shiftKey,
        altKey: e.altKey,
        metaKey: e.metaKey,
      },
      timestamp: Date.now(),
    });
  });

  // Handle focus to ensure keyboard events work
  video.addEventListener("click", () => {
    video.focus();
  });

  console.log("Input capture setup complete");
}

