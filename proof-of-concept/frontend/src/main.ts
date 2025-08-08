const video = document.getElementById("video") as HTMLVideoElement;
const eventLog = document.getElementById("event-log") as HTMLDivElement;
const connectionStatus = document.getElementById(
  "connection-status",
) as HTMLDivElement;
const pointerStatus = document.getElementById(
  "pointer-status",
) as HTMLDivElement;
const fullscreenStatus = document.getElementById(
  "fullscreen-status",
) as HTMLDivElement;
console.log("video element", video);

const ws = new WebSocket(`ws://${location.hostname}:8080/ws`);

let pc: RTCPeerConnection;
let inputChannel: RTCDataChannel | null = null;
let isPointerLocked = false;

let lastBytes = 0;
let lastTimestamp = 0;

setInterval(async () => {
  if (!pc) return;

  const stats = await pc.getStats();
  stats.forEach((report) => {
    if (report.type === "inbound-rtp" && report.kind === "video") {
      if (lastTimestamp > 0) {
        const bytesDiff = report.bytesReceived - lastBytes;
        const timeDiff = (report.timestamp - lastTimestamp) / 1000; // in Sekunden
        const bitrateBps = (bytesDiff * 8) / timeDiff; // bit/s
        const bitrateMbps = bitrateBps / 1_000_000; // Mbit/s
        console.log(`Bitrate: ${bitrateMbps.toFixed(2)} Mbit/s`);
      }
      lastBytes = report.bytesReceived;
      lastTimestamp = report.timestamp;
    }
  });
}, 1000);

ws.onopen = async () => {
  connectionStatus.textContent = "WebSocket Connected";
  connectionStatus.className = "status-connected";

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

  // Handle incoming data channels from the server
  pc.ondatachannel = (event) => {
    const channel = event.channel;
    if (channel.label === "input") {
      inputChannel = channel;
      console.log("Input data channel received");

      inputChannel.onopen = () => {
        console.log("Input data channel opened");
        connectionStatus.textContent = "WebRTC Data Channel Ready";
        connectionStatus.className = "status-connected";
      };

      inputChannel.onclose = () => {
        console.log("Input data channel closed");
        inputChannel = null;
      };

      inputChannel.onerror = (error) => {
        console.error("Input data channel error:", error);
      };
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

function transmitInputEvent(inputEvent: InputEvent) {
  // Try WebRTC data channel first (preferred for low latency)
  if (inputChannel && inputChannel.readyState === "open") {
    try {
      inputChannel.send(JSON.stringify(inputEvent));
      return;
    } catch (error) {
      console.warn(
        "Failed to send via data channel, falling back to WebSocket:",
        error,
      );
    }
  }

  // Fallback to WebSocket
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({ inputEvent }));
  } else {
    console.warn("No available connection to transmit input event");
  }
}

function requestFullscreen() {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen().catch((err) => {
      console.warn("Failed to enter fullscreen:", err);
    });
  }
}

function requestPointerLock() {
  if (!isPointerLocked) {
    video.requestPointerLock();
  }
}

function setupFullscreenAndPointerLock() {
  // Handle fullscreen changes
  document.addEventListener("fullscreenchange", () => {
    if (document.fullscreenElement) {
      console.log("Entered fullscreen");
      fullscreenStatus.textContent = "Fullscreen: Yes";
      fullscreenStatus.className = "status-fullscreen";
    } else {
      console.log("Exited fullscreen");
      fullscreenStatus.textContent = "Fullscreen: No";
      fullscreenStatus.className = "";
    }
  });

  // Handle pointer lock changes
  document.addEventListener("pointerlockchange", () => {
    isPointerLocked = document.pointerLockElement === video;
    if (isPointerLocked) {
      console.log("Pointer locked");
      pointerStatus.textContent = "Pointer: Locked";
      pointerStatus.className = "status-locked";
    } else {
      console.log("Pointer unlocked");
      pointerStatus.textContent = "Pointer: Unlocked";
      pointerStatus.className = "";
    }
  });

  // Handle pointer lock errors
  document.addEventListener("pointerlockerror", () => {
    console.error("Pointer lock failed");
    pointerStatus.textContent = "Pointer: Lock Failed";
  });
}

function setupInputCapture() {
  // Setup fullscreen and pointer lock handlers
  setupFullscreenAndPointerLock();

  // Mouse events
  video.addEventListener("mousemove", (e) => {
    let deltaX = 0;
    let deltaY = 0;

    if (isPointerLocked) {
      // Use movementX/Y when pointer is locked (more accurate)
      deltaX = e.movementX;
      deltaY = e.movementY;
    } else {
      // Fallback to calculating delta from position (less accurate)
      const rect = video.getBoundingClientRect();
      const currentX = e.clientX - rect.left;
      const currentY = e.clientY - rect.top;

      // Store last position for next calculation
      if (!video.dataset.lastX || !video.dataset.lastY) {
        video.dataset.lastX = currentX.toString();
        video.dataset.lastY = currentY.toString();
        return;
      }

      const lastX = parseFloat(video.dataset.lastX);
      const lastY = parseFloat(video.dataset.lastY);

      deltaX = currentX - lastX;
      deltaY = currentY - lastY;

      video.dataset.lastX = currentX.toString();
      video.dataset.lastY = currentY.toString();
    }

    // Only send if there's actual movement
    if (deltaX !== 0 || deltaY !== 0) {
      const inputEvent = {
        type: "mouse_move" as const,
        data: { deltaX, deltaY },
        timestamp: Date.now(),
      };

      logEvent(inputEvent);
      transmitInputEvent(inputEvent);
    }
  });

  video.addEventListener("mousedown", (e) => {
    e.preventDefault();

    // Request fullscreen and pointer lock on first click
    requestFullscreen();
    requestPointerLock();

    const rect = video.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    const y = (e.clientY - rect.top) / rect.height;

    const inputEvent = {
      type: "mouse_click" as const,
      data: {
        button: e.button,
        x: Math.round(x * 1000) / 1000,
        y: Math.round(y * 1000) / 1000,
      },
      timestamp: Date.now(),
    };

    logEvent(inputEvent);
    transmitInputEvent(inputEvent);
  });

  video.addEventListener("mouseup", (e) => {
    e.preventDefault();
    const rect = video.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width;
    const y = (e.clientY - rect.top) / rect.height;

    const inputEvent = {
      type: "mouse_release" as const,
      data: {
        button: e.button,
        x: Math.round(x * 1000) / 1000,
        y: Math.round(y * 1000) / 1000,
      },
      timestamp: Date.now(),
    };

    logEvent(inputEvent);
    transmitInputEvent(inputEvent);
  });

  // Prevent context menu
  video.addEventListener("contextmenu", (e) => {
    e.preventDefault();
  });

  // Keyboard events - need to focus the video element
  video.tabIndex = 0;
  video.focus();

  video.addEventListener("keydown", (e) => {
    // Handle escape key to exit fullscreen and unlock pointer
    if (e.key === "Escape") {
      if (document.fullscreenElement) {
        document.exitFullscreen();
      }
      if (isPointerLocked) {
        document.exitPointerLock();
      }
      // Don't prevent default for Escape to allow browser handling
      return;
    }

    e.preventDefault();

    const inputEvent = {
      type: "key_press" as const,
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
    };

    logEvent(inputEvent);
    transmitInputEvent(inputEvent);
  });

  video.addEventListener("keyup", (e) => {
    e.preventDefault();

    const inputEvent = {
      type: "key_release" as const,
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
    };

    logEvent(inputEvent);
    transmitInputEvent(inputEvent);
  });

  // Handle focus to ensure keyboard events work
  video.addEventListener("click", () => {
    video.focus();
    // Also request fullscreen and pointer lock on any click
    requestFullscreen();
    requestPointerLock();
  });

  console.log("Input capture setup complete");
}
