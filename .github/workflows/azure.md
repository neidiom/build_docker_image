
on: [push]

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:

    - name: Running an action for checking out a repository
      uses: actions/checkout@master

    - name: Setup Cache
      uses: actions/cache@v1
      with:
        path: ~/caches
        key: ${{ runner.os }}-build-${{ hashFiles('Dockerfile') }}
        restore-keys: |
          ${{ runner.os }}-build-${{ hashFiles('Dockerfile') }}
          ${{ runner.os }}-build-
          ${{ runner.os }}-
  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:

    - name: Running an action for checking out a repository
      uses: actions/checkout@master
      
    - name: Login to Azure container registry
      uses: azure/docker-login@v1
      with:
        login-server: ${{ secrets.REGISTRY_HOSTNAME }}
        username: ${{ secrets.REGISTRY_USERNAME }}
        password: ${{ secrets.REGISTRY_PASSWORD }}

    - name: Build and save docker image 
      run: |
        if [ ! -f ~/caches/images.tar ]; then
          docker build . -t ${{ secrets.REGISTRY_HOSTNAME }}/filialfinder:${{ github.sha }} && \
          mkdir -p ~/caches && \
          echo 'tar start'
          docker save ${{ secrets.REGISTRY_HOSTNAME }}/filialfinder:${{ github.sha }} -o ~/caches/images.tar
          echo 'tar finish'
        fi

    - run: |
        ls -al ~/caches
        du -hs ~/caches/*

  run:
    needs: build
    runs-on: ubuntu-latest
    steps:

    - name: Running an action for checking out a repository
      uses: actions/checkout@master

    - name: Cache restore
      uses: actions/cache@v1
      with:
        path: ~/caches
        key: ${{ runner.os }}-build-v3-after-${{ hashFiles('Dockerfile') }}
        restore-keys: |
          ${{ runner.os }}-build-${{ hashFiles('Dockerfile') }}
          ${{ runner.os }}-build-
          ${{ runner.os }}-

    - name: Docker load
      if: steps.cache.outputs.cache-hit != 'true'
      run: | 
        docker load -q -i ~/caches/images.tar
        docker push ${{ secrets.REGISTRY_HOSTNAME }}/filialfinder:${{ github.sha }}
