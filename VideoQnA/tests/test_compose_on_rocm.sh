#!/bin/bash
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

set -x
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

    docker pull intellabs/vdms:v2.8.0
    docker pull ghcr.io/huggingface/text-generation-inference:2.4.1-rocm
    docker images && sleep 1s
}


function start_services() {
    cd $WORKPATH/docker_compose/amd/gpu/rocm/

    export host_ip=${ip_address}

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
    export DATAPREP_SERVICE_ENDPOINT="http://${host_ip}:6007/v1/dataprep"
    export DATAPREP_GET_FILE_ENDPOINT="http://${host_ip}:6007/v1/dataprep/get_file"
    export DATAPREP_GET_VIDEO_LIST_ENDPOINT="http://${host_ip}:6007/v1/dataprep/get_videos"

    export VDMS_HOST=${host_ip}
    export VDMS_PORT=8001
    export INDEX_NAME="mega-videoqna"
    export USECLIP=1

    docker volume create video-llama-model
    docker compose up vdms-vector-db dataprep -d
    sleep 30s

    # Insert some sample data to the DB
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://${host_ip}:6007/v1/dataprep \
    -H "Content-Type: multipart/form-data" \
    -F "files=@$WORKPATH/assets/video/op_1_0320241830.mp4")

    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "Inserted some data at the beginning."
    else
        echo "Inserted failed at the beginning. Received status was $HTTP_STATUS"
        docker logs dataprep-vdms-server >> ${LOG_PATH}/dataprep.log
        exit 1
    fi
    # Bring all the others
    docker compose up -d > ${LOG_PATH}/start_services_with_compose.log
    sleep 1m

    # List of containers running uvicorn
    list=("dataprep-vdms-server" "embedding-multimodal-server" "retriever-vdms-server" "reranking-videoqna-server" "lvm-video-llama" "videoqna-backend-server")

    # Define the maximum time limit in seconds
    TIME_LIMIT=5400
    start_time=$(date +%s)

    check_condition() {
        local item=$1

        if docker logs $item 2>&1 | grep -q "Uvicorn running on"; then
            return 0
        else
            return 1
        fi
    }

    # Main loop
    while [[ ${#list[@]} -gt 0 ]]; do
        # Get the current time
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        # Exit if time exceeds the limit
        if (( elapsed_time >= TIME_LIMIT )); then
            echo "Time limit exceeded."
            break
        fi

        # Iterate through the list
        for i in "${!list[@]}"; do
            item=${list[i]}
            if check_condition "$item"; then
                echo "Condition met for $item, removing from list."
                unset list[i]
            else
                echo "Condition not met for $item, keeping in list."
            fi
        done

        # Clean up the list to remove empty elements
        list=("${list[@]}")

        # Check if the list is empty
        if [[ ${#list[@]} -eq 0 ]]; then
            echo "List is empty. Exiting."
            break
        fi
        sleep 5m
    done

    if docker logs videoqna-ui-server 2>&1 | grep -q "Streamlit app"; then
        return 0
    else
        return 1
    fi

}

function validate_services() {
    local URL="$1"
    local EXPECTED_RESULT="$2"
    local SERVICE_NAME="$3"
    local DOCKER_NAME="$4"
    local INPUT_DATA="$5"

    local HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST -d "$INPUT_DATA" -H 'Content-Type: application/json' "$URL")
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "[ $SERVICE_NAME ] HTTP status is 200. Checking content..."

        local CONTENT=$(curl -s -X POST -d "$INPUT_DATA" -H 'Content-Type: application/json' "$URL" | tee ${LOG_PATH}/${SERVICE_NAME}.log)

        if echo "$CONTENT" | grep -q "$EXPECTED_RESULT"; then
            echo "[ $SERVICE_NAME ] Content is as expected."
        else
            echo "[ $SERVICE_NAME ] Content does not match the expected result: $CONTENT"
            docker logs ${DOCKER_NAME} >> ${LOG_PATH}/${SERVICE_NAME}.log
            exit 1
        fi
    else
        echo "[ $SERVICE_NAME ] HTTP status is not 200. Received status was $HTTP_STATUS"
        docker logs ${DOCKER_NAME} >> ${LOG_PATH}/${SERVICE_NAME}.log
        exit 1
    fi
    sleep 1s
}

function validate_microservices() {
    # Check if the microservices are running correctly.
    cd $WORKPATH/docker_compose/amd/gpu/rocm/data

    # dataprep microservice
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://${host_ip}:6007/v1/dataprep \
    -H "Content-Type: multipart/form-data" \
    -F "files=@./op_1_0320241830.mp4")

    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "Dataprep microservice is running correctly."
    else
        echo "Dataprep microservice is not running correctly. Received status was $HTTP_STATUS"
        docker logs dataprep-vdms-server >> ${LOG_PATH}/dataprep.log
        exit 1
    fi

    # Embedding Microservice
    validate_services \
        "${host_ip}:6000/v1/embeddings" \
        "Sample text" \
        "embedding" \
        "embedding-multimodal-server" \
        '{"text":"Sample text"}'

    # Retriever Microservice
    export your_embedding=$(python -c "import random; embedding = [random.uniform(-1, 1) for _ in range(512)]; print(embedding)")
    validate_services \
        "${host_ip}:7000/v1/retrieval" \
        "retrieved_docs" \
        "retriever" \
        "retriever-vdms-server" \
        "{\"text\":\"test\",\"embedding\":${your_embedding}}"

    # Reranking Microservice
    validate_services \
        "${host_ip}:8000/v1/reranking" \
        "video_url" \
        "reranking" \
        "reranking-videoqna-server" \
        '{
            "retrieved_docs": [{"doc": [{"text": "retrieved text"}]}],
            "initial_query": "query",
            "top_n": 1,
            "metadata": [
                {"other_key": "value", "video":"top_video_name", "timestamp":"20"}
            ]
        }'

    # LVM Microservice
    validate_services \
        "${host_ip}:9000/v1/lvm" \
        "silence" \
        "lvm" \
        "lvm-video-llama" \
        '{"video_url":"https://github.com/DAMO-NLP-SG/Video-LLaMA/raw/main/examples/silence_girl.mp4","chunk_start": 0,"chunk_duration": 7,"prompt":"What is the person doing?","max_new_tokens": 50}'

    sleep 1s
}

function validate_megaservice() {
    validate_services \
    "${host_ip}:8888/v1/videoqna" \
    "man" \
    "videoqna-backend-server" \
    "videoqna-backend-server" \
    '{"messages":"What is the man doing?","stream":"True"}'
}

function validate_frontend() {
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X GET http://${host_ip}:5173/_stcore/health)

    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "Frontend is running correctly."
        local CONTENT=$(curl -s -X GET http://${host_ip}:5173/_stcore/health)
        if echo "$CONTENT" | grep -q "ok"; then
            echo "Frontend Content is as expected."
        else
            echo "Frontend Content does not match the expected result: $CONTENT"
            docker logs videoqna-xeon-ui-server >> ${LOG_PATH}/ui.log
            exit 1
        fi
    else
        echo "Frontend is not running correctly. Received status was $HTTP_STATUS"
        docker logs videoqna-xeon-ui-server >> ${LOG_PATH}/ui.log
        exit 1
    fi
}

function stop_docker() {
    cd $WORKPATH/docker_compose/amd/gpu/rocm/
    docker compose stop && docker compose rm -f
    docker volume rm video-llama-model
}

function main() {

    stop_docker

#    if [[ "$IMAGE_REPO" == "opea" ]]; then build_docker_images; fi
    start_services

    validate_microservices
    validate_megaservice
    validate_frontend

    stop_docker
#    echo y | docker system prune

}

main
