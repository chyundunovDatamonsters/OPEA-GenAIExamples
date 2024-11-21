#!/bin/bash
# Copyright (C) 2024 Advanced Micro Devices, Inc.
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

export HOST_IP=${ip_address}
export HOST_IP_EXTERNAL=${ip_address}
export CHATQNA_EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
export CHATQNA_RERANK_MODEL_ID="BAAI/bge-reranker-base"
export CHATQNA_LLM_MODEL_ID="meta-llama/Meta-Llama-3-8B-Instruct"
export MODEL=${CHATQNA_LLM_MODEL_ID}
export CHATQNA_VLLM_SERVICE_PORT=9009
export CHATQNA_TEI_EMBEDDING_PORT=8090
export CHATQNA_TEI_EMBEDDING_ENDPOINT="http://${HOST_IP}:${CHATQNA_TEI_EMBEDDING_PORT}"
export CHATQNA_TEI_RERANKING_PORT=8808
export CHATQNA_REDIS_VECTOR_PORT=6379
export CHATQNA_REDIS_VECTOR_INSIGHT_PORT=8001
export CHATQNA_REDIS_DATAPREP_PORT=6007
export CHATQNA_REDIS_RETRIEVER_PORT=7000
export CHATQNA_INDEX_NAME="rag-redis"
export CHATQNA_MEGA_SERVICE_HOST_IP=${HOST_IP}
export CHATQNA_RETRIEVER_SERVICE_HOST_IP=${HOST_IP}
export CHATQNA_FRONTEND_SERVICE_IP=${HOST_IP}
export CHATQNA_FRONTEND_SERVICE_PORT=5173
export CHATQNA_BACKEND_SERVICE_NAME=chatqna
export CHATQNA_BACKEND_SERVICE_IP=${HOST_IP}
export CHATQNA_BACKEND_SERVICE_PORT=8888
export CHATQNA_BACKEND_SERVICE_ENDPOINT="http://${HOST_IP}:${CHATQNA_BACKEND_SERVICE_PORT}/v1/chatqna"
export CHATQNA_DATAPREP_SERVICE_ENDPOINT="http://${HOST_IP}:${CHATQNA_REDIS_DATAPREP_PORT}/v1/dataprep"
export CHATQNA_DATAPREP_GET_FILE_ENDPOINT="http://${HOST_IP}:${CHATQNA_REDIS_DATAPREP_PORT}/v1/dataprep/get_file"
export CHATQNA_DATAPREP_DELETE_FILE_ENDPOINT="http://${HOST_IP}:${CHATQNA_REDIS_DATAPREP_PORT}/v1/dataprep/delete_file"
export CHATQNA_REDIS_URL="redis://${HOST_IP}:${CHATQNA_REDIS_VECTOR_PORT}"
export CHATQNA_EMBEDDING_SERVICE_HOST_IP=${HOST_IP}
export CHATQNA_RERANK_SERVICE_HOST_IP=${HOST_IP}
export CHATQNA_LLM_SERVICE_HOST_IP=${HOST_IP}
export CHATQNA_NGINX_PORT=8081
export CHATQNA_HUGGINGFACEHUB_API_TOKEN=${HUGGINGFACEHUB_API_TOKEN}
export PATH="/home/huggingface/miniconda3/bin:$PATH"
export DATAPREP_TEST_FILE_PREFIX=${RANDOM}

function build_docker_images() {
    cd "$WORKPATH"/docker_image_build
    git clone https://github.com/opea-project/GenAIComps.git && cd GenAIComps && git checkout "${opea_branch:-"main"}" && cd ../

    echo "Build all the images with --no-cache, check docker_image_build.log for details..."
    service_list="chatqna chatqna-ui chatqna-conversation-ui dataprep-redis retriever-redis nginx"
    docker compose -f build.yaml build ${service_list} --no-cache > "${LOG_PATH}"/docker_image_build.log

# The image for vllm is built locally. It will be hosted in the Docker Hub in the near future
#    docker pull vllm-api-server
    docker pull ghcr.io/huggingface/text-embeddings-inference:cpu-1.5

    docker images && sleep 1s
}

function start_services() {

    # Start Docker Containers
    docker compose -f compose_vllm.yaml up -d > "${LOG_PATH}"/start_services_with_compose.log

    n=0
    until [[ "$n" -ge 500 ]]; do
        docker logs chatqna-vllm-service >& "${LOG_PATH}"/chatqna-vllm-service_start.log
        if grep -q "Application startup complete" "${LOG_PATH}"/chatqna-vllm-service_start.log; then
            break
        fi
        sleep 10s
        n=$((n+1))
    done
}

function validate_service() {
    local URL="$1"
    local EXPECTED_RESULT="$2"
    local SERVICE_NAME="$3"
    local DOCKER_NAME="$4"
    local INPUT_DATA="$5"

    if [[ $SERVICE_NAME == *"chatqna-dataprep-redis-service"* ]]; then
        cd "$LOG_PATH"
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -F 'files=@./${DATAPREP_TEST_FILE_PREFIX}_dataprep_file.txt' -H 'Content-Type: multipart/form-data' "$URL")
    elif [[ $SERVICE_NAME == *"chatqna-dataprep-redis-service"* ]]; then
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -F 'link_list=["https://www.ces.tech/"]' "$URL")
    elif [[ $SERVICE_NAME == *"chatqna-dataprep-redis-service"* ]]; then
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -H 'Content-Type: application/json' "$URL")
    elif [[ $SERVICE_NAME == *"chatqna-dataprep-redis-service"* ]]; then
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -d '{"file_path": "all"}' -H 'Content-Type: application/json' "$URL")
    else
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -d "$INPUT_DATA" -H 'Content-Type: application/json' "$URL")
    fi
    HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    RESPONSE_BODY=$(echo "$HTTP_RESPONSE" | sed -e 's/HTTPSTATUS\:.*//g')

    docker logs "${DOCKER_NAME}" >> "${LOG_PATH}"/"${SERVICE_NAME}".log

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
        "${ip_address}:8090/embed" \
        "[[" \
        "chatqna-tei-embedding-service" \
        "chatqna-tei-embedding-service" \
        '{"inputs":"What is Deep Learning?"}'

    sleep 1m # retrieval can't curl as expected, try to wait for more time

    # test /v1/dataprep upload file
    echo "Deep learning is a subset of machine learning that utilizes neural networks with multiple layers to analyze various levels of abstract data representations. It enables computers to identify patterns and make decisions with minimal human intervention by learning from large amounts of data." > "$LOG_PATH"/${DATAPREP_TEST_FILE_PREFIX}_dataprep_file.txt
    validate_service \
        "http://${ip_address}:6007/v1/dataprep" \
        "Data preparation succeeded" \
        "chatqna-dataprep-redis-service" \
        "chatqna-dataprep-redis-service"

    # test /v1/dataprep upload link
    validate_service \
        "http://${ip_address}:6007/v1/dataprep" \
        "Data preparation succeeded" \
        "chatqna-dataprep-redis-service" \
        "chatqna-dataprep-redis-service"

    # test /v1/dataprep/get_file
    validate_service \
        "http://${ip_address}:6007/v1/dataprep/get_file" \
        '{"name":' \
        "chatqna-dataprep-redis-service" \
        "chatqna-dataprep-redis-service"

    # test /v1/dataprep/delete_file
    validate_service \
        "http://${ip_address}:6007/v1/dataprep/delete_file" \
        '{"status":true}' \
        "chatqna-dataprep-redis-service" \
        "chatqna-dataprep-redis-service"

    # retrieval microservice
    test_embedding=$(python3 -c "import random; embedding = [random.uniform(-1, 1) for _ in range(768)]; print(embedding)")
    validate_service \
        "${ip_address}:7000/v1/retrieval" \
        "retrieved_docs" \
        "chatqna-retriever" \
        "chatqna-retriever" \
        "{\"text\":\"What is the revenue of Nike in 2023?\",\"embedding\":${test_embedding}}"

    # tei for rerank microservice
    validate_service \
        "${ip_address}:8808/rerank" \
        '{"index":1,"score":' \
        "chatqna-tei-reranking-service" \
        "chatqna-tei-reranking-service" \
        '{"query":"What is Deep Learning?", "texts": ["Deep Learning is not...", "Deep learning is..."]}'

    # tgi for llm service
    validate_service \
        "${ip_address}:9009/generate" \
        "generated_text" \
        "chatqna-vllm-service" \
        "chatqna-vllm-service" \
        '{"inputs":"What is Deep Learning?","parameters":{"max_new_tokens":17, "do_sample": true}}'

}

function validate_megaservice() {
    # Curl the Mega Service
    validate_service \
        "${ip_address}:8888/v1/chatqna" \
        "data: " \
        "chatqna-backend-server" \
        "chatqna-backend-server" \
        '{"messages": "What is the revenue of Nike in 2023?"}'

}

function validate_frontend() {
    echo "[ TEST INFO ]: --------- frontend test started ---------"
    cd "$WORKPATH"/ui/svelte
    local conda_env_name="OPEA_e2e"
    export PATH=${HOME}/miniforge3/bin/:$PATH
    if conda info --envs | grep -q "$conda_env_name"; then
        echo "$conda_env_name exist!"
    else
        conda create -n ${conda_env_name} python=3.12 -y
    fi
    source activate ${conda_env_name}
    echo "[ TEST INFO ]: --------- conda env activated ---------"

    sed -i "s/localhost/$ip_address/g" playwright.config.ts

    conda install -c conda-forge nodejs=22.6.0 -y
    npm install && npm ci && npx playwright install --with-deps
    node -v && npm -v && pip list

    exit_status=0
    npx playwright test || exit_status=$?

    if [ $exit_status -ne 0 ]; then
        echo "[TEST INFO]: ---------frontend test failed---------"
        exit $exit_status
    else
        echo "[TEST INFO]: ---------frontend test passed---------"
    fi
}

function stop_docker() {
    cd "$WORKPATH"/docker_compose/amd/gpu/rocm
    docker compose -f compose_vllm.yaml stop && docker compose -f compose_vllm.yaml rm -f
}

function main() {

    stop_docker
    if [[ "$IMAGE_REPO" == "opea" ]]; then build_docker_images; fi
    start_time=$(date +%s)
    start_services
    end_time=$(date +%s)
    duration=$((end_time-start_time))
    echo "Mega service start duration is $duration s" && sleep 1s


    if [ "${mode}" == "perf" ]; then
        python3 "$WORKPATH"/tests/chatqna_benchmark.py
    elif [ "${mode}" == "" ]; then
        validate_microservices
        echo "==== microservices validated ===="
        validate_megaservice
        echo "==== megaservice validated ===="
        validate_frontend
        echo "==== frontend validated ===="
    fi

    stop_docker
    echo y | docker system prune

}

main
