#!/bin/bash
# Copyright (C) 2024 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: Apache-2.0

set -ex
IMAGE_REPO=${IMAGE_REPO:-"opea"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
echo "REGISTRY=IMAGE_REPO=${IMAGE_REPO}"
echo "TAG=IMAGE_TAG=${IMAGE_TAG}"
export REGISTRY=${IMAGE_REPO}
export TAG=${IMAGE_TAG}

WORKPATH=$(dirname "$PWD")
LOG_PATH="$WORKPATH/tests"
ip_address=$(hostname -I | awk '{print $1}')
export PATH="~/miniconda3/bin:$PATH"

function build_docker_images() {
    cd $WORKPATH/docker_image_build
    git clone https://github.com/opea-project/GenAIComps.git && cd GenAIComps && git checkout "${opea_branch:-"main"}" && cd ../

    echo "Build all the images with --no-cache, check docker_image_build.log for details..."
    service_list="audioqna whisper asr llm-tgi speecht5 tts"
    docker compose -f build.yaml build ${service_list} --no-cache > ${LOG_PATH}/docker_image_build.log
    echo "docker pull ghcr.io/huggingface/text-generation-inference:2.3.1-rocm"
    docker pull ghcr.io/huggingface/text-generation-inference:2.3.1-rocm
    docker images && sleep 1s
}

function start_services() {
    cd $WORKPATH/docker_compose/amd/gpu/rocm/
    export host_ip=${ip_address}
    export AUDIOQNA_HUGGINGFACEHUB_API_TOKEN=${HUGGINGFACEHUB_API_TOKEN}
    export AUDIOQNA_VLLM_ENDPOINT=http://$host_ip:3006/v1/chat/completions
    export AUDIOQNA_LLM_MODEL_ID=meta-llama/Meta-Llama-3-8B-Instruct
    export AUDIOQNA_ASR_ENDPOINT=http://$host_ip:7066
    export AUDIOQNA_TTS_ENDPOINT=http://$host_ip:7055
    export AUDIOQNA_MEGA_SERVICE_HOST_IP=${host_ip}
    export AUDIOQNA_ASR_SERVICE_HOST_IP=${host_ip}
    export AUDIOQNA_TTS_SERVICE_HOST_IP=${host_ip}
    export AUDIOQNA_LLM_SERVICE_HOST_IP=${host_ip}
    export AUDIOQNA_ASR_SERVICE_PORT=3001
    export AUDIOQNA_TTS_SERVICE_PORT=3002
    export AUDIOQNA_LLM_SERVICE_PORT=3007

    # sed -i "s/backend_address/$ip_address/g" $WORKPATH/ui/svelte/.env

    # Start Docker Containers
    docker compose up -d > ${LOG_PATH}/start_services_with_compose.log
    n=0
    until [[ "$n" -ge 100 ]]; do
       docker logs tgi-service > $LOG_PATH/tgi_service_start.log
       if grep -q Connected $LOG_PATH/tgi_service_start.log; then
           break
       fi
       sleep 5s
       n=$((n+1))
    done
}
function validate_megaservice() {
    result=$(http_proxy="" curl http://${ip_address}:3008/v1/audioqna -XPOST -d '{"audio": "UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA", "max_tokens":64}' -H 'Content-Type: application/json')
    echo $result
    if [[ $result == *"AAA"* ]]; then
        echo "Result correct."
    else
        docker logs whisper-service > $LOG_PATH/whisper-service.log
        docker logs asr-service > $LOG_PATH/asr-service.log
        docker logs speecht5-service > $LOG_PATH/tts-service.log
        docker logs tts-service > $LOG_PATH/tts-service.log
        docker logs tgi-service > $LOG_PATH/tgi-service.log
        docker logs llm-tgi-server > $LOG_PATH/llm-tgi-server.log
        docker logs audioqna-xeon-backend-server > $LOG_PATH/audioqna-xeon-backend-server.log

        echo "Result wrong."
        exit 1
    fi

}

#function validate_frontend() {
# Frontend tests are currently disabled
#    cd $WORKPATH/ui/svelte
#    local conda_env_name="OPEA_e2e"
#    export PATH=${HOME}/miniforge3/bin/:$PATH
##    conda remove -n ${conda_env_name} --all -y
##    conda create -n ${conda_env_name} python=3.12 -y
#    source activate ${conda_env_name}
#
#    sed -i "s/localhost/$ip_address/g" playwright.config.ts
#
##    conda install -c conda-forge nodejs -y
#    npm install && npm ci && npx playwright install --with-deps
#    node -v && npm -v && pip list
#
#    exit_status=0
#    npx playwright test || exit_status=$?
#
#    if [ $exit_status -ne 0 ]; then
#        echo "[TEST INFO]: ---------frontend test failed---------"
#        exit $exit_status
#    else
#        echo "[TEST INFO]: ---------frontend test passed---------"
#    fi
#}

function stop_docker() {
    cd $WORKPATH/docker_compose/amd/gpu/rocm/
    docker compose stop && docker compose rm -f
}

function main() {

    stop_docker
    if [[ "$IMAGE_REPO" == "opea" ]]; then build_docker_images; fi
    start_services

    validate_megaservice
    # Frontend tests are currently disabled
    # validate_frontend

    stop_docker
    echo y | docker system prune

}

main
