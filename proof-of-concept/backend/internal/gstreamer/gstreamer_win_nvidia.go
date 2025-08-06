//go:build windows

package gstreamer

const pipelineStr = `d3d11screencapturesrc ! 
video/x-raw(memory:D3D11Memory),framerate=60/1,width=1920,height=1080 ! 
d3d11convert ! 
nvh264enc preset=low-latency-hq tune=zerolatency rc-mode=cbr-ld-hq bitrate=12000 ! 
h264parse ! 
rtph264pay config-interval=1 pt=96 ! 
appsink name=rtpsink`

func getPipelineStr() string {
	return pipelineStr
}
