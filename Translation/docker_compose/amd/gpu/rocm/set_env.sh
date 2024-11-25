#!/usr/bin/env bash

# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

export TRANSLATION_HOST_IP='192.165.1.21'
export TRANSLATIONS_EXTERNAL_HOST_IP='direct-supercomputer1.powerml.co'
export TRANSLATIONS_LLM_MODEL_ID="haoranxu/ALMA-13B"
export TRANSLATIONS_TGI_LLM_ENDPOINT="http://${TRANSLATION_HOST_IP}:8008"
export TRANSLATIONS_HUGGINGFACEHUB_API_TOKEN='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'
export TRANSLATIONS_MEGA_SERVICE_HOST_IP=${TRANSLATION_HOST_IP}
export TRANSLATIONS_LLM_SERVICE_HOST_IP=${TRANSLATION_HOST_IP}
export TRANSLATIONS_BACKEND_SERVICE_ENDPOINT="http://${TRANSLATIONS_EXTERNAL_HOST_IP}:${TRANSLATIONS_BACKEND_SERVICE_PORT}/v1/translation"
export TRANSLATIONS_NGINX_PORT=18123
export TRANSLATIONS_FRONTEND_SERVICE_IP=${TRANSLATIONS_EXTERNAL_HOST_IP}
export TRANSLATIONS_FRONTEND_SERVICE_PORT=18120
export TRANSLATIONS_BACKEND_SERVICE_NAME=translation
export TRANSLATIONS_BACKEND_SERVICE_IP=${TRANSLATIONS_EXTERNAL_HOST_IP}
export TRANSLATIONS_BACKEND_SERVICE_PORT=18121
