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

  }
}
