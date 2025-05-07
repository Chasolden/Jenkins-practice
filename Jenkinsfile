pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = 'brightex99/brighthub'
        TAG = "${BUILD_NUMBER}"
        DOCKERFILE_PATH = './Dockerfile'
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS_ID = 'docker_credentials_id'
        SNYK_TOKEN = credentials('snyk-api-token')
        VM_USER = 'bright'
        VM_HOST = '192.168.168.134'
        VM_DEPLOY_DIR = '/home/bright'
        SSH_CREDENTIALS_ID = 'bright-ssh-creds-id'
    }
    stages {
        stage('build stage') {
            steps {
                echo "Building docker image..."
                sh """
                    docker build -f ${DOCKERFILE_PATH} \
                    -t ${DOCKER_IMAGE_NAME}:${TAG} .
                    docker images | grep ${DOCKER_IMAGE_NAME}
                """
            }
        }
        stage('testing stage') {
            steps {
                echo "Scanning docker image ..."
                withCredentials([string(credentialsId: 'snyk-api-token', variable: 'SNYK_TOKEN')]) {
                    sh 'snyk auth $SNYK_TOKEN'
                    sh "snyk test --docker ${DOCKER_IMAGE_NAME}:${TAG} || true"

                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                echo "Pushing image to Docker Hub..."
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${DOCKER_IMAGE_NAME}:${TAG}"
                }
            }
        }

        stage('Deploy to VM') {
            steps {
                echo "Deploying to remote VM..."
                sshagent (credentials: ["${SSH_CREDENTIALS_ID}"]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${VM_USER}@${VM_HOST} '
                        docker pull ${DOCKER_IMAGE_NAME}:${TAG} &&
                        docker stop helloapp || true &&
                        docker rm helloapp || true &&
                        docker run -d --name helloapp -p 6565:6565 ${DOCKER_IMAGE_NAME}:${TAG}
                    '
                    """
                }
            }
        }
    }
}