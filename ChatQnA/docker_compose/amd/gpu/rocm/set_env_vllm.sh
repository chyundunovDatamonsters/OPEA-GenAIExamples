#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0

export HOST_IP='192.165.1.21'
export CHATQNA_HUGGINGFACEHUB_API_TOKEN="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"
export CHATQNA_EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
export CHATQNA_RERANK_MODEL_ID="BAAI/bge-reranker-base"
export CHATQNA_LLM_MODEL_ID="meta-llama/Meta-Llama-3-8B-Instruct"
export MODEL=${CHATQNA_LLM_MODEL_ID}
export CHATQNA_VLLM_SERVICE_PORT=18008
export CHATQNA_TEI_EMBEDDING_PORT=18090
export CHATQNA_TEI_EMBEDDING_ENDPOINT="http://${HOST_IP}:${CHATQNA_TEI_EMBEDDING_PORT}"
export CHATQNA_TEI_RERANKING_PORT=18808
export CHATQNA_REDIS_VECTOR_PORT=16379
export CHATQNA_REDIS_VECTOR_INSIGHT_PORT=8001
export CHATQNA_REDIS_DATAPREP_PORT=6007
export CHATQNA_REDIS_RETRIEVER_PORT=7000
export CHATQNA_INDEX_NAME="rag-redis"
export CHATQNA_MEGA_SERVICE_HOST_IP=${HOST_IP}
export CHATQNA_RETRIEVER_SERVICE_HOST_IP=${HOST_IP}
export CHATQNA_BACKEND_SERVICE_ENDPOINT="http://${HOST_IP}:${CHATQNA_BACKEND_SERVICE_PORT}/v1/chatqna"
export CHATQNA_DATAPREP_SERVICE_ENDPOINT="http://${HOST_IP}:${CHATQNA_REDIS_DATAPREP_PORT}/v1/dataprep"
export CHATQNA_DATAPREP_GET_FILE_ENDPOINT="http://${HOST_IP}:${CHATQNA_REDIS_DATAPREP_PORT}/v1/dataprep/get_file"
export CHATQNA_DATAPREP_DELETE_FILE_ENDPOINT="http://${HOST_IP}:${CHATQNA_REDIS_DATAPREP_PORT}/v1/dataprep/delete_file"
export CHATQNA_FRONTEND_SERVICE_IP=${HOST_IP}
export CHATQNA_FRONTEND_SERVICE_PORT=15173
export CHATQNA_BACKEND_SERVICE_NAME=chatqna
export CHATQNA_BACKEND_SERVICE_IP=${HOST_IP}
export CHATQNA_BACKEND_SERVICE_PORT=18888
export CHATQNA_REDIS_URL="redis://${HOST_IP}:${CHATQNA_REDIS_VECTOR_PORT}"
export CHATQNA_EMBEDDING_SERVICE_HOST_IP=${HOST_IP}
export CHATQNA_RERANK_SERVICE_HOST_IP=${HOST_IP}
export CHATQNA_LLM_SERVICE_HOST_IP=${HOST_IP}
export CHATQNA_NGINX_PORT=15176
