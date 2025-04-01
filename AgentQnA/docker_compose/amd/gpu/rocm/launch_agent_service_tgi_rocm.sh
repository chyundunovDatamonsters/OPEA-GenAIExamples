# Copyright (C) 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: Apache-2.0

WORKPATH=$(dirname "$PWD")/..
export ip_address=${host_ip}
export HUGGINGFACEHUB_API_TOKEN=${your_hf_api_token}
export AGENTQNA_TGI_IMAGE=ghcr.io/huggingface/text-generation-inference:2.4.1-rocm
export AGENTQNA_TGI_SERVICE_PORT="8085"

# LLM related environment variables
export AGENTQNA_CARD_ID="card1"
export AGENTQNA_RENDER_ID="renderD136"
export HF_CACHE_DIR=${HF_CACHE_DIR}
ls $HF_CACHE_DIR
export LLM_MODEL_ID="Intel/neural-chat-7b-v3-3"
#export NUM_SHARDS=4
export LLM_ENDPOINT_URL="http://${ip_address}:${AGENTQNA_TGI_SERVICE_PORT}"
export temperature=0.01
export max_new_tokens=512

# agent related environment variables
export AGENTQNA_WORKER_AGENT_SERVICE_PORT="9095"
export TOOLSET_PATH=$WORKPATH/GenAIExamples/AgentQnA/tools/
echo "TOOLSET_PATH=${TOOLSET_PATH}"
export recursion_limit_worker=12
export recursion_limit_supervisor=10
export WORKER_AGENT_URL="http://${ip_address}:${AGENTQNA_WORKER_AGENT_SERVICE_PORT}/v1/chat/completions"
export RETRIEVAL_TOOL_URL="http://${ip_address}:8889/v1/retrievaltool"
export CRAG_SERVER=http://${ip_address}:18881

export AGENTQNA_FRONTEND_PORT="9090"

#retrieval_tool
export TEI_EMBEDDING_ENDPOINT="http://${host_ip}:6006"
export TEI_RERANKING_ENDPOINT="http://${host_ip}:8808"
export REDIS_URL="redis://${host_ip}:26379"
export INDEX_NAME="rag-redis"
export MEGA_SERVICE_HOST_IP=${host_ip}
export EMBEDDING_SERVICE_HOST_IP=${host_ip}
export RETRIEVER_SERVICE_HOST_IP=${host_ip}
export RERANK_SERVICE_HOST_IP=${host_ip}
export BACKEND_SERVICE_ENDPOINT="http://${host_ip}:8889/v1/retrievaltool"
export DATAPREP_SERVICE_ENDPOINT="http://${host_ip}:6007/v1/dataprep/ingest"
export DATAPREP_GET_FILE_ENDPOINT="http://${host_ip}:6007/v1/dataprep/get"
export DATAPREP_DELETE_FILE_ENDPOINT="http://${host_ip}:6007/v1/dataprep/delete"

docker compose -f compose.yaml up -d
