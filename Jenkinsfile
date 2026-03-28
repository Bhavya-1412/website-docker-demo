pipeline {  
    agent any  

    environment {
        AWS_REGION      = 'ap-south-1'
        ECR_REPO        = 'website-docker-demo'
        AWS_ACCOUNT_ID  = '522706696705'
        IMAGE_TAG       = "${env.BUILD_NUMBER}"
        IMAGE_URI       = AWS_ACCOUNT_ID + ".dkr.ecr." + AWS_REGION + ".amazonaws.com/" + ECR_REPO + ":" + IMAGE_TAG
        LATEST_URI      = AWS_ACCOUNT_ID + ".dkr.ecr." + AWS_REGION + ".amazonaws.com/" + ECR_REPO + ":latest"
        DEPLOY_SERVER   = '13.232.91.6'
        CONTAINER_NAME  = 'website-demo'
        EC2_USER        = 'ubuntu'
    }

    stages {  

        stage('Checkout') {  
            steps {  
                git branch: 'main', url: 'https://github.com/Bhavya-1412/website-docker-demo.git'  
            }  
        }  

        stage('Build Docker Image') {  
            steps {  
                sh 'docker build -t website-docker-demo .'  
            }  
        }  

        stage('Tag Docker Image') {  
            steps {  
                sh """  
                    docker tag website-docker-demo:latest $IMAGE_URI  
                    docker tag website-docker-demo:latest $LATEST_URI  
                """  
            }  
        }  

        stage('Login to ECR') {  
            steps {  
                sh """  
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com  
                """  
            }  
        }  

        stage('Push Image to ECR') {  
            steps {  
                sh """  
                    docker push $IMAGE_URI  
                    docker push $LATEST_URI  
                """  
            }  
        }  

        stage('Deploy to EC2') {  
            steps {  
                sshagent(['deploy-ec2-key']) {  
                    sh """  
                        ssh -o StrictHostKeyChecking=no $EC2_USER@$DEPLOY_SERVER '
                            set -e
                            
                            echo "Logging in to ECR..."
                            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                            
                            echo "Pulling latest image..."
                            docker pull $LATEST_URI
                            
                            echo "Stopping old container if exists..."
                            docker stop $CONTAINER_NAME || true
                            docker rm $CONTAINER_NAME || true
                            
                            echo "Running new container..."
                            docker run -d --name $CONTAINER_NAME -p 80:80 $LATEST_URI
                            
                            echo "Deployment successful!"
                        '
                    """  
                }  
            }  
        }  
    }  

    post {  
        success {  
            echo 'Website deployed successfully ✅'  
        }  
        failure {  
            echo 'Pipeline failed ❌ Check logs'  
        }  
    }  
}