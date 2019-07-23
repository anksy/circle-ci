# https://nodejs.org/en/docs/guides/nodejs-docker-webapp/
# Build:
# docker build -t hoteljot/jot:tag .
# =================
# Steps to push
# --------------
# 1. docker login flexsincontainer.azurecr.io
# 2. docker tag flexsincontainer.azurecr.io/stewardcompanymanagementplatform:latest
# 2. docker run -it flexsincontainer.azurecr.io/stewardcompanymanagementplatform:latest
# 4. docker exec -it <mycontainer> bash
# 5. docker push flexsincontainer.azurecr.io/stewardcompanymanagementplatform:latest
# 6. https://stewardcompany.scm.azurewebsites.net/api/logs/docker -> to check application logs
# ====================
# Run:
# docker run -it hoteljot/jot
# docker run -it -p 7000:8017 vern/vern:tag
#
# Compose:
# docker-compose up -d
# docker-compose -f docker-compose-production.yml up -d

FROM ubuntu:latest
LABEL maintainer="flexsin.com"

# 80 = HTTP, 443 = HTTPS, 8035 = NODEJS server
EXPOSE 80 443 8035

# Set development environment as default
ENV NODE_ENV production

# Install Utilities
RUN apt-get update -q  \
 && apt-get install -yqq \
 curl \
 git \
 ssh \
 gcc \
 make \
 build-essential \
 libkrb5-dev \
 sudo \
 libfontconfig \
 apt-utils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install libfontconfig for writting html into pdf
# RUN sudo apt-get install -y libfontconfig

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN sudo apt-get install -yq nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install NODEJS Prerequisites
RUN npm install --quiet -g pm2 && npm cache clean

RUN mkdir -p /opt/steward
WORKDIR /opt/steward

# Copies the local package.json file to the container
# and utilities docker container cache to not needing to rebuild
# and install node_modules/ everytime we build the docker, but only
# when the local package.json file changes.
# Install npm packages
COPY package.json /opt/steward/package.json
RUN npm install --quiet --only=production && npm cache clean

# Install bower packages
#COPY bower.json /opt/steward/bower.json

COPY . /opt/steward 

# Run NODEJS server
#CMD npm install --only=production && npm start

# To RUN USING PM2 DOCKER
CMD ["pm2-docker", "bin/exec.json"]
