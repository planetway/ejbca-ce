pipeline {

  agent { label 'jenkins-lin64-slave' }

  environment {
    ejbcaImageName = "723692602888.dkr.ecr.eu-north-1.amazonaws.com/ejbca-ce-app"
    ejbcaVersion = '7.4.3.3'
  }

  stages {
    stage('Build EJBCA Code') {
      steps {
        script {
          // Build number is not used at the moment, it's available for future use.
          echo "----- EJBCA Build Start -----"
            sh './jenkins-files/planetway/run_build.sh ${BUILD_NUMBER}'
          echo "----- EJBCA Build End -----"
        }
      }
    }
    stage('Build EJBCA Docker Image') {
      steps{
        script {
          ejbcaDockerImage = docker.build(ejbcaImageName + ":${ejbcaVersion}.${BUILD_NUMBER}", "-f ./Dockerfile .")
        }
      }
    }
    stage('Push EJBCA Docker Image to Artifactory') {
      steps{
        script {
          docker.withRegistry('https://' + ejbcaImageName) {
            ejbcaDockerImage.push()
          }
        }
      }
    }
  }
}
