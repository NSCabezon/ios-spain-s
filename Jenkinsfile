def is_develop_branch = BRANCH_NAME.contains("develop")
def is_master_branch = BRANCH_NAME.contains("master")
def cron_string = is_develop_branch ? "H 23 * * *" : is_master_branch ? "H 0 * * *" : ""

pipeline {
    options {
        copyArtifactPermission('spain-appium');
    }
    environment {
        MATCH_PASSWORD=credentials('jenkins-match-password')
        COMMIT_MESSAGE = sh(script: 'git log --oneline --format=%B -n 1 $GIT_COMMIT', returnStdout: true).trim()
    }
    parameters {
        booleanParam(name: "DEPLOY_TO_INTERN", defaultValue: is_develop_branch, description: "Do you want to deploy INTERN?")
        booleanParam(name: "DEPLOY_TO_DEV", defaultValue: false, description: "Do you want to deploy DEV?")
        booleanParam(name: "DEPLOY_TO_PRE", defaultValue: is_master_branch, description: "Do you want to deploy PRE?")
        booleanParam(name: "RUN_TESTS", defaultValue: false, description: "Do you want to run the build with tests?")
        booleanParam(name: "INCREMENT_VERSION", defaultValue: true, description: "Do you want to increment the build version?")
        choice(name: 'NODE_LABEL', choices: ['spain', 'ios', 'hub'], description: '')
    }
    agent { label params.NODE_LABEL ?: 'spain' }    
    triggers { cron(cron_string) }

    stages {
        stage("Install dependencies") {
            steps {
                sh "bundle install"
                sh "bundle exec pod install"
                sh "bundle exec fastlane ios check_certs"
            }
        }
        stage("Linting") {
            steps {
                sh "bundle exec fastlane ios swift_lint"
            }
        }
        stage("Test all example apps") {
            when {
                expression { return params.RUN_TESTS }
                expression { return !env.COMMIT_MESSAGE.startsWith("Updating Version") }
            }
            steps {
                sh "bundle exec fastlane ios test"
            }
        }
        stage("Distribute Intern") {
            when {
                expression { return params.DEPLOY_TO_INTERN }
                expression { return !env.COMMIT_MESSAGE.startsWith("Updating Version") }
            }
            steps {
                sh "bundle exec fastlane ios release deploy_env:intern notify_testers:true branch:${env.BRANCH_NAME}"
            }
        }
        stage('Compile Intern to Appium') {
            when {
                expression { return  is_develop_branch || is_master_branch}
                expression { return !env.COMMIT_MESSAGE.contains("Updating Version") }
            }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    echo "Distributing iOS app"
                    sh "bundle exec fastlane ios build_appium"
                    sh "mv Build/Products/Intern-Debug-iphonesimulator/*.app INTERN.app"
                    sh 'zip -vr INTERN.zip INTERN.app/ -x "*.DS_Store"'
                    archiveArtifacts artifacts: 'INTERN.zip'
                }
            }
        }
        stage("Distribute Dev") {
            when {
                expression { return params.DEPLOY_TO_DEV }
                expression { return !env.COMMIT_MESSAGE.startsWith("Updating Version") }
            }
            steps {
                sh "bundle exec fastlane ios release deploy_env:dev notify_testers:false branch:${env.BRANCH_NAME}"
            }
        }
        stage("Distribute Pre") {
            when {
                expression { return params.DEPLOY_TO_PRE }
                expression { return !env.COMMIT_MESSAGE.startsWith("Updating Version") }
            }
            steps {
                sh "bundle exec fastlane ios release deploy_env:pre notify_testers:true branch:${env.BRANCH_NAME}"
            }
        }
        stage("Increment version") {
            when {
                expression { return params.INCREMENT_VERSION }
                expression { return !env.COMMIT_MESSAGE.startsWith("Updating Version") }
            }
            steps {
                sh "bundle exec fastlane ios increment_version branch:${env.BRANCH_NAME}"
            }
        }
    }
    post {
        always{
            script{
				if(env.COMMIT_MESSAGE.contains("Updating Version"))
					currentBuild.result = 'NOT_BUILT'
			}
        }
        failure {
            mail to: "jose.carlos.estela@experis.es", subject: "Build: ${env.JOB_NAME} - Failed", body: "The build ${env.JOB_NAME} has failed"
            mail to: "tania.castellano@experis.es", subject: "Build: ${env.JOB_NAME} - Failed", body: "The build ${env.JOB_NAME} has failed"
        }
    }
}
