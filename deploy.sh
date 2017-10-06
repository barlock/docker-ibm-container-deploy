#!/bin/bash

#   This script is for packaging and deploying a service to Bluemix Container registry and Kubernetes service
#
#   DOCKERFILE              The location of the dockerfile to build with
#   DEPLOYMENT_FILE         The location of the deployment file
#   BX_ID                   The Bluemix ID to authenticate with.
#   BX_PWD                  The Bluemix password to authenticate with.
#   BX_ACCOUNT              The Bluemix account id
#   BX_ORG                  The Bluemix organization to deploy into.
#   BX_SPACE                The Bluemix space to deploy into.
#   APP_NAME                The name of the app to be deployed to Kubernetes
#   CR_NAMESPACE            The Container Registry namespace to publish package to
#   CS_CLUSTER              The Container Service cluster name to deploy to

REQUIRED=("BX_ID" "BX_PWD" "BX_ORG" "BX_SPACE" "APP_NAME" "CR_NAMESPACE" "APP_NAME")
for name in ${REQUIRED[*]}; do
    if [ -z "${!name}" ]; then
        echo "The '${name}' environment variable is required."
        exit 1
    fi
done

BUILD_TAG=$(git rev-parse --short HEAD)

bx_login () {
    echo "Logging into bx"
    bx login -a https://api.ng.bluemix.net -u "${BX_ID}" -p "${BX_PWD}" -c "${BX_ACCOUNT}" -o "${BX_ORG}" -s "${BX_SPACE}"
}

bx_init_registry () {
    echo "Initializing and setting up registry service"
    bx cr login
}

bx_init_container_service () {
    echo "Initializing and setting up container service"
    bx cs init

    CLUSTER_CONFIG=`bx cs cluster-config ${CS_CLUSTER} --export`
    eval "${CLUSTER_CONFIG}"
}

publish_docker_image () {
    echo "Building Docker image and tagging it"
    docker build -f "${DOCKERFILE}" -t ${APP_NAME} .

    echo "Tagging Latest"
    docker tag ${APP_NAME} ${CR_URL}/${CR_NAMESPACE}/${APP_NAME}:latest

    echo "Tagging ${BUILD_TAG}"
    docker tag ${APP_NAME} ${CR_URL}/${CR_NAMESPACE}/${APP_NAME}:${BUILD_TAG}

    echo "Publish image to container service registry"
    docker push ${CR_URL}/${CR_NAMESPACE}/${APP_NAME}
}

deploy_to_kube () {
    echo "Deploying to Kubernetes cluster"
    kubectl apply -f ${DEPLOYMENT_FILE}

    # Ensure app is the latest version
    kubectl set image deployment/${APP_NAME} ${APP_NAME}=${CR_URL}/${CR_NAMESPACE}/${APP_NAME}:${BUILD_TAG}
}

bx_login && \
bx_init_registry && \
bx_init_container_service && \
publish_docker_image && \
deploy_to_kube
