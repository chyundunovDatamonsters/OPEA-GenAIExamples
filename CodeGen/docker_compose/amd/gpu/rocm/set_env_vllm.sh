#!/usr/bin/env bash

# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

### The IP address or domain name of the server on which the application is running
export CODEGEN_HOST_IP=10.53.22.29
export CODEGEN_EXTERNAL_HOST=68.69.180.77

### A token for accessing repositories with models
export CODEGEN_HUGGINGFACEHUB_API_TOKEN=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

### Model ID
export CODEGEN_LLM_MODEL_ID="Qwen/Qwen2.5-Coder-7B-Instruct"

### The port of the LLM service. On this port, the LLM service will accept connections
export CODEGEN_LLM_SERVICE_PORT=9000
export CODEGEN_VLLM_SERVICE_PORT=8081
export CODEGEN_VLLM_ENDPOINT="http://${CODEGEN_HOST_IP}:${CODEGEN_VLLM_SERVICE_PORT}"

### The IP address or domain name of the server for CodeGen MegaService
export CODEGEN_MEGA_SERVICE_HOST_IP=${CODEGEN_HOST_IP}

### The port for CodeGen backend service
export CODEGEN_BACKEND_SERVICE_PORT=18150

### The URL of CodeGen backend service, used by the frontend service
export CODEGEN_BACKEND_SERVICE_URL="http://${CODEGEN_HOST_IP}:${CODEGEN_BACKEND_SERVICE_PORT}/v1/codegen"

### The endpoint of the LLM service to which requests to this service will be sent
export CODEGEN_LLM_SERVICE_HOST_IP=${CODEGEN_HOST_IP}

### The CodeGen service UI port
export CODEGEN_UI_SERVICE_PORT=18151
