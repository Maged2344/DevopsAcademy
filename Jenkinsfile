pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    }

    triggers {
        pollSCM('* * * * *')  // Poll GitHub every minute for changes
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Maged2344/DevopsAcademy.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                retry(3) {
                    sh '''
                        echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                        docker push magedmohamed/devopsacademy-web:latest
                        docker push magedmohamed/devopsacademy-backend:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    DEPLOY_DIR=/home/maged/devopsacademy

                    cd $DEPLOY_DIR

                    # Stop running containers first (releases bind mounts)
                    docker compose down || true

                    # Clean old files (keep ssl/ and docker volumes)
                    rm -rf $DEPLOY_DIR/frontend $DEPLOY_DIR/backend $DEPLOY_DIR/nginx
                    docker run --rm -v $DEPLOY_DIR/monitoring:/mnt alpine sh -c "rm -rf /mnt/*" 2>/dev/null || true
                    rm -rf $DEPLOY_DIR/monitoring
                    rm -f $DEPLOY_DIR/index.html $DEPLOY_DIR/admin.html $DEPLOY_DIR/course.html
                    rm -f $DEPLOY_DIR/script.js $DEPLOY_DIR/styles.css $DEPLOY_DIR/logo.png
                    rm -f $DEPLOY_DIR/nginx.conf $DEPLOY_DIR/Dockerfile

                    cd $OLDPWD

                    # Copy fresh project structure
                    cp docker-compose.yml $DEPLOY_DIR/docker-compose.yml
                    cp -r backend $DEPLOY_DIR/backend
                    cp -r frontend $DEPLOY_DIR/frontend
                    cp -r nginx $DEPLOY_DIR/nginx
                    cp -r monitoring $DEPLOY_DIR/monitoring

                    cd $DEPLOY_DIR
                    docker compose build --no-cache
                    docker compose up -d
                    docker image prune -f
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment successful! Site is live at https://devopsacademy.cloud-stacks.com'
        }
        failure {
            echo 'Deployment failed. Check the logs.'
        }
    }
}
