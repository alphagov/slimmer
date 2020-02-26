#!/usr/bin/env groovy

library("govuk")

REPOSITORY = 'slimmer'

node {

  try {
    stage('Checkout') {
      checkout scm
    }

    stage('Clean') {
      govuk.cleanupGit()
      govuk.mergeMasterBranch()
    }

    stage('Bundle') {
      echo 'Bundling'
      sh("bundle install --path ${JENKINS_HOME}/bundles/${JOB_NAME}")
    }

    stage('Linter') {
      govuk.lintRuby()
    }

    stage('Tests') {
      govuk.setEnvar('RAILS_ENV', 'test')
      govuk.runTests()
    }

    if(env.BRANCH_NAME == "master") {
      stage('Publish Gem') {
        def version = sh(
          script: /ruby -e "puts eval(File.read('${REPOSITORY}.gemspec'), TOPLEVEL_BINDING).version.to_s"/,
          returnStdout: true
        ).trim()

        def taggedReleaseExists = sh(
          script: "git tag | grep v${version}",
          returnStatus: true
        ) == 0

        if (taggedReleaseExists) {
          echo "Version ${version} has already been tagged on Github"
        } else {
          echo('Pushing tag')
          govuk.pushTag(REPOSITORY, env.BRANCH_NAME, 'v' + version)
        }

        def escapedVersion = version.replaceAll(/\./, /\\\\./)
        def versionAlreadyPublished = sh(
          script: /gem list ^${REPOSITORY}\$ --remote --all --quiet | grep [^0-9\\.]${escapedVersion}[^0-9\\.]/,
          returnStatus: true
        ) == 0

        if (versionAlreadyPublished) {
          echo "Version ${version} has already been published to rubygems.org"
        } else {
          echo('Publishing gem')
          sh("gem build ${REPOSITORY}.gemspec")
          sh("gem push '${REPOSITORY}-${version}.gem'")
        }
      }
    }

  } catch (e) {
    currentBuild.result = 'FAILED'
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
