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
                rm -rf /var/lib/jenkins/workspace/tmp
                rm -rf /var/lib/jenkins/workspace/${env.JOB_NAME}/*
                git clone https://TrekDevOps:WQrULM66cGyPyB@bitbucket.org/trekbikes/${env.JOB_NAME}.git /var/lib/jenkins/workspace/tmp
                mv /var/lib/jenkins/workspace/tmp/* /var/lib/jenkins/workspace/${env.JOB_NAME}
                rm -rf /var/lib/jenkins/workspace/tmp
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
