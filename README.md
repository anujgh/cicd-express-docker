
# CI/CD NODEJS EXPRESS DOCKER ECS

This repo has nodejs express project. We created docker image from it and deploy it to docker-hub. Then pull that docker file and deployee to AWS-EC2 server.

Reffrence taken video Links for tutorial are 
- https://www.youtube.com/watch?v=LnA0hvN_FiE&t=10s
- https://www.youtube.com/watch?v=AiiFbsAlLaI&t=478s


# Steps

1. Create AWS-ECR repo. And topy the url of that repo.
2. Create AWS cluster Ex. name 'my-node-app-docker-cluster'. Select AWS Fargate (serverless) or Amazon EC2 instances. Here AWS Fargate is used. Cluster creation is taking time, in meanwhile we chan createe task-definition.
3. Create new Task definition. Ex. name : 'my-node-app-docker-task-definition'. This is the configration of task, in which our project container will run. We can select here, Os, CPU & memmory. Also Task role can be assigned.
4. In container section we set the container name (Ex. my-node-app-docker-container) and url of ECR image.
5. Also map the port no like (3000, 8000, etc) on which our task container project is running.
6. Now give the health check command in 'Health Check' section. Add the command: "CMD-SHELL, curl -f http://localhost:3000/health || exit 1". When we click 'info' link of health check command. In detail this command is showing. we can change localhost url according to our project.

Health check interval is default 30 seconds. But we can change it.

# Cluster service

7. Click on Cluster link and click our created cluster. In the cluster detail there is a section for services. Click on Create button in Service section.
8. In Deployment configuration section. There is a Family drop-down. Select the task definition Ex. 'my-node-app-docker-task-definition'.
9. Give the service name 'my-node-app-docker-service'.
10. Set the Desired tasks 2 for set-up of load-balancer.
11. **Load Balancing (Optional):** Select Application load balancer.
12. Give the name to load balancer 'my-node-docker-app-load-balancer'.
13. **Service auto scaling - optional:** Give the Minimum number of tasks : 2 and Maximum number of tasks: 5
14. Give the name of policy 'my-node-docker-app-policy'
15. Select 'ECSServiceAverageCPUUtilization' option in ECS service metric. Also mention Target value in %. Ex. 70
16. Now click on Create button.

# CI/CD FILE IN GITHUB ACTIONS
17. Arange the required config details from aws account for creeateing cicd pipe line. For Ex. ws-access-key-id and aws-secret-access-key.
 

---
  
**Create Docker File Image**

18-1. Create a new file at root named 'Dockerfile'.
18-2. Add following code to Dockerfile set of commands to create docker image.
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
19. Go to task definition in aws and click on the name of task defination. In detail page click on JSON tab. copy all content of json file.
20. Create task defination file at git repo and past all json content. File name Ex.'docker-cicd-task-definition.json'.
21. Create ci/cd file at '.github/workflows/ecs-file.yml'. Set the name of Aws-Image, Cluster, Service, Task-defination file, Container name.

22. Add the following code for create build docker image and deploy to AWS-ECR (Elastic Container Registry). 
The reffrence link for following file "https://docs.github.com/en/actions/deployment/deploying-to-your-cloud-provider/deploying-to-amazon-elastic-container-service"
```
    name: Deploy Node Application on AWS-ECS

on:
  push:
    branches: 
      - express-docker-ecs

jobs:
  deploy:
    
    runs-on: ubuntu-latest
    steps:
      - name: checkout
        uses: actions/checkout@v4
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2
        with:
          mask-password: 'true'

      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
          ECR_REPOSITORY: 'my-docker-cicd'
        run: |
          # Build a docker container and
          # push it to ECR so that it can
          # be deployed to ECS.
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

      - name: Fill in the new image ID in the Amazon ECS task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: 'docker-cicd-task-definition.json'
          container-name: my-docker-cicd
          image: ${{ steps.build-image.outputs.image }}

      - name: Deploy Amazon ECS task definition
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: docker-cicd-service1
          cluster: docker-cicd-ecs
          wait-for-service-stability: true
          
       
        
```
23. Go to the load balancer list in AWS and click created load balancer 'my-node-docker-app-load-balancer'.
24. In detail copy the dns from detail of load balancer.
25. Run it in browser.
##  Things are done on AWS-ECS. Congrats ! :-)
