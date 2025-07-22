//go:build darwin && arm64

package gstreamer

const pipelineStr = `avfvideosrc capture-screen=true ! 
video/x-raw,framerate=60/1 ! 
videoscale ! 
video/x-raw,width=1920,height=1080 ! 
vtenc_h264_hw realtime=true allow-frame-reordering=false bitrate=10000 max-keyframe-interval=60 ! 
h264parse ! 
rtph264pay config-interval=1 pt=96 ! 
udpsink host=127.0.0.1 port=5004`

func getPipelineStr() string {
	return pipelineStr
}
