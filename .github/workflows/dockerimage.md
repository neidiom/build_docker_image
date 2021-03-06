name: Docker Image CI

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

env:
  GITHUB_SHA: ${{ github.sha }} 
  GITHUB_REF: ${{ github.ref }} 
  IMAGE: my_image_name_2
  REGISTRY_HOSTNAME: gcr.io
  PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}

jobs:

  build:

    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v2

    # Configure docker to use the gcloud command-line tool as a credential helper
    - run: |
        # Set up docker to authenticate
        # via gcloud command-line tool.
        gcloud auth configure-docker

    # Setup gcloud CLI
    - uses: GoogleCloudPlatform/github-actions/setup-gcloud@master
      with:
        version: '290.0.1'
        project_id: ${{ secrets.GCP_PROJECT_ID }}
        service_account_key: ${{ secrets.GCR_KEY }}
        export_default_credentials: true

    - run: gcloud info
    - run: gcloud auth list

    # Configure docker to use the gcloud command-line tool as a credential helper
    - run: |
        # Set up docker to authenticate
        # via gcloud command-line tool.
        gcloud auth configure-docker


#    - name: Build Docker image
#      run: |
#        echo $IMAGE
#        echo $PROJECT_ID
#        echo ${{ secrets.GCLOUD_APP_NAME }}
#        docker build . --tag ${{ REGISTRY_HOSTNAME }}/"$PROJECT_ID"/${{ secrets.GCLOUD_APP_NAME }}

    - name: Docker build
      run: |
        export TAG=$(date +%s)
        echo "##[set-output name=branch;]$(echo ${GITHUB_REF#refs/heads/})"
        export REF=`echo $GITHUB_REF | awk -F/ '{print $NF}'`
        echo $REF
        echo $GITHUB_SHA
        echo $GITHUB_REF
        docker build -t "$REGISTRY_HOSTNAME/${{ secrets.GCP_PROJECT_ID }}/${{ secrets.GCLOUD_APP_NAME }}:${TAG}" -t "$REGISTRY_HOSTNAME/${{ secrets.GCP_PROJECT_ID }}/${{ secrets.GCLOUD_APP_NAME }}:latest" .
        docker push "$REGISTRY_HOSTNAME/${{ secrets.GCP_PROJECT_ID }}/${{ secrets.GCLOUD_APP_NAME }}:${TAG}"
        docker push "$REGISTRY_HOSTNAME/${{ secrets.GCP_PROJECT_ID }}/${{ secrets.GCLOUD_APP_NAME }}:latest"


#    - name: Build the Docker image
#      run: docker build . --file Dockerfile --tag my-image-name:$(date +%s)


#- name: Docker build
#          commands:
#            # Replace with your GCP Project ID
#            - docker build -t "asia.gcr.io/YOUR_GCP_PROJECT_ID/semaphore-example:${SEMAPHORE_GIT_SHA:0:7}" .
#            - docker push "asia.gcr.io/GCP_PROJECT_ID/semaphore-example:${SEMAPHORE_GIT_SHA:0:7}"
