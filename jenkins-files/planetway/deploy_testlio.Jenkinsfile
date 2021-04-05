pipeline {

  agent { label 'jenkins-lin64-slave' }

  parameters {
    string(name: 'EJBCA_APPLICATION_CONTAINER_IMAGE_TAG', defaultValue: 'latest', description: 'Insert EJBCA Docker image tag version here - default is latest')
  }

  environment {
    ejbcaImageName = "artifactory.corp.planetway.com:443/docker-virtual/ejbca-ce-app"
    registryCredential = 'svc.artifac_upload' // this user has read/write permissions
    ejbcaVersion = '7.4.0'
  }

  stages {
    stage('Deploy EJBCA to testlio environment (using docker via ansible)') {
      steps {
      sh 'mkdir -p ansible-ejbca'
        dir("ansible-ejbca") {
          git branch: "master", credentialsId: 'svc.jenkins', url: 'https://bitbucket.corp.planetway.com/scm/infra/planetway_planetid_ansible.git'
          withCredentials([usernamePassword(credentialsId: 'svc.artifac_upload', passwordVariable: 'ARTIFACTORY_USER_PASSWORD', usernameVariable: 'ARTIFACTORY_USERNAME')]) {
          echo "----- Deploy Start (using docker)-----"
              sh '''
                export ARTIFACTORY_USERNAME=${ARTIFACTORY_USERNAME};
                export ARTIFACTORY_USER_PASSWORD=${ARTIFACTORY_USER_PASSWORD};
                export ANSIBLE_SSH_KEY_PATH=/home/jenkins/.ssh/pid_initial_ssh_key;
                export ANSIBLE_SSH_USER=ubuntu;
                export ANSIBLE_SITE_FILE_PATH=site_aws.yml;
                export ANSIBLE_VAULT_KEY_PATH=/home/jenkins/.vault_pass.txt;
                export ANSIBLE_INVETORY_FILE_PATH=inventory/aws/testlio/aws_ec2.yml;
                export ANSIBLE_TAGS='--tags=ejbca';
                export ANSIBLE_EXTRA_VARIABLES="-e ejbca_ca_docker_image_version=${EJBCA_APPLICATION_CONTAINER_IMAGE_TAG} -e ansible_ssh_private_key_file=${ANSIBLE_SSH_KEY_PATH}";
                ./run_ansible.sh
              '''
          echo "----- Deploy End (using docker)-----"
          }
        }
      }
    }
  }

}
