#!/usr/bin/env bash

#
echo "waiting 180 seconds for cloud-init to update /etc/apt/sources.list"
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 1; done'
echo "running apt-get update ..."
cat /etc/apt/sources.list
sudo -E apt-get update

# Install apt requirements
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    awscli

# Get the Docker repo GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker Ubuntu repo
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get -y update

# Add the Gitlab repo
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash

# Install Docker CE and the Gitlab runner
sudo apt-get -y install docker-ce docker-ce-cli containerd.io gitlab-runner

# Add the cron that keeps refreshing the AWS ECR token for Docker login
#sudo echo -e '#!/bin/bash\n$(aws ecr get-login --registry-ids <ecr_registry_id> --no-include-email --region us-east-1)' > /etc/cron.hourly/aws_ecr_login
#sudo chmod +x /etc/cron.hourly/aws_ecr_login
