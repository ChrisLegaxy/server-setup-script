#! /bin/sh

deps_base() {
    echo "Installing base deps"

    sudo apt-get update \
    && sudo apt-get upgrade -y
}

docker_debs() {
    echo "Installing Docker & Docker Compose"
    curl -fsSL https://get.docker.com -o get-docker.sh \
    && sudo sh get-docker.sh

    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && sudo chmod +x /usr/local/bin/docker-compose
}

nginx_debs() {
    sudo apt-get install nginx -y \
    && sudo ufw allow 'Nginx HTTP' \
    && sudo ufw allow 'OpenSSH' \
    && sudo ufw --force enable \
    && sudo systemctl enable nginx \
    && cp ./nginx/base /etc/nginx/site-availables/ \
    && cp ./nginx/upstream.conf /etc/nginx/conf.d/
}

gitlab_runner_debs() {
    sudo curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64" \
    && sudo chmod +x /usr/local/bin/gitlab-runner \
    && sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash \
    && sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner \
    && sudo gitlab-runner start \
    && sudo rm /home/gitlab-runner/.bash_logout
}

permissions() {
    sudo usermod -aG docker root
    sudo usermod -aG docker gitlab-runner
}

exec_all() {
    deps_base
    wait
    docker_debs
    gitlab_runner_debs
    nginx_debs
    wait
    permissions
}

exec_all

echo "Script run successfully! Your server has been setup!"
