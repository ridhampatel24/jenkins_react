pipeline{
    agent any
    tools{
        nodejs "nodeJS"
    }
    stages {
        stage("Fetch Code"){
            steps{
                git branch: 'main', url:'https://github.com/ridhampatel24/jenkins_react.git'
            }
        }

        stage('Build'){
            steps{
                sh 'npm install'
            }
        }

        stage('Build App Image') {
            steps {
                script {
                    dockerImage = docker.build( "react_app" + ":$BUILD_NUMBER", "./")
                }
            }
        }



        
    }
}