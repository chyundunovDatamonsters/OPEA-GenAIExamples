# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

export host_ip='192.165.1.21'
export host_ip_external='direct-supercomputer1.powerml.co'
export MONGO_HOST=${host_ip}
export MONGO_PORT=27017
export DB_NAME="opea"
export PROMPT_COLLECTION_NAME="Conversations"
export EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
export RERANK_MODEL_ID="BAAI/bge-reranker-base"
export LLM_MODEL_ID="Intel/neural-chat-7b-v3-3"
export LLM_MODEL_ID_CODEGEN="Qwen/Qwen2.5-Coder-7B-Instruct"
export TEI_EMBEDDING_ENDPOINT="http://${host_ip}:6006"
export TEI_RERANKING_ENDPOINT="http://${host_ip}:8808"
export TGI_LLM_ENDPOINT="http://${host_ip}:9009"
export REDIS_URL="redis://${host_ip}:6379"
export INDEX_NAME="rag-redis"
export HUGGINGFACEHUB_API_TOKEN="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"
export LANGCHAIN_API_KEY='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'
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_ENDPOINT="https://api.smith.langchain.com"
export MEGA_SERVICE_HOST_IP=${host_ip}
export EMBEDDING_SERVICE_HOST_IP=${host_ip}
export EMBEDDING_SERVER_PORT=6006
export RETRIEVER_SERVICE_HOST_IP=${host_ip}
export RETRIEVER_SERVICE_PORT=7000
export RERANK_SERVICE_HOST_IP=${host_ip}
export RERANK_SERVER_PORT=8808
export LLM_SERVICE_HOST_IP=${host_ip}
export LLM_SERVICE_HOST_IP_DOCSUM=${host_ip}
export LLM_SERVICE_HOST_IP_FAQGEN=${host_ip}
export LLM_SERVICE_HOST_IP_CODEGEN=${host_ip}
export LLM_SERVICE_HOST_IP_CHATQNA=${host_ip}
export LLM_SERVICE_PORT_CHATQNA=9009
export LLM_SERVICE_HOST_PORT_FAQGEN=9002
export LLM_SERVICE_HOST_PORT_CODEGEN=9001
export LLM_SERVICE_HOST_PORT_DOCSUM=9003
export TGI_LLM_ENDPOINT_CHATQNA="http://${host_ip}:9009"
export TGI_LLM_ENDPOINT_CODEGEN="http://${host_ip}:8028"
export TGI_LLM_ENDPOINT_FAQGEN="http://${host_ip}:9009"
export TGI_LLM_ENDPOINT_DOCSUM="http://${host_ip}:9009"

export BACKEND_SERVICE_ENDPOINT_CHATQNA_PORT=18120
export BACKEND_SERVICE_ENDPOINT_FAQGEN_PORT=18122
export BACKEND_SERVICE_ENDPOINT_CODEGEN_PORT=18123
export BACKEND_SERVICE_ENDPOINT_DOCSUM_PORT=18124
export DATAPREP_SERVICE_ENDPOINT_PORT=18125
export CHAT_HISTORY_ENDPOINT_PORT=18126
export PROMPT_SERVICE_ENDPOINT_PORT=18127
export PRODUCTIVITYSUITE_KEYCLOAK_PORT=18129
export PRODUCTIVITYSUITE_UI_PORT=18130

export BACKEND_SERVICE_ENDPOINT_CHATQNA="http://${host_ip_external}:${BACKEND_SERVICE_ENDPOINT_CHATQNA_PORT}/v1/chatqna"
export DATAPREP_DELETE_FILE_ENDPOINT="http://${host_ip_external}:${DATAPREP_SERVICE_ENDPOINT_PORT}/v1/dataprep/delete_file"
export BACKEND_SERVICE_ENDPOINT_FAQGEN="http://${host_ip_external}:${BACKEND_SERVICE_ENDPOINT_FAQGEN_PORT}/v1/faqgen"
export BACKEND_SERVICE_ENDPOINT_CODEGEN="http://${host_ip_external}:${BACKEND_SERVICE_ENDPOINT_CODEGEN_PORT}/v1/codegen"
export BACKEND_SERVICE_ENDPOINT_DOCSUM="http://${host_ip_external}:${BACKEND_SERVICE_ENDPOINT_DOCSUM_PORT}/v1/docsum"
export DATAPREP_SERVICE_ENDPOINT="http://${host_ip_external}:${DATAPREP_SERVICE_ENDPOINT_PORT}/v1/dataprep"
export DATAPREP_GET_FILE_ENDPOINT="http://${host_ip_external}:${DATAPREP_SERVICE_ENDPOINT_PORT}/v1/dataprep/get_file"
export CHAT_HISTORY_CREATE_ENDPOINT="http://${host_ip_external}:${CHAT_HISTORY_ENDPOINT_PORT}/v1/chathistory/create"
export CHAT_HISTORY_CREATE_ENDPOINT="http://${host_ip_external}:${CHAT_HISTORY_ENDPOINT_PORT}/v1/chathistory/create"
export CHAT_HISTORY_DELETE_ENDPOINT="http://${host_ip_external}:${CHAT_HISTORY_ENDPOINT_PORT}/v1/chathistory/delete"
export CHAT_HISTORY_GET_ENDPOINT="http://${host_ip_external}:${CHAT_HISTORY_ENDPOINT_PORT}/v1/chathistory/get"
export PROMPT_SERVICE_GET_ENDPOINT="http://${host_ip_external}:${PROMPT_SERVICE_ENDPOINT_PORT}/v1/prompt/get"
export PROMPT_SERVICE_CREATE_ENDPOINT="http://${host_ip_external}:${PROMPT_SERVICE_ENDPOINT_PORT}/v1/prompt/create"
export KEYCLOAK_SERVICE_ENDPOINT="http://${host_ip_external}:${PRODUCTIVITYSUITE_KEYCLOAK_PORT}"

export PROMPT_COLLECTION_NAME="prompt"

export V2A_SERVICE_HOST_IP=${host_ip}
export V2A_ENDPOINT=http://$host_ip:7078
export A2T_ENDPOINT=http://$host_ip:7066
export A2T_SERVICE_HOST_IP=${host_ip}
export A2T_SERVICE_PORT=9099
export DATA_ENDPOINT=http://$host_ip:7079
export DATA_SERVICE_HOST_IP=${host_ip}
export DATA_SERVICE_PORT=7079
