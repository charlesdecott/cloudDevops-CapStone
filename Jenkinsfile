pipeline {

	environment {
	    registry = "charlesdecott/capstone"
	    registryCredential = 'docker-hub'
	}
  
  agent any
  stages {
    
    stage('Lint HTML') {
      steps {
        sh 'tidy -q -e *.html'
      }
    }
	  
    stage('Lint Dockerfile') {
                    steps {

                        sh 'hadolint --ignore DL3006 --ignore SC2028 --ignore DL3008 --ignore DL3015 Dockerfile'



                    }
        }
    
	stage('Build docker image') {
                    steps {

                        withCredentials([usernamePassword( credentialsId: 'docker-hub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
				sh 'echo "the value of username is ${USERNAME} and password id ${PASSWORD}"'
				sh "docker login -u ${USERNAME} -p ${PASSWORD}"
				sh 'docker build --tag=charlesdecott/capstone:latest .'

			 }
       	 	}
        }
	  
		stage('Build Docker Image') {
			steps {
				app = docker.build("charlesdecott/capstone")
			}
		}

		stage('Push Image To Dockerhub') {
			steps {
				docker.withRegistry('https://registry.hub.docker.com', 'docker-hub') {
            				app.push("latest")
					
				}
			}
		}

		stage('Set Current kubectl Context') {
			steps {
				withAWS(region:'us-west-2', credentials:'aws-static') {
					sh '''
						kubectl config use-context arn:aws:eks:eu-west-1:527034694658:cluster/capstone
					'''
				}
			}
		}


		stage('Deploy Blue Container') {
			steps {
				withAWS(region:'us-west-2', credentials:'aws-static') {
					sh '''
						kubectl apply -f ./blue-controller.json
					'''
				}
			}
		}

		stage('Deploy Green Container') {
			steps {
				withAWS(region:'us-west-2', credentials:'aws-static') {
					sh '''
						kubectl apply -f ./green-controller.json
					'''
				}
			}
		}

		stage('Create the service in the cluster, redirect to blue') {
			steps {
				withAWS(region:'us-west-2', credentials:'aws-static') {
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
				withAWS(region:'us-west-2', credentials:'aws-static') {
					sh '''
						kubectl apply -f ./green-service.json
					'''
				}
			}
		}

    }
}
