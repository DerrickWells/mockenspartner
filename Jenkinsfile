ciBuild = env.CI == null ? true : env.CI.toLowerCase() == 'true'
buildRepo = "mock_ens_partner"
productName = "mockenspartner"
buildName = "mockenspartner"
organization = "com.mock_ens_partner"
dockerImageBaseName = "${productName}/${buildName}"

def applicationName = "${productName.capitalize()} ${buildName.capitalize()}"
def environmentName = "${productName.capitalize()}-${buildName.capitalize()}"
def artifactory = getArtifactoryServer(artifactoryServerID: env.ARTIFACTORY_NAME)
def buildInfo = newBuildInfo()
buildInfo.retention maxBuilds: 10, deleteBuildArtifacts: true

pipeline {
    agent none

    options {
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr:'10'))
        skipDefaultCheckout()
        timestamps()
    }

    stages {
        stage('Version') {
            agent { label 'git' }
            steps {
                checkout scm
                script {
                    relVersion='0.0'
                    buildType = ciBuild ? 'ci' : 'integration'
                    cmBuildNumber = "${relVersion}.${BUILD_NUMBER}"
                    cmReleaseTag = "release/${buildName}/${relVersion}"
                    cmBuildTag = "build/${buildName}/${cmBuildNumber}"
                    dockerRegistry = ciBuild ? env.ARTIFACTORY_REGISTRY_CI : env.ARTIFACTORY_REGISTRY_QA
                    npmRepo = ciBuild ? env.ARTIFACTORY_NPM_CI : env.ARTIFACTORY_NPM_QA


                    gerritEnvironment = [
                        "VCS_REPO=${buildRepo}"
                    ]
                    if (env.GERRIT_REFSPEC != null) {
                        gerritEnvironment = [
                            "VCS_REF=${GERRIT_PATCHSET_REVISION}",
                            "VCS_REPO=${GERRIT_PROJECT}"
                        ]
                    }

                    stepEnvironment = gerritEnvironment + [
                        "BUILD_NAME = ${buildName}",
                        "CM_BUILD_NUMBER=${cmBuildNumber}",
                        "PRODUCT=${productName}",
                        "REL_VERSION=${relVersion}",
                        "DOCKER_REPO=${dockerImageBaseName}",
						"TF_VAR_application_name=${applicationName}",
						"TF_VAR_environment_name=${environmentName}",
						"TF_VAR_terraform_access_role=${env.AWS_ACCOUNT_ROLE}"
                    ]
                }
                echo "Build type: ${buildType}"
                echo "Release version: ${relVersion}"
                echo "Build version: ${cmBuildNumber}"
                echo "Build tag: ${cmBuildTag}"

            }
            
        }
    
        stage('Build') {
            agent { label 'docker' }
            steps {
                checkout scm
                script {
                    cmSemVer = "${relVersion}-${buildType}.${BUILD_NUMBER}"

                    stageEnvironment = [
                        "CM_LIFECYCLE=${buildType}",
                        "CM_SEM_VER=${cmSemVer}"
                    ]
                }
                withEnv(stepEnvironment + stageEnvironment) {
                    withCredentials([
                        usernamePassword(
							credentialsId: env.ARTIFACTORY_ID,
							passwordVariable: 'DOCKER_PASS',
							usernameVariable: 'DOCKER_USER'
						)
                    ]) {
                        timeout(40) {
                            script {
                                if (ciBuild) {
                                    sh 'npm --version'
                                    sh 'npm cache verify'
                                    sh 'npm config set strict-ssl false'
                                    sh 'npm install'
                                }
                                else {
                                    sh 'npm cache verify'
                                    sh 'npm config set strict-ssl false'
                                    sh 'npm install'
                                    sh """docker login -u $DOCKER_USER -p "$DOCKER_PASS" $dockerRegistry"""
                                    sh "docker build -t ${dockerRegistry}/${productName}/${buildName} ." 
                                    sh "docker push ${dockerRegistry}/${productName}/${buildName}"
                                    sh "docker build -t ${dockerRegistry}/${productName}/${buildName}:v2 ." 
                                    sh "docker push ${dockerRegistry}/${productName}/${buildName}"
                                    sh "docker build -t ${dockerRegistry}/${productName}/${buildName}:v3 ." 
                                    sh "docker push ${dockerRegistry}/${productName}/${buildName}"
                                    sh "docker build -t ${dockerRegistry}/${productName}/${buildName}:v4 ." 
                                    sh "docker push ${dockerRegistry}/${productName}/${buildName}"
                                    sh "docker build -t ${dockerRegistry}/${productName}/${buildName}:v5 ." 
                                    sh "docker push ${dockerRegistry}/${productName}/${buildName}"
                                    sh "docker build -t ${dockerRegistry}/${productName}/${buildName}:v6 ." 
                                    sh "docker push ${dockerRegistry}/${productName}/${buildName}"
                                    sh "docker images"
                                }
                            }
                        }
                    }
                }
            }
        }
        
        stage('Publish') {
            when {
                beforeAgent true
                expression { return !ciBuild }
            }
            agent { label 'git && make && terraform'}
            steps {
                checkout scm
                script {
                    fullDockerImage = "${dockerRegistry}/${productName}/${buildName}"
                    terraformDir = tool name: 'Terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
                    kubectlDir = tool name: 'kubectl', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
                    nodePortPublic = "32007"
                    node2Port = "31007"
                    node3Port = "31107"
                    node4Port = "31307"
                    node5Port = "31507"
                    node6Port = "31707"

                    stageEnvironment = [
                        "TERRAFORM=${terraformDir}/terraform",
						"KUBECTL=${kubectlDir}/kubectl",
						"TF_VAR_docker_image=${fullDockerImage}",
						"TF_VAR_node_port=${nodePortPublic}",
                        "TF_VAR_node_2_port=${node2Port}",
                        "TF_VAR_node_3_port=${node3Port}",
                        "TF_VAR_node_4_port=${node4Port}",
                        "TF_VAR_node_5_port=${node5Port}",
                        "TF_VAR_node_6_port=${node6Port}",
						"TF_VAR_k8s_host=gasdvkmaster.hs.mdmgr.net:6443",
						"TF_VAR_service_name=${buildName}"
                    ]
                }
                withCredentials([
					string(credentialsId: env.QTS_KUBERNETES_SVC_JENKINS_CRED_ID, variable: 'TF_VAR_service_token'),
					string(credentialsId: env.QTS_KUBERNETES_CACERT_CRED_ID, variable: 'TF_VAR_cluster_cert')
				]) {
					withEnv(stepEnvironment + stageEnvironment) {			
                        sh "cd ./kube && ${TERRAFORM} init -upgrade -input=false"
                        sh "cd ./kube && ${TERRAFORM} apply -input=false -auto-approve"
                        sh "cd ./kube && ${KUBECTL} apply --kubeconfig rendered/kube.conf -f rendered"
					}
				}
            }
        }
    }
}