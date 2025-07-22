//go:build linux

package gstreamer

import (
	"os"
)

type DisplayServerType string

const (
	X11     DisplayServerType = "x11"
	Wayland DisplayServerType = "wayland"
	Unknown DisplayServerType = "unknown"
)

// getDisplayServerType detects whether the current Linux session is running
// X11 or Wayland.
func getDisplayServerType() DisplayServerType {
	// The most reliable method is checking XDG_SESSION_TYPE.
	sessionType := os.Getenv("XDG_SESSION_TYPE")
	if sessionType == "wayland" {
		return Wayland
	}
	if sessionType == "x11" {
		return X11
	}

	// Fallback for systems that might not set XDG_SESSION_TYPE.
	// The presence of WAYLAND_DISPLAY is a strong indicator of a Wayland session.
	if os.Getenv("WAYLAND_DISPLAY") != "" {
		return Wayland
	}

	// If WAYLAND_DISPLAY is not set, but DISPLAY is, it's almost certainly X11.
	// This also handles the case where XDG_SESSION_TYPE is not set.
	if os.Getenv("DISPLAY") != "" {
		return X11
	}

	return Unknown
}

func getPipelineStr() string {
	switch getDisplayServerType() {
	case X11:
		return pipelineStrX11
	case Wayland:
		return pipelineStrWayland
	default:
		panic("Unsupported display server type (neither X11 nor Wayland detected)")
	}
}

const pipelineStrX11 = `ximagesrc use-damage=false ! 
video/x-raw,framerate=60/1 ! 
videoconvert ! 
nvideoconvert ! 
'video/x-raw(memory:NVMM),width=1920,height=1080' ! 
nvh264enc preset=low-latency-hq tune=zerolatency rc-mode=cbr-ld-hq bitrate=12000 ! 
h264parse ! 
rtph264pay config-interval=1 pt=96 ! 
udpsink host=127.0.0.1 port=5004`

const pipelineStrWayland = `pipewiresrc ! 
video/x-raw,format=BGRx,framerate=60/1 ! 
videoconvert ! 
nvideoconvert ! 
'video/x-raw(memory:NVMM),width=1920,height=1080' ! 
nvh264enc preset=low-latency-hq tune=zerolatency rc-mode=cbr-ld-hq bitrate=12000 ! 
h264parse ! 
rtph264pay config-interval=1 pt=96 ! 
udpsink host=127.0.0.1 port=5004`
