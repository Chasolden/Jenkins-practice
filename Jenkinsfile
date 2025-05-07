pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = 'brightex99/helloapp'
        TAG = "${BUILD_NUMBER}"
        DOCKERFILE_PATH = './Dockerfile'
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS_ID = '8b10758e-5915-4b7d-aabb-a0c662c6c5eb'
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
                script {
                      image = docker.build("${DOCKER_IMAGE_NAME}:${TAG}", "apps/helloapp")
                }
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
    }
}