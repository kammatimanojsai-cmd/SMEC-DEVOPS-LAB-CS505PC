# Jenkins LTS with the plugins the lab pipeline needs (setup wizard skipped, admin created by init script)
FROM jenkins/jenkins:lts-jdk21
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
RUN jenkins-plugin-cli --plugins workflow-aggregator git junit timestamper pipeline-stage-view
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy
