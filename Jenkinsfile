pipeline {
  
  agent any
  stages {
    
    stage('Lint HTML') {
      steps {
        sh 'tidy -q -e *.html'
      }
    }
    
    stage('Creating Kubernetes Cluster') {
			steps {
				withAWS(region:'eu-west-1', credentials:'aws-static') {
					sh 'echo "Creating Kubernetes Cluster"'
					sh '''
						eksctl create cluster \
						--name capstone \
						--nodegroup-name standard-workers \
						--node-type t2.micro \
						--nodes 2 \
						--nodes-min 1 \
						--nodes-max 3 \
						--node-ami auto \
						--region eu-west-1 \
						--zones eu-west-1a \
						--zones eu-west-1b \
					'''
				}
			}
		}
    
		stage('Create CONF file for the clusterCreate CONF file for the cluster') {
			steps {
				withAWS(region:'eu-west-1', credentials:'aws-static') {
					sh 'pip3 install --upgrade --user awscli'
					sh 'aws --version'
					sh 'aws eks --region eu-west-1 update-kubeconfig --name capstone'
				}
			}
		}

		stage('Build Docker Image') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
					sh '''
						docker build -t mekivala/capstone .
					'''
				}
			}
		}

		stage('Push Image To Dockerhub') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
					sh '''
						docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
						docker push mekivala/capstone
					'''
				}
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
