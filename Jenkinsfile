pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        checkout([						$class: 'GitSCM', 						branches: [[name: '*/master']], 						doGenerateSubmoduleConfigurations: false, 						extensions: [], 						submoduleCfg: [], 						userRemoteConfigs: [[credentialsId: 'GitHub_Credentials', url: 'https://github.com/ekoo7/ma_project-2.git']]					])
      }
    }
    stage('Code Analyse') {
      steps {
        sh 'echo "Code Analyse durchführen"'
      }
    }
    stage('Build') {
      steps {
        script {
          sh "mvn clean install package"
        }

      }
    }
    stage('Deploy Build To Ansible Host') {
      steps {
        sshPublisher(publishers: [
          						sshPublisherDesc(
            							configName: 'ansible-docker-server', 
            							transfers: [
              								sshTransfer(cleanRemote: false, 
              									excludes: '', 
              									execCommand: '', 
              									execTimeout: 120000, 
              									flatten: false, 
              									makeEmptyDirs: false, 
              									noDefaultExcludes: false, 
              									patternSeparator: '[, ]+', 
              									remoteDirectory: '//opt//docker', 
              									remoteDirectorySDF: false, 
              									removePrefix: 'webapp/target', 
              									sourceFiles: 'webapp/target/*.war')], 
              							usePromotionTimestamp: false, 
              							useWorkspaceInPromotion: false, 
              							verbose: false
              						)
              					])
            }
          }
          stage('Create Docker Container And Push To Repository') {
            steps {
              sshPublisher(publishers: [sshPublisherDesc(
                						configName: 'ansible-docker-server', 
                						transfers: [sshTransfer(
                  							cleanRemote: false, 
                  								excludes: '', 
                  								execCommand: '''cd /opt/docker
								docker build -t $JOB_NAME:v1.$BUILD_ID .
								docker tag $JOB_NAME:v1.$BUILD_ID ekoo7/$JOB_NAME:v1.$BUILD_ID
								docker tag $JOB_NAME:v1.$BUILD_ID ekoo7/$JOB_NAME:latest
								docker push ekoo7/$JOB_NAME:v1.$BUILD_ID
								docker push ekoo7/$JOB_NAME:latest
								docker rmi $JOB_NAME:v1.$BUILD_ID ekoo7/$JOB_NAME:v1.$BUILD_ID ekoo7/$JOB_NAME:latest''', 
                  								execTimeout: 120000, 
                  								flatten: false, 
                  								makeEmptyDirs: false, 
                  								noDefaultExcludes: false, 
                  								patternSeparator: '[, ]+', 
                  								remoteDirectory: '//opt//docker', 
                  								remoteDirectorySDF: false, 
                  								removePrefix: '', 
                  								sourceFiles: 'Dockerfile'
                  							)
                  						], 
                  							usePromotionTimestamp: false, 
                  							useWorkspaceInPromotion: false, 
                  							verbose: false
                  					)
                  				])
                }
              }
              stage('TEST-ENV Compliance Test') {
                steps {
                  echo 'Compliance Tests in TEST-ENV durchführen...'
                  sshPublisher(publishers: [
                    						sshPublisherDesc(
                      							configName: 'ansible-docker-server', 
                      							transfers: [
                        								sshTransfer(
                          									cleanRemote: false, 
                          									excludes: '', 
                          									execCommand: '''cd /opt/playbooks/
									ansible-playbook compliance_tests_env.yml --extra-vars "variable_host=testenv"''', 
                          									execTimeout: 120000, 
                          									flatten: false, 
                          									makeEmptyDirs: false, 
                          									noDefaultExcludes: false, 
                          									patternSeparator: '[, ]+', 
                          									remoteDirectory: '', 
                          									remoteDirectorySDF: false, 
                          									removePrefix: '', 
                          									sourceFiles: ''
                          								)
                          							], 
                          							usePromotionTimestamp: false, 
                          							useWorkspaceInPromotion: false, 
                          							verbose: false
                          						)
                          					])
                        }
                      }
                      stage('Deploy to TEST-ENV ...') {
                        steps {
                          sshPublisher(publishers: [
                            						sshPublisherDesc(
                              							configName: 'ansible-docker-server', 
                              							transfers: [
                                								sshTransfer(
                                  									cleanRemote: false, 
                                  									excludes: '', 
                                  									execCommand: '''cd /opt/playbooks/
										ansible-playbook deploy_docker_container.yml --extra-vars "variable_host=testenv"''', 
                                  									execTimeout: 120000, 
                                  									flatten: false, 
                                  									makeEmptyDirs: false, 
                                  									noDefaultExcludes: false, 
                                  									patternSeparator: '[, ]+', 
                                  									remoteDirectory: '', 
                                  									remoteDirectorySDF: false, 
                                  									removePrefix: '', 
                                  									sourceFiles: ''
                                  								)
                                  							], 
                                  							usePromotionTimestamp: false, 
                                  							useWorkspaceInPromotion: false, 
                                  							verbose: false
                                  						)
                                  					])
                                }
                              }
                              stage('TEST-ENV Compliance Test Container') {
                                steps {
                                  echo 'Compliance Tests in TEST-ENV im Docker Container durchführen...'
                                  sshPublisher(publishers: [
                                    						sshPublisherDesc(
                                      							configName: 'ansible-docker-server', 
                                      							transfers: [
                                        								sshTransfer(
                                          									cleanRemote: false, 
                                          									excludes: '', 
                                          									execCommand: '''cd /opt/playbooks/
									ansible-playbook compliance_tests_container.yml --extra-vars "variable_host=testenv"
									ansible-playbook inspec_webserver.yml --extra-vars "variable_host=testenv"''', 
                                          									execTimeout: 120000, 
                                          									flatten: false, 
                                          									makeEmptyDirs: false, 
                                          									noDefaultExcludes: false, 
                                          									patternSeparator: '[, ]+', 
                                          									remoteDirectory: '', 
                                          									remoteDirectorySDF: false, 
                                          									removePrefix: '', 
                                          									sourceFiles: ''
                                          								)
                                          							], 
                                          							usePromotionTimestamp: false, 
                                          							useWorkspaceInPromotion: false, 
                                          							verbose: false
                                          						)
                                          					])
                                        }
                                      }
                                      stage('Manual Approval for QA-Deployment') {
                                        input {
                                          message 'Soll die Applikation in die QA-ENV deployt werden?'
                                          id 'Ja.'
                                        }
                                        steps {
                                          echo 'Compliance Tests und Deployment werden durchgeführt.'
                                        }
                                      }
                                      stage('QA-ENV Compliance Test') {
                                        steps {
                                          echo 'Compliance Tests in QA-ENV durchführen...'
                                          sshPublisher(publishers: [
                                            						sshPublisherDesc(
                                              							configName: 'ansible-docker-server', 
                                              							transfers: [
                                                								sshTransfer(
                                                  									cleanRemote: false, 
                                                  									excludes: '', 
                                                  									execCommand: '''cd /opt/playbooks/
									ansible-playbook compliance_tests_env.yml --extra-vars "variable_host=qaenv"''', 
                                                  									execTimeout: 120000, 
                                                  									flatten: false, 
                                                  									makeEmptyDirs: false, 
                                                  									noDefaultExcludes: false, 
                                                  									patternSeparator: '[, ]+', 
                                                  									remoteDirectory: '', 
                                                  									remoteDirectorySDF: false, 
                                                  									removePrefix: '', 
                                                  									sourceFiles: ''
                                                  								)
                                                  							], 
                                                  							usePromotionTimestamp: false, 
                                                  							useWorkspaceInPromotion: false, 
                                                  							verbose: false
                                                  						)
                                                  					])
                                                }
                                              }
                                              stage('Deploy to QA-ENV ...') {
                                                steps {
                                                  sshPublisher(publishers: [
                                                    						sshPublisherDesc(
                                                      							configName: 'ansible-docker-server', 
                                                      							transfers: [
                                                        								sshTransfer(
                                                          									cleanRemote: false, 
                                                          									excludes: '', 
                                                          									execCommand: '''cd /opt/playbooks/
									ansible-playbook deploy_docker_container.yml --extra-vars "variable_host=qaenv"''', 
                                                          									execTimeout: 120000, 
                                                          									flatten: false, 
                                                          									makeEmptyDirs: false, 
                                                          									noDefaultExcludes: false, 
                                                          									patternSeparator: '[, ]+', 
                                                          									remoteDirectory: '', 
                                                          									remoteDirectorySDF: false, 
                                                          									removePrefix: '', 
                                                          									sourceFiles: ''
                                                          								)
                                                          							], 
                                                          							usePromotionTimestamp: false, 
                                                          							useWorkspaceInPromotion: false, 
                                                          							verbose: false
                                                          						)
                                                          					])
                                                        }
                                                      }
                                                      stage('QA-ENV Compliance Test Container') {
                                                        steps {
                                                          echo 'Compliance Tests in QA-ENV im Docker Container durchführen...'
                                                          sshPublisher(publishers: [
                                                            						sshPublisherDesc(
                                                              							configName: 'ansible-docker-server', 
                                                              							transfers: [
                                                                								sshTransfer(
                                                                  									cleanRemote: false, 
                                                                  									excludes: '', 
                                                                  									execCommand: '''cd /opt/playbooks/
									ansible-playbook compliance_tests_container.yml --extra-vars "variable_host=qaenv"''', 
                                                                  									execTimeout: 120000, 
                                                                  									flatten: false, 
                                                                  									makeEmptyDirs: false, 
                                                                  									noDefaultExcludes: false, 
                                                                  									patternSeparator: '[, ]+', 
                                                                  									remoteDirectory: '', 
                                                                  									remoteDirectorySDF: false, 
                                                                  									removePrefix: '', 
                                                                  									sourceFiles: ''
                                                                  								)
                                                                  							], 
                                                                  							usePromotionTimestamp: false, 
                                                                  							useWorkspaceInPromotion: false, 
                                                                  							verbose: false
                                                                  						)
                                                                  					])
                                                                }
                                                              }
                                                              stage('Manual Approval for PROD-Deployment') {
                                                                input {
                                                                  message 'Soll die Applikation in die PROD-ENV deployt werden?'
                                                                  id 'Ja.'
                                                                }
                                                                steps {
                                                                  echo 'Compliance Tests und Deployment werden durchgeführt.'
                                                                }
                                                              }
                                                              stage('PROD-ENV Compliance Test') {
                                                                steps {
                                                                  echo 'Compliance Tests in TEST-ENV durchführen...'
                                                                  sshPublisher(publishers: [
                                                                    						sshPublisherDesc(
                                                                      							configName: 'ansible-docker-server', 
                                                                      							transfers: [
                                                                        								sshTransfer(
                                                                          									cleanRemote: false, 
                                                                          									excludes: '', 
                                                                          									execCommand: '''cd /opt/playbooks/
									ansible-playbook compliance_tests_env.yml --extra-vars "variable_host=qaenv"''', 
                                                                          									execTimeout: 120000, 
                                                                          									flatten: false, 
                                                                          									makeEmptyDirs: false, 
                                                                          									noDefaultExcludes: false, 
                                                                          									patternSeparator: '[, ]+', 
                                                                          									remoteDirectory: '', 
                                                                          									remoteDirectorySDF: false, 
                                                                          									removePrefix: '', 
                                                                          									sourceFiles: ''
                                                                          								)
                                                                          							], 
                                                                          							usePromotionTimestamp: false, 
                                                                          							useWorkspaceInPromotion: false, 
                                                                          							verbose: false
                                                                          						)
                                                                          					])
                                                                        }
                                                                      }
                                                                      stage('Deploy to PROD-ENV ...') {
                                                                        steps {
                                                                          sshPublisher(publishers: [
                                                                            						sshPublisherDesc(
                                                                              							configName: 'ansible-docker-server', 
                                                                              							transfers: [
                                                                                								sshTransfer(
                                                                                  									cleanRemote: false, 
                                                                                  									excludes: '', 
                                                                                  									execCommand: '''cd /opt/playbooks/
									ansible-playbook deploy_docker_container.yml --extra-vars "variable_host=prodenv"''', 
                                                                                  									execTimeout: 120000, 
                                                                                  									flatten: false, 
                                                                                  									makeEmptyDirs: false, 
                                                                                  									noDefaultExcludes: false, 
                                                                                  									patternSeparator: '[, ]+', 
                                                                                  									remoteDirectory: '', 
                                                                                  									remoteDirectorySDF: false, 
                                                                                  									removePrefix: '', 
                                                                                  									sourceFiles: ''
                                                                                  								)
                                                                                  							], 
                                                                                  							usePromotionTimestamp: false, 
                                                                                  							useWorkspaceInPromotion: false, 
                                                                                  							verbose: false
                                                                                  						)
                                                                                  					])
                                                                                }
                                                                              }
                                                                              stage('PROD-ENV Compliance Test Container') {
                                                                                steps {
                                                                                  echo 'Compliance Tests in PROD-ENV im Docker Container durchführen...'
                                                                                  sshPublisher(publishers: [
                                                                                    						sshPublisherDesc(
                                                                                      							configName: 'ansible-docker-server', 
                                                                                      							transfers: [
                                                                                        								sshTransfer(
                                                                                          									cleanRemote: false, 
                                                                                          									excludes: '', 
                                                                                          									execCommand: '''cd /opt/playbooks/
									ansible-playbook compliance_tests_container.yml --extra-vars "variable_host=prodenv"''', 
                                                                                          									execTimeout: 120000, 
                                                                                          									flatten: false, 
                                                                                          									makeEmptyDirs: false, 
                                                                                          									noDefaultExcludes: false, 
                                                                                          									patternSeparator: '[, ]+', 
                                                                                          									remoteDirectory: '', 
                                                                                          									remoteDirectorySDF: false, 
                                                                                          									removePrefix: '', 
                                                                                          									sourceFiles: ''
                                                                                          								)
                                                                                          							], 
                                                                                          							usePromotionTimestamp: false, 
                                                                                          							useWorkspaceInPromotion: false, 
                                                                                          							verbose: false
                                                                                          						)
                                                                                          					])
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                    tools {
                                                                                      maven 'Maven'
                                                                                    }
                                                                                  }