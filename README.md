# Usage
This project aims to build a docker image, add the image to your IBM Container Service docker registry, then deploy said image into your Kubernetes cluster on Bluemix.

```bash
docker run \
  -v /app/location:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DOCKERFILE="/location/of/DOCKERFILE" \
  -e DEPLOYMENT_FILE="/location/of/deployment.yml" \
  -e BX_ID="bluemix.username@company.com" \
  -e BX_PWD="secretpassw0rd" \
  -e BX_ACCOUNT="accountid" \
  -e BX_ORG="bluemix_org" \
  -e BX_SPACE="bluemix_space" \
  -e APP_NAME="app-name" \
  -e CR_NAMESPACE="blumix_container_registry" \
  -e CS_CLUSTER="bluemix_container_cluster" \
  barlock/ibm-container-deploy  
```

### Volumes
* `/data` - This is the directory where you're application is
* `/var/run/docker.sock:/var/run/docker.sock` - needed to run docker builds

### Environment Variables
* `DOCKERFILE` - This is the location of yor dockerfile defaults to `.` the root of your app
* `DEPLOYMENT_FILE` - This is a file that will be `kubectl appply -f`'d
* `BX_ID` - Your Bluemix id, usually an email address
* `BX_PWD` - The password to your Bluemix ID
* `BX_ACCOUNT` - The account you wish to deploy to
* `BX_ORG` - The org you wish to deploy to
* `BX_SPACE` - The space you wish to deploy to
* `APP_NAME` - The name of the app that will be pushed to the registry
* `CR_NAMESPACE` - The namespace of your container service registry
* `CS_CLUSTER` - The name of your container service cluster