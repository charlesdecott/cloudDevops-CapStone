pipeline {
  
  agent any
  stages {
    
    stage('Lint HTML') {
      steps {
        sh 'tidy -q -e *.html'
      }
    }
    
    

		stage('Build Docker Image') {
			steps {
				app = docker.build("charlesdecott/capstone")
			}
		}

		stage('Push Image To Dockerhub') {
			steps {
				docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
            				app.push("latest")
			}
		}

		stage('Set Current kubectl Context') {
			steps {
				withAWS(region:'us-west-2', credentials:'aws-master') {
					sh '''
						kubectl config use-context arn:aws:eks:eu-west-1:527034694658:cluster/capstone
					'''
				}
			}
		}


		stage('Deploy Blue Container') {
			steps {
				withAWS(region:'us-west-2', credentials:'aws-master') {
					sh '''
						kubectl apply -f ./blue-controller.json
					'''
				}
			}
		}

		stage('Deploy Green Container') {
			steps {
				withAWS(region:'us-west-2', credentials:'aws-master') {
					sh '''
						kubectl apply -f ./green-controller.json
					'''
				}
			}
		}

		stage('Create the service in the cluster, redirect to blue') {
			steps {
				withAWS(region:'us-west-2', credentials:'aws-master') {
					sh '''
						kubectl apply -f ./blue-service.json
					'''
				}
			}
		}

		stage('Wait user approve') {
            steps {
                input "Ready to redirect traffic to green?"
            }
        }

		stage('Create the service in the cluster, redirect to green') {
			steps {
				withAWS(region:'us-west-2', credentials:'aws-master') {
					sh '''
						kubectl apply -f ./green-service.json
					'''
				}
			}
		}

    }
}
