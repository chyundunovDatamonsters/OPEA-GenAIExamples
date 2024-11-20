#!/usr/bin/env bash

host_ip=$(hostname -I | awk '{print $1}')

export VIDEOQNA_MEGA_SERVICE_HOST_IP=${host_ip}
export VIDEOQNA_EMBEDDING_SERVICE_HOST_IP=${host_ip}
export VIDEOQNA_RETRIEVER_SERVICE_HOST_IP=${host_ip}
export VIDEOQNA_RERANK_SERVICE_HOST_IP=${host_ip}
export VIDEOQNA_LVM_SERVICE_HOST_IP=${host_ip}

export VIDEOQNA_MODEL_ID="google/deplot"
export VIDEOQNA_LVM_ENDPOINT="http://${host_ip}:19009"
export VIDEOQNA_BACKEND_SERVICE_ENDPOINT="http://${host_ip}:18888/v1/videoqna"
export VIDEOQNA_BACKEND_HEALTH_CHECK_ENDPOINT="http://${host_ip}:18888/v1/health_check"
export VIDEOQNA_DATAPREP_SERVICE_ENDPOINT="http://${host_ip}:16007/v1/dataprep"
export VIDEOQNA_DATAPREP_GET_FILE_ENDPOINT="http://${host_ip}:16007/v1/dataprep/get_file"
export VIDEOQNA_DATAPREP_GET_VIDEO_LIST_ENDPOINT="http://${host_ip}:16007/v1/dataprep/get_videos"
export VIDEOQNA_TRANSFORMERS_CACHE="/home/$USER"

export VIDEOQNA_VDMS_HOST=${host_ip}
export VIDEOQNA_VDMS_PORT=18001
export VIDEOQNA_INDEX_NAME="mega-videoqna"
export VIDEOQNA_USECLIP=1
export VIDEOQNA_LLM_DOWNLOAD="True" # Set to "False" before redeploy LVM server to avoid model download
