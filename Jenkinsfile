pipeline {
    agent {
        node {
            label 'master'
        }
    }
environment {
        TERRAFORM_CMD = 'docker run -v `pwd`:/app -w /app/ hashicorp/terraform:light'
    }
    stages {
        stage('checkout repo') {
            steps {
            sh """
                checkout scm
            """
            }
        }
        stage('pull latest light terraform image') {
            steps {
                sh  """
                    docker pull hashicorp/terraform:light
                    """
            }
        }
        stage('init') {
            steps {
                sh  """
                    ${TERRAFORM_CMD} init -backend=true -input=false
                    """
            }
        }
        stage('plan') {
            steps {
                sh  """
                    ${TERRAFORM_CMD} plan -out=tfplan -input=false 
                    """
                script {
                  timeout(time: 10, unit: 'MINUTES') {
                    input(id: "Deploy Gate", message: "Deploy ${env.JOB_NAME}?", ok: 'Deploy')
                  }
                }
            }
        }
        stage('apply') {
            steps {
                sh  """
                    ${TERRAFORM_CMD} apply -lock=false -input=false tfplan
                    """
            }
        }
    }
}
