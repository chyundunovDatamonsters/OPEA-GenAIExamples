#!/usr/bin/env bash

# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

# Remember to set your private variables mentioned in README

# Befor run script:
# export host_ip='your_internal_server_address/hostname'
# export HUGGINGFACEHUB_API_TOKEN='you HF token'
# export OPENAI_API_KEY='your OPEN AI API key'

export HOST_IP=${host_ip}
export TEI_EMBEDDER_PORT=12000
export LLM_ENDPOINT_PORT=11634
export EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
export VLLM_SERVICE_PORT=8089
export HUGGINGFACEHUB_API_TOKEN=${HUGGINGFACEHUB_API_TOKEN}
export HF_CACHE_DIR="./data"
export LLM_MODEL_ID="Intel/neural-chat-7b-v3-3"
export OPENAI_EMBEDDING_MODEL="text-embedding-3-small"
export OPENAI_LLM_MODEL="gpt-4o"
export RETRIEVER_COMPONENT_NAME="OPEA_RETRIEVER_NEO4J"
export TEI_EMBEDDING_ENDPOINT="http://${HOST_IP}:${TEI_EMBEDDER_PORT}"
export OPENAI_API_KEY=${OPENAI_API_KEY}
export LLM_ENDPOINT="http://${HOST_IP}:${VLLM_SERVICE_PORT}"
export NEO4J_PORT1=7474
export NEO4J_PORT2=7687
export NEO4J_URI="bolt://${HOST_IP}:${NEO4J_PORT2}"
export NEO4J_URL="bolt://${HOST_IP}:${NEO4J_PORT2}"
export NEO4J_USERNAME="neo4j"
export NEO4J_PASSWORD="neo4jtest"
export DATAPREP_SERVICE_ENDPOINT="http://${HOST_IP}:5000/v1/dataprep/ingest"
export LOGFLAG=True
export MAX_INPUT_TOKENS=4096
export MAX_TOTAL_TOKENS=8192
export DATA_PATH="/mnt/nvme2n1/hf_cache"
export DATAPREP_PORT=11103
export RETRIEVER_PORT=7000
export MEGA_SERVICE_PORT=18101
export FRONTEND_SERVICE_PORT=18102
export NGINX_PORT
