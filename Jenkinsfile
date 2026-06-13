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
                sh 'docker build -t magedmohamed/devopsacademy:latest .'
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    cd /home/maged/devopsacademy
                    docker compose down || true
                    docker compose up -d
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment successful! Site is live at https://20.25.62.124'
        }
        failure {
            echo 'Deployment failed. Check the logs.'
        }
    }
}
