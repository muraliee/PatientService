pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE_NAME = 'patient-service'
        DOCKER_CREDENTIALS_ID = 'dockerhub-cred'
        DOCKER_USERNAME = credentials('dockerhub-cred:username')
        BUILD_TAG = "${BUILD_NUMBER}"
        GIT_REPO_URL = 'https://github.com/yourusername/hospital-management-system.git'
        GIT_BRANCH = 'main'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }

    stages {
        stage('Git Checkout') {
            steps {
                script {
                    echo '========== Git Checkout Started =========='
                    try {
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: "*/${GIT_BRANCH}"]],
                            userRemoteConfigs: [[url: "${GIT_REPO_URL}"]]
                        ])
                        echo '✓ Git Checkout Completed Successfully'
                    } catch (Exception e) {
                        echo "✗ Git Checkout Failed: ${e.message}"
                        throw e
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo '========== Docker Build Started =========='
                    try {
                        dir('PatientService') {
                            sh """
                                echo 'Building Docker image...'
                                docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_TAG} .
                                docker tag ${DOCKER_IMAGE_NAME}:${BUILD_TAG} ${DOCKER_IMAGE_NAME}:latest
                                echo '✓ Docker Image Built Successfully'
                                docker images | grep ${DOCKER_IMAGE_NAME}
                            """
                        }
                    } catch (Exception e) {
                        echo "✗ Docker Build Failed: ${e.message}"
                        throw e
                    }
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    echo '========== Docker Push Started =========='
                    try {
                        withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", 
                                                         passwordVariable: 'DOCKER_PASSWORD', 
                                                         usernameVariable: 'DOCKER_USERNAME')]) {
                            sh """
                                echo 'Logging into DockerHub...'
                                echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

                                echo 'Tagging image for DockerHub...'
                                docker tag ${DOCKER_IMAGE_NAME}:${BUILD_TAG} ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_TAG}
                                docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:latest

                                echo 'Pushing image to DockerHub...'
                                docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_TAG}
                                docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:latest

                                echo '✓ Docker Image Pushed Successfully to DockerHub'
                                echo "Image pushed: ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_TAG}"
                                echo "Latest tag: ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:latest"

                                echo 'Logging out from DockerHub...'
                                docker logout
                            """
                        }
                    } catch (Exception e) {
                        echo "✗ Docker Push Failed: ${e.message}"
                        throw e
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo '========== Pipeline Cleanup =========='
                sh 'docker logout || true'
            }
        }
        success {
            script {
                echo '✓ Pipeline Completed Successfully'
                echo "========================================="
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Docker Image: ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${BUILD_TAG}"
                echo "========================================="
            }
        }
        failure {
            script {
                echo '✗ Pipeline Failed'
                echo "========================================="
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Please check the logs above for errors"
                echo "========================================="
            }
        }
    }
}
