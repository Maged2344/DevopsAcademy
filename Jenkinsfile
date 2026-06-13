pipeline {
    agent any

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

        stage('Deploy') {
            steps {
                sh '''
                    DEPLOY_DIR=/home/maged/devopsacademy

                    # Clean old files (keep ssl/ and docker volumes)
                    rm -rf $DEPLOY_DIR/frontend $DEPLOY_DIR/backend $DEPLOY_DIR/nginx
                    rm -f $DEPLOY_DIR/index.html $DEPLOY_DIR/admin.html $DEPLOY_DIR/course.html
                    rm -f $DEPLOY_DIR/script.js $DEPLOY_DIR/styles.css $DEPLOY_DIR/logo.png
                    rm -f $DEPLOY_DIR/nginx.conf $DEPLOY_DIR/Dockerfile

                    # Copy fresh project structure
                    cp docker-compose.yml $DEPLOY_DIR/docker-compose.yml
                    cp -r backend $DEPLOY_DIR/backend
                    cp -r frontend $DEPLOY_DIR/frontend
                    cp -r nginx $DEPLOY_DIR/nginx

                    cd $DEPLOY_DIR
                    docker compose down || true
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
