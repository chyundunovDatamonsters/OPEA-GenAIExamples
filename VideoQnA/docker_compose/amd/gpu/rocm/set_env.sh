#!/usr/bin/env bash

# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

export host_ip=$(hostname -I | awk '{print $1}')

export MEGA_SERVICE_HOST_IP=${host_ip}
export EMBEDDING_SERVICE_HOST_IP=${host_ip}
export RETRIEVER_SERVICE_HOST_IP=${host_ip}
export RERANK_SERVICE_HOST_IP=${host_ip}
export LVM_SERVICE_HOST_IP=${host_ip}

export VIDEOQNA_TGI_SERVICE_PORT="9009"
export HOST_IP=${host_ip}
export VIDEOQNA_HUGGINGFACEHUB_API_TOKEN=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
#export VIDEOQNA_LVM_MODEL_ID="Xkev/Llama-3.2V-11B-cot"
export VIDEOQNA_LVM_MODEL_ID="BAAI/Aquila-VL-2B-llava-qwen"

export LVM_ENDPOINT="http://${host_ip}:9009"
export BACKEND_SERVICE_ENDPOINT="http://${host_ip}:8888/v1/videoqna"
export BACKEND_HEALTH_CHECK_ENDPOINT="http://${host_ip}:8888/v1/health_check"
export DATAPREP_SERVICE_ENDPOINT="http://${host_ip}:6004/v1/dataprep"
export DATAPREP_GET_FILE_ENDPOINT="http://${host_ip}:6004/v1/dataprep/get_file"
export DATAPREP_GET_VIDEO_LIST_ENDPOINT="http://${host_ip}:6004/v1/dataprep/get_videos"

export VDMS_HOST=${host_ip}
export VDMS_PORT=8001
export INDEX_NAME="mega-videoqna"
export USECLIP=1
