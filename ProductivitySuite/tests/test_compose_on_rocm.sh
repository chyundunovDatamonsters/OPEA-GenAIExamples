#!/bin/bash
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

set -xe
IMAGE_REPO=${IMAGE_REPO:-"opea"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
echo "REGISTRY=IMAGE_REPO=${IMAGE_REPO}"
echo "TAG=IMAGE_TAG=${IMAGE_TAG}"
export REGISTRY=${IMAGE_REPO}
export TAG=${IMAGE_TAG}

WORKPATH=$(dirname "$PWD")
LOG_PATH="$WORKPATH/tests"
ip_address=$(hostname -I | awk '{print $1}')

function build_docker_images() {
    cd $WORKPATH/docker_image_build
    git clone https://github.com/opea-project/GenAIComps.git && cd GenAIComps && git checkout "${opea_branch:-"main"}" && cd ../

    echo "Build all the images with --no-cache, check docker_image_build.log for details..."
    docker compose -f build.yaml build --no-cache > ${LOG_PATH}/docker_image_build.log

    docker pull ghcr.io/huggingface/text-embeddings-inference:cpu-1.5
    docker pull ghcr.io/huggingface/text-generation-inference:2.3.1-rocm
    docker images && sleep 1s
}

function start_services() {
    cd $WORKPATH/docker_compose/amd/gpu/rocm/

    export host_ip=${ip_address}
    export host_ip_external=${ip_address}
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
    export BACKEND_SERVICE_ENDPOINT_DOCSUM_PORT=18121
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
    export V2A_ENDPOINT=http://${host_ip}:7078
    export A2T_ENDPOINT=http://${host_ip}:7066
    export A2T_SERVICE_HOST_IP=${host_ip}
    export A2T_SERVICE_PORT=9099
    export DATA_ENDPOINT=http://${host_ip}:7079
    export DATA_SERVICE_HOST_IP=${host_ip}
    export DATA_SERVICE_PORT=7079

    # Start Docker Containers
    docker compose up -d > ${LOG_PATH}/start_services_with_compose.log
    n=0
    until [[ "$n" -ge 100 ]]; do
        docker logs tgi_service > ${LOG_PATH}/tgi_service_start.log
        if grep -q Connected ${LOG_PATH}/tgi_service_start.log; then
            echo "ChatQnA TGI Service Connected"
            break
        fi
        sleep 5s
        n=$((n+1))
    done
    n=0
    until [[ "$n" -ge 100 ]]; do
        docker logs tgi_service_codegen > ${LOG_PATH}/tgi_service_codegen_start.log
        if grep -q Connected ${LOG_PATH}/tgi_service_codegen_start.log; then
            echo "CodeGen TGI Service Connected"
            break
        fi
        sleep 5s
        n=$((n+1))
    done
}

function validate_service() {
    local URL="$1"
    local EXPECTED_RESULT="$2"
    local SERVICE_NAME="$3"
    local DOCKER_NAME="$4"
    local INPUT_DATA="$5"

    if [[ $SERVICE_NAME == *"dataprep_upload_file"* ]]; then
        cd $LOG_PATH
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -F 'files=@./dataprep_file.txt' -H 'Content-Type: multipart/form-data' "$URL")
    elif [[ $SERVICE_NAME == *"dataprep_upload_link"* ]]; then
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -F 'link_list=["https://www.ces.tech/"]' "$URL")
    elif [[ $SERVICE_NAME == *"dataprep_get"* ]]; then
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -H 'Content-Type: application/json' "$URL")
    elif [[ $SERVICE_NAME == *"dataprep_del"* ]]; then
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -d '{"file_path": "all"}' -H 'Content-Type: application/json' "$URL")
    elif [[ $SERVICE_NAME == *"docsum-backend-server"* ]]; then
        local INPUT_DATA="messages=Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE and E5."
            HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -F "type=text" -F "$INPUT_DATA" -H 'Content-Type: multipart/form-data' "$URL")
    elif [[ $SERVICE_NAME == *"faqgen-backend-server"* ]]; then
    	  local INPUT_DATA="messages=Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE and E5."
            HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -F "$INPUT_DATA" -F "stream=true" -H 'Content-Type: multipart/form-data' "$URL")
    else
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -d "$INPUT_DATA" -H 'Content-Type: application/json' "$URL")
    fi
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    RESPONSE_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

    docker logs ${DOCKER_NAME} >> ${LOG_PATH}/${SERVICE_NAME}.log

    # check response status
    if [ "$HTTP_STATUS" -ne "200" ]; then
        echo "[ $SERVICE_NAME ] HTTP status is not 200. Received status was $HTTP_STATUS"
        exit 1
    else
        echo "[ $SERVICE_NAME ] HTTP status is 200. Checking content..."
    fi
    # check response body
    if [[ "$RESPONSE_BODY" != *"$EXPECTED_RESULT"* ]]; then
        echo "[ $SERVICE_NAME ] Content does not match the expected result: $RESPONSE_BODY"
        exit 1
    else
        echo "[ $SERVICE_NAME ] Content is as expected."
    fi

    sleep 1s
}

function validate_microservices() {
    # Check if the microservices are running correctly.

    # tei for embedding service
    validate_service \
        "${host_ip}:${EMBEDDING_SERVER_PORT}/embed" \
        "[[" \
        "tei-embedding" \
        "tei-embedding-server" \
        '{"inputs":"What is Deep Learning?"}'

    # embedding microservice
    validate_service \
        "${host_ip}:6000/v1/embeddings" \
        '"text":"What is Deep Learning?","embedding":[' \
        "embedding-microservice" \
        "embedding-tei-server" \
        '{"text":"What is Deep Learning?"}'

#    sleep 1m # retrieval can't curl as expected, try to wait for more time

    # test /v1/dataprep upload file
    echo "Deep learning is a subset of machine learning that utilizes neural networks with multiple layers to analyze various levels of abstract data representations. It enables computers to identify patterns and make decisions with minimal human intervention by learning from large amounts of data." > $LOG_PATH/dataprep_file.txt
    validate_service \
        "http://${host_ip}:${DATAPREP_SERVICE_ENDPOINT_PORT}/v1/dataprep" \
        "Data preparation succeeded" \
        "dataprep_upload_file" \
        "dataprep-redis-server"

    # test /v1/dataprep upload link
    validate_service \
        "http://${host_ip}:${DATAPREP_SERVICE_ENDPOINT_PORT}/v1/dataprep" \
        "Data preparation succeeded" \
        "dataprep_upload_link" \
        "dataprep-redis-server"

    # test /v1/dataprep/get_file
    validate_service \
        "http://${host_ip}:${DATAPREP_SERVICE_ENDPOINT_PORT}/v1/dataprep/get_file" \
        '{"name":' \
        "dataprep_get" \
        "dataprep-redis-server"

    # test /v1/dataprep/delete_file
    validate_service \
        "http://${host_ip}:${DATAPREP_SERVICE_ENDPOINT_PORT}/v1/dataprep/delete_file" \
        '{"status":true}' \
        "dataprep_del" \
        "dataprep-redis-server"

    # retrieval microservice
    test_embedding=$(python3 -c "import random; embedding = [random.uniform(-1, 1) for _ in range(768)]; print(embedding)")
    validate_service \
        "${host_ip}:7000/v1/retrieval" \
        "retrieved_docs" \
        "retrieval-microservice" \
        "retriever-redis-server" \
        "{\"text\":\"What is the revenue of Nike in 2023?\",\"embedding\":${test_embedding}}"

    # tei for rerank microservice
    validate_service \
        "${host_ip}:${RERANK_SERVER_PORT}/rerank" \
        '{"index":1,"score":' \
        "tei-rerank" \
        "tei-reranking-server" \
        '{"query":"What is Deep Learning?", "texts": ["Deep Learning is not...", "Deep learning is..."]}'

    # rerank microservice
    validate_service \
        "${host_ip}:8000/v1/reranking" \
        "Deep learning is..." \
        "reranking" \
        "reranking-tei-server" \
        '{"initial_query":"What is Deep Learning?", "retrieved_docs": [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}'

    # tgi for llm service
    validate_service \
        "${host_ip}:${LLM_SERVICE_PORT_CHATQNA}/generate" \
        "generated_text" \
        "tgi_service" \
        "tgi_service" \
        '{"inputs":"What is Deep Learning?","parameters":{"max_new_tokens":17, "do_sample": true}}'

    # ChatQnA llm microservice
    validate_service \
        "${host_ip}:9000/v1/chat/completions" \
        "data: " \
        "llm" \
        "llm-tgi-server" \
        '{"query":"What is Deep Learning?"}'

    # FAQGen llm microservice
    validate_service \
        "${host_ip}:9002/v1/faqgen" \
        "data: " \
        "llm_faqgen" \
        "llm-faqgen-server" \
        '{"query":"Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE and E5."}'

    # Docsum llm microservice
    validate_service \
        "${host_ip}:9003/v1/chat/docsum" \
        "data: " \
        "llm_docsum_server" \
        "llm-docsum-server" \
        '{"query":"Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE and E5."}'

    # CodeGen llm microservice
    validate_service \
        "${host_ip}:9001/v1/chat/completions" \
        "data: " \
        "llm_codegen" \
        "llm-tgi-server-codegen" \
        '{"query":"def print_hello_world():"}'

    result=$(curl -X 'POST' \
    http://${host_ip}:${CHAT_HISTORY_ENDPOINT_PORT}/v1/chathistory/create \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
    "data": {
        "messages": "test Messages", "user": "test"
    }
    }')
        echo $result
        if [[ ${#result} -eq 26 ]]; then
            echo "Correct result."
        else
            echo "Incorrect result."
            exit 1
        fi

        result=$(curl -X 'POST' \
    http://${host_ip}:${PROMPT_SERVICE_ENDPOINT_PORT}/v1/prompt/create \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
        "prompt_text": "test prompt", "user": "test"
    }')
        echo $result
        if [[ ${#result} -eq 26 ]]; then
            echo "Correct result."
        else
            echo "Incorrect result."
            exit 1
        fi

}


function validate_megaservice() {


    # Curl the ChatQnAMega Service
    validate_service \
        "${host_ip}:${BACKEND_SERVICE_ENDPOINT_CHATQNA_PORT}/v1/chatqna" \
        "data: " \
        "chatqna-backend-server" \
        "chatqna-backend-server" \
        '{"messages": "What is the revenue of Nike in 2023?"}'\


    # Curl the FAQGen Service
    validate_service \
        "${host_ip}:${BACKEND_SERVICE_ENDPOINT_FAQGEN_PORT}/v1/faqgen" \
        "Text Embeddings Inference" \
        "faqgen-backend-server" \
        "faqgen-backend-server" \
        '{"messages": "Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE and E5."}'\

    # Curl the DocSum Mega Service
    validate_service \
        "${host_ip}:${BACKEND_SERVICE_ENDPOINT_DOCSUM_PORT}/v1/docsum" \
        "embedding" \
        "docsum-backend-server" \
        "docsum-backend-server" \
        '{"messages": "Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE and E5."}'


    # Curl the CodeGen Mega Service
    validate_service \
    "${host_ip}:${BACKEND_SERVICE_ENDPOINT_CODEGEN_PORT}/v1/codegen" \
        "print" \
        "codegen-backend-server" \
        "codegen-backend-server" \
        '{"messages": "def print_hello_world():"}'
}

function validate_frontend() {
    echo "[ TEST INFO ]: --------- frontend test started ---------"
    cd $WORKPATH/ui/react
    local conda_env_name="OPEA_e2e"
    export PATH=${HOME}/miniconda3/bin/:$PATH
#    conda remove -n ${conda_env_name} --all -y
#    conda create -n ${conda_env_name} python=3.12 -y
    source activate ${conda_env_name}
    echo "[ TEST INFO ]: --------- conda env activated ---------"

#    conda install -c conda-forge nodejs=22.6.0 -y
    npm install && npm ci
    node -v && npm -v && pip list

    exit_status=0
    npm run test || exit_status=$?

    if [ $exit_status -ne 0 ]; then
        echo "[TEST INFO]: ---------frontend test failed---------"
        exit $exit_status
    else
        echo "[TEST INFO]: ---------frontend test passed---------"
    fi
}

function stop_docker() {
    cd $WORKPATH/docker_compose/amd/gpu/rocm/
    docker compose stop && docker compose rm -f
}

function main() {

#    stop_docker
#    if [[ "$IMAGE_REPO" == "opea" ]]; then build_docker_images; fi
    start_time=$(date +%s)
    start_services
    end_time=$(date +%s)
    duration=$((end_time-start_time))
    echo "Mega service start duration is $duration s" && sleep 1s

    validate_microservices
    echo "==== microservices validated ===="
    validate_megaservice
    echo "==== megaservices validated ===="
    validate_frontend
    echo "==== frontend validated ===="

#    stop_docker
#    echo y | docker system prune

}

main
