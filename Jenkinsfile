#!/usr/bin/env groovy

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  try {
    stage("Checkout") {
      checkout scm
    }

    stage("Cleanup") {
      govuk.cleanupGit()
      govuk.mergeMasterBranch()
    }

    stage("Build") {
      sh "${WORKSPACE}/jenkins.sh"
    }

    if (env.BRANCH_NAME == 'master') {
      stage("Publish gem") {
        sh "bundle exec rake publish_gem --trace"
      }
    }
  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: 'Mailer',
      notifyEveryUnstableBuild: true,
      recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
      sendToIndividuals: true])
    throw e
  }

}
