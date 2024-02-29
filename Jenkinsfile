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

        stage('SonarQube analysis') {
            environment {
                scannerHome = tool 'sonar4.7'
            }
            steps {
                withSonarQubeEnv('sonar') {
                sh '''${scannerHome}/bin/sonar-scanner \
                   -Dsonar.projectKey=reactapp \
                   -Dsonar.projectName=react-repo \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=. 
                   '''
                }
            }
        }

        stage('Quality Gate'){
            steps{
                timeout(time: 1, unit: 'HOURS'){
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Build App Image') {
            steps {
                script {
                    dockerImage = docker.build( "react_app_${BUILD_TIMESTAMP}" + ":$BUILD_NUMBER", "./")
                }
            }
        }



        
    }
}