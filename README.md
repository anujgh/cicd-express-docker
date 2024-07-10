
# CI/CD NODEJS EXPRESS DOCKER EC2

This repo has nodejs express project. We created docker image from it and deploy it to docker-hub. Then pull that docker file and deployee to AWS-EC2 server.


# Steps
1. Create a new file at root named 'Dockerfile'.
2. Add following code to Dockerfile set of commands to create docker image.
```
    FROM node:20.12.2
    WORKDIR /app
    COPY ./package.json ./
    COPY ./package-lock.json ./
    RUN  npm install

    COPY ./src ./src
    EXPOSE 3000
    CMD [ "npm", "start" ]
```
3. Create ci/cd file at '.github/workflows/cicd.yml'.
4. Add the following code for create build and deploy to docker-hub and awsl-ec2.
```
    name: Deploy Node Application

    on:
    push:
        branches: 
        - main

    jobs:
    build:
        runs-on: ubuntu-latest
        steps:
        - name: checkout serice
            uses: actions/checkout@v4
        - name: Login to Docker Hub
            run: docker login -u ${{secrets.DOCKER_USERNAME}} -p ${{secrets.DOCKER_PASS}}
        - name: Build docker image
            run: docker build -t 27anujsharma/cicd-node-docker .
        - name: Publish image to docker hub
            run: docker push 27anujsharma/cicd-node-docker:latest

    deploy:
        needs: build
        runs-on: self-hosted
        steps:
        - name: Pull image from docker hub
            run: docker pull 27anujsharma/cicd-node-docker:latest
        - name: Delete old container
            run: docker rm -f nodejs-app-container
        - name: Run docker conntainer
            run: docker run -d -p 3000:3000 --name nodejs-app-container 27anujsharma/cicd-node-docker
        
```

5. Create AWS-EC2 instance.
6. Register EC2 server with github runner. When we click on Actions -> Runners -> Self-hosted runners. And click on New Runner. Then all the commands we will get. Run all the commands in EC2 terminal.
7. Install the Docker in EC2 with following commands.

```
    sudo apt update
    sudo apt install docker.io
```
8. Docker is installed in EC2. Now give the all permissions to Docker in EC2 terminal with following command.
```
    sudo chmod 777 /var/run/docker.sock
```
9. Now do any push and commits to the main branch. Then 2 jobs will be created one is build and other is deploy. In build docker image will be created and pushed to docker-hub. In deploy job docker image will be pulled to EC2 terminal.

10. Don't forgot to add running port no accessable for everyone in EC2 security group > Inbound rules.

##  Things are done. Congrats ! ;-)
