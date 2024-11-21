#!/usr/bin/env bash                                                                                                           set_env.sh

# Copyright (C) 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: Apache-2.0


# export host_ip=<your External Public IP>    # export host_ip=$(hostname -I | awk '{print $1}')

export host_ip="192.165.1.21"
export AUDIOQNA_HUGGINGFACEHUB_API_TOKEN=${HUGGINGFACEHUB_API_TOKEN}
export AUDIOQNA_VLLM_ENDPOINT=http://$host_ip:3006/v1/chat/completions
export AUDIOQNA_LLM_SERVICE_ENDPOINT=http://$host_ip:3006/v1/chat/completions
export AUDIOQNA_LLM_MODEL_ID=meta-llama/Meta-Llama-3-8B-Instruct
export AUDIOQNA_ASR_ENDPOINT=http://$host_ip:7066
export AUDIOQNA_TTS_ENDPOINT=http://$host_ip:7055
export AUDIOQNA_MEGA_SERVICE_HOST_IP=${host_ip}
export AUDIOQNA_ASR_SERVICE_HOST_IP=${host_ip}
export AUDIOQNA_TTS_SERVICE_HOST_IP=${host_ip}
export AUDIOQNA_LLM_SERVICE_HOST_IP=${host_ip}
export AUDIOQNA_ASR_SERVICE_PORT=3001
export AUDIOQNA_TTS_SERVICE_PORT=3002
export AUDIOQNA_LLM_SERVICE_PORT=3006
