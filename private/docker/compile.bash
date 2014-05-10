#!/bin/bash

meteor bundle bundle.tar.gz

DOCKERFILE="
FROM phusion/passenger-customizable:latest
ENV HOME /root
RUN sudo apt-get update && sudo apt-get dist-upgrade -y
RUN /build/utilities.sh
RUN /build/nodejs.sh
RUN npm install -g coffee-script

# install node.js
RUN apt-get install -y python-software-properties python g++ make

USER app
WORKDIR /home/app
ENV HOME /home/app
ADD bundle.tar.gz bundle.tar.gz
RUN tar zxvf bundle.tar.gz
RUN rm bundle.tar.gz

EXPOSE 80
EXPOSE 3005
EXPOSE 3006

ENTRYPOINT cd bundle; PORT=80 node main.js
"

scp bundle.tar.gz $1:~/deploy/
echo "${DOCKERFILE}" | ssh $1 "cat - > deploy/Dockerfile"
ssh $1 "cd bundle && docker build -t d2moddin ."
rm bundle.tar.gz
