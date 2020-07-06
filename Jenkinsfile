pipeline {
  agent any
  stages {
    stage('Lint HTML') {
      steps {
        sh 'tidy -q -e *.html'
      }
    }

    stage('Building image') {
      steps {
        script {
          dockerImage = docker.build registry + ":$BUILD_NUMBER"
        }

      }
    }

    stage('Deploy Image') {
      steps {
        script {
          docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }

      }
    }

    stage('Remove Unused docker image') {
      steps {
        sh "docker rmi $registry:$BUILD_NUMBER"
      }
    }

    stage('Set Current kubectl Context') {
      steps {
        withAWS(region: 'eu-west-1', credentials: 'aws-static') {
          sh 'aws --region eu-west-1 eks update-kubeconfig --name capstoneEKS --role-arn arn:aws:iam::527034694658:role/eksctl-capstone-cluster-ServiceRole-186CPCPBG7YWL'
        }

      }
    }

    stage('Deploy Blue Container') {
      steps {
        withAWS(region: 'eu-west-1', credentials: 'aws-static') {
          sh '''aws --region eu-west-1 eks update-kubeconfig --name capstoneEKS --role-arn arn:aws:iam::527034694658:role/eksctl-capstone-cluster-ServiceRole-186CPCPBG7YWL

kubectl apply -f ./blue-controller.json'''
        }

      }
    }

    stage('Deploy Green Container') {
      steps {
        withAWS(region: 'eu-west-1', credentials: 'aws-static') {
          sh 'kubectl apply -f ./green-controller.json'
        }

      }
    }

    stage('Create the service in the cluster, redirect to blue') {
      steps {
        withAWS(region: 'eu-west-1', credentials: 'aws-static') {
          sh 'kubectl apply -f ./blue-service.json'
        }

      }
    }

    stage('Wait user approve') {
      steps {
        input 'Ready to redirect traffic to green?'
      }
    }

    stage('Create the service in the cluster, redirect to green') {
      steps {
        withAWS(region: 'eu-west-1', credentials: 'aws-static') {
          sh 'kubectl apply -f ./green-service.json'
        }

      }
    }

  }
  environment {
    registry = 'charlesdecott/capstone'
    registryCredential = 'docker-hub'
    dockerImage = ''
  }
}