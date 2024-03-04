def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger',
]

pipeline{
    agent any
    environment{
        registryCredential = 'ecr:us-east-1:awscreds'
        appRegistry = "533267180280.dkr.ecr.us-east-1.amazonaws.com/reactrepo"
        reactappRegistry = "https://533267180280.dkr.ecr.us-east-1.amazonaws.com" 
        cluster = "reactcluster"
        service = "servicename"   
    }

    tools{
        nodejs "nodeJS"
    }

    stages {
        stage("Fetch Code"){
            steps{
                git branch: 'main', url:'https://github.com/ridhampatel24/jenkins_react.git'
            }

            post {
                success {
                    slackSend channel: '#jenkinscicd',
                    color: COLOR_MAP[currentBuild.currentResult],
                    message: "*${currentBuild.currentResult}:* Fetch Code Complete. SonarQube Analysis Starts..."
                }
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

            post {
                success {
                    slackSend channel: '#jenkinscicd',
                    color: COLOR_MAP[currentBuild.currentResult],
                    message: "*${currentBuild.currentResult}:* Sonar Analysis Completed."
                }
            }
        }

        stage('Quality Gate'){
            steps{
                timeout(time: 1, unit: 'HOURS'){
                    waitForQualityGate abortPipeline: true
                }
            }

            post {
                success {
                    slackSend channel: '#jenkinscicd',
                    color: COLOR_MAP[currentBuild.currentResult],
                    message: "*${currentBuild.currentResult}:* Quality Gate Passed. Building Docker Image..."
                }
            }
        }
        
        stage('Build App Docker Image') {
            steps {
                script {
                    dockerImage = docker.build( appRegistry + ":$BUILD_NUMBER", "./")
                }
            }
            post {
                success {
                    slackSend channel: '#jenkinscicd',
                    color: COLOR_MAP[currentBuild.currentResult],
                    message: "*${currentBuild.currentResult}:* Docker Image is Build. Uploading Image..."
                }
            }
        }

        stage('Upload App Image') {
          steps{
            script {
              docker.withRegistry( reactappRegistry, registryCredential ) {  
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')
              }
            }
          }

          post {
                success {
                    slackSend channel: '#jenkinscicd',
                    color: COLOR_MAP[currentBuild.currentResult],
                    message: "*${currentBuild.currentResult}:* Docker Image Uploaded Succesfully to ECR"
                }
            }
        }

        // stage('Deploy to ECS') {
        //     steps{
        //         withAWS(credentials: 'awscreds' , region: 'us-east-1'){
        //             sh 'aws ecs update-service --cluster ${cluster} --service ${service} --force-new-deployment'
        //         }
        //     }
        // }
        
    }

    post {
        always {
            slackSend channel: '#jenkinscicd',
            color: COLOR_MAP[currentBuild.currentResult],
            message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }


}