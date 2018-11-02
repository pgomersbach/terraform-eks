from jenkins/jenkins:lts

# Distributed Builds plugins
RUN /usr/local/bin/install-plugins.sh ssh-slaves

# install Notifications and Publishing plugins
RUN /usr/local/bin/install-plugins.sh email-ext
RUN /usr/local/bin/install-plugins.sh mailer
RUN /usr/local/bin/install-plugins.sh slack

# Artifacts
RUN /usr/local/bin/install-plugins.sh htmlpublisher copyartifact artifactory

# UI
RUN /usr/local/bin/install-plugins.sh greenballs
RUN /usr/local/bin/install-plugins.sh simple-theme-plugin

# Scm
RUN /usr/local/bin/install-plugins.sh git-client git github cvs subversion bitbucket

# Scaling
RUN /usr/local/bin/install-plugins.sh kubernetes

# Maven
RUN /usr/local/bin/install-plugins.sh maven-plugin ant maven-info

# Matrix
RUN /usr/local/bin/install-plugins.sh matrix-auth matrix-project

# Confluence
RUN /usr/local/bin/install-plugins.sh confluence-publisher 

# Hashicorp
RUN /usr/local/bin/install-plugins.sh hashicorp-vault-plugin

# Workflow
RUN /usr/local/bin/install-plugins.sh workflow-aggregator workflow-multibranch docker-workflow 

# install Maven
USER root
RUN apt-get update && apt-get install -y maven
USER jenkins

