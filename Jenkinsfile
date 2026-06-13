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
                    cp docker-compose.yml /home/maged/devopsacademy/docker-compose.yml
                    cp -r backend /home/maged/devopsacademy/backend
                    cp Dockerfile /home/maged/devopsacademy/Dockerfile
                    cp nginx.conf /home/maged/devopsacademy/nginx.conf
                    cp index.html /home/maged/devopsacademy/index.html
                    cp admin.html /home/maged/devopsacademy/admin.html
                    cp course.html /home/maged/devopsacademy/course.html
                    cp styles.css /home/maged/devopsacademy/styles.css
                    cp script.js /home/maged/devopsacademy/script.js
                    cp logo.png /home/maged/devopsacademy/logo.png
                    cd /home/maged/devopsacademy
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
