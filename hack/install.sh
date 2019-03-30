#!/usr/bin/env bash

set -e

[ -z "$MESH_NAME" ] && { echo "Need to set the environment variable MESH_NAME"; exit 1; }

if ! command -v jq >/dev/null 2>&1; then
    echo "Please install jq before continuing"
    exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
    echo "Please install openssl before continuing"
    exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Please install kubectl before continuing"
    exit 1
fi

tmpdir=$(mktemp -d)
echo "\nWorking directory at ${tmpdir}\n"

cd $tmpdir

mkdir -p deploy
curl https://raw.githubusercontent.com/aws/aws-app-mesh-inject/v0.1.0/deploy/inject-ns.yaml > deploy/inject-ns.yaml
curl https://raw.githubusercontent.com/aws/aws-app-mesh-inject/v0.1.0/deploy/inject.yaml.template > deploy/inject.yaml.template

mkdir -p hack
curl https://raw.githubusercontent.com/aws/aws-app-mesh-inject/v0.1.0/hack/gen-cert.sh > hack/gen-cert.sh
curl https://raw.githubusercontent.com/aws/aws-app-mesh-inject/v0.1.0/hack/ca-bundle.sh > hack/ca-bundle.sh

chmod u+x ./hack/ca-bundle.sh ./hack/gen-cert.sh

export IMAGE_NAME=602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-app-mesh-inject:v0.1.0
export MESH_REGION=""

export SIDECAR_IMAGE=111345817488.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-envoy:v1.9.0.0-prod
export INIT_IMAGE=111345817488.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-proxy-route-manager:latest

curl https://raw.githubusercontent.com/aws/aws-app-mesh-inject/v0.1.0/hack/deployInjector.sh | bash