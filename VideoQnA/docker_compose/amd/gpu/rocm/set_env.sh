#!/usr/bin/env bash

host_ip=$(hostname -I | awk '{print $1}')

export VIDEOQNA_MEGA_SERVICE_HOST_IP=${host_ip}
export VIDEOQNA_EMBEDDING_SERVICE_HOST_IP=${host_ip}
export VIDEOQNA_RETRIEVER_SERVICE_HOST_IP=${host_ip}
export VIDEOQNA_RERANK_SERVICE_HOST_IP=${host_ip}
export VIDEOQNA_LVM_SERVICE_HOST_IP=${host_ip}

export VIDEOQNA_MODEL_ID="DAMO-NLP-SG/VideoLLaMA2.1-7B-16F"
export VIDEOQNA_LVM_ENDPOINT="http://${host_ip}:9009"
export VIDEOQNA_BACKEND_SERVICE_ENDPOINT="http://${host_ip}:8888/v1/videoqna"
export VIDEOQNA_BACKEND_HEALTH_CHECK_ENDPOINT="http://${host_ip}:8888/v1/health_check"
export VIDEOQNA_DATAPREP_SERVICE_ENDPOINT="http://${host_ip}:6007/v1/dataprep"
export VIDEOQNA_DATAPREP_GET_FILE_ENDPOINT="http://${host_ip}:6007/v1/dataprep/get_file"
export VIDEOQNA_DATAPREP_GET_VIDEO_LIST_ENDPOINT="http://${host_ip}:6007/v1/dataprep/get_videos"

export VIDEOQNA_VDMS_HOST=${host_ip}
export VIDEOQNA_VDMS_PORT=8001
export VIDEOQNA_INDEX_NAME="mega-videoqna"
export VIDEOQNA_USECLIP=1
export VIDEOQNA_LLM_DOWNLOAD="True" # Set to "False" before redeploy LVM server to avoid model download
