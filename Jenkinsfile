@Library ('infra') _
pipeline { 
    agent any 
      triggers {
          githubPush()
      }
    /*DEFINICION DE TODAS LAS VARIABLES QUE SERÁN NECESARIAS PARA CADA PROYECTO Y BRANCH*/
      environment{
        URL_GIT_INFRA_SCRIPTS="https://raw.githubusercontent.com/tikoglobal/tiko-infra/dev/vars/"
        ENVIRONMENTS_INFRA="secret/data/jenkins/tiko-infra"        
        ENVIRONMENTS_GLOBAL="secret/data/jenkins/tiko-global"        
        PROYECT = 'logistics-api'
        VAULT_PATH_PR = "secret/data/jenkins/logistics-api/"
        ENV_TEST = "FALSE"
        URL_VAULT = "http://3.18.18.13:8200"
        TAG = """${sh(returnStdout: true,script: 'echo "${JOB_NAME}_${BUILD_NUMBER}" |sed "s#/#_#g"')}"""
        URL_PROYECT = """${sh(returnStdout: true,script: 'echo "https://github.com/tikoglobal/${JOB_NAME}.git/" | sed "s#/${BRANCH_NAME}##g"')}"""
      }
    stages {
      /*ETAPA DONDE OBTIENE TODO EL CODIGO DESDE GITHUB*/
      stage('CheckOut') {
        steps {
          cleanWs()
          echo "Cleaned Up Workspace For Project $TAG"
          checkout scm
          script{
            withCredentials(
              [usernamePassword(credentialsId: 'GitHubTikoMachineUser', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                sh "chmod +x cleanSetup.sh && ./cleanSetup.sh"
              }
            withCredentials(
            [usernamePassword(credentialsId: 'vaultAccesWithRole', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) { 
              echo "Get environments INFRA..."
              sh"./getEnvVault_Source.sh $URL_VAULT $ENVIRONMENTS_INFRA $USERNAME $PASSWORD sourceEnvironment.sh"
            }
          }
        }
      }
      stage('Unit Testing') {
	  steps {
              script{
                withCredentials(
                [usernamePassword(credentialsId: 'vaultAccesWithRole', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) { 
                    sh "./createEnvFile.sh ${USERNAME} ${PASSWORD}"
                  if (env.ENV_TEST == 'FALSE') {
                    setEnvironment("Dockerfile.migrator","${BRANCH_NAME}", "true")
                  }else {
                    setEnvironment("Dockerfile.migrator","dev", "true")
                  }
                  if (env.BRANCH_NAME == 'dev') {
                    setEnvironment("Dockerfile.migrator","qa","false")
                  }else if (env.BRANCH_NAME == 'master') {
                    setEnvironment("Dockerfile.migrator","demo","false")
                  }
                }
              }
      	}
      }
      /*ETAPA DONDE COMPILA Y LUEGO LO SUBE A DOCKER HUB*/
      stage('Build & Delivery to DockerHub') {
        steps {
          script{
            withCredentials(
            [usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
              def nuevoTag = env.TAG.replaceAll("\n","")
                sh "./buildContainer.sh"
            }
          }
        }
      }
      stage('Aprobación'){
        when {
            expression {
              BRANCH_NAME ==~ /(master)/ 
            }
        }
        steps{
          script{
            stageSanityCheck.approval('master')
          }  
        }
      }        
      /*ETAPA DONDE REALIZA EL BACKUP DEL CONTENEDOR ACTUAL QUE SERÁ REEMPLAZADO Y LUEGO GENERA EL DEPLOY DE LO COMPILADO ANTERIORMENTE */
      stage('Deploy on Remote Host') {
        parallel {
          stage ('Deploy '){
            steps {
              script{
                def nuevoTag = env.TAG.replaceAll("\n","")
                sshagent (credentials: ['ssh-andres']) {
                  withCredentials(
                    [usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                      /*DEPLOY DEL CONTENEDOR NUEVO*/
                        sh "./deployContainer.sh origin"
                  }
                }
              }
            }
          }
          stage('Deploy on QA'){
              when{
                  branch 'dev'
              }
            steps {
              script{
                def nuevoTag = env.TAG.replaceAll("\n","")
                sshagent (credentials: ['ssh-andres']) {
                  withCredentials(
                    [usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        /*DEPLOY DEL CONTENEDOR NUEVO*/
                      sh "./deployContainer.sh ${BRANCH_NAME}"
                  }
                }
              }
            }
          }
          stage('Deploy on Demo'){
              when{
                  branch 'master'
              }
            steps {
              script{
                def nuevoTag = env.TAG.replaceAll("\n","")
                sshagent (credentials: ['ssh-andres']) {
                  withCredentials(
                    [usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        /*DEPLOY DEL CONTENEDOR NUEVO*/
                      sh "./deployContainer.sh ${BRANCH_NAME}"
                  }
                }
              }
            }
          }
        }
      }
    }
    /*LUEGO DE FINALIZADO EL PROCESO ENVIA MAIL Y/O REALIZA ACCIONES SEGUN EL RESULTADO*/
    post {  
          success {
            script{
              utility.sendNotificaciones('True', 'True', '#BADA55', 'The operation was completed successfully on ', 'success')
            }
          }
          failure {
            script{
              utility.sendNotificaciones('True', 'True', '#FF5733', 'The operation ended with errors on ' + "${env.BUILD_URL}", 'failure')
            }
          }
          unstable {
            script{
              utility.sendNotificaciones('True', 'True', '#FAF30F', 'The operation was completed but the environment is unstable on ', 'unstable')
            }
          }
      }
    options {
      buildDiscarder(logRotator(daysToKeepStr: '15', numToKeepStr: '50'))
    }
  }
def setEnvironment(dockerFile_v, branchEnvironment, runTest){
  if (runTest == 'true'){  
    sh '''
      . ./sourceEnvironment.sh
      chmod +x generaDockerfile.sh
      ./generaDockerfile.sh '''+"${dockerFile_v}" + ''' ${FILE_ENVIRONMENT}_'''+"${branchEnvironment}"+'''
      cp ${FILE_ENVIRONMENT}_'''+"${branchEnvironment}"+''' tmp_source.sh
      chmod +x tmp_source.sh
      chmod +x run-tests.sh
      ./run-tests.sh
      docker push ${DOCKER_HUB_REPO}:logistics-api_ci_migrations
    '''
  }
}
