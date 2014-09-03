FROM dockerimages/ubuntu-core:14.04
MAINTAINER Frank Lemanschik @ Direkt SPEED Europe <frank@github.dspeed.eu> @frank-dspeed
ENV DOCKER_BUILD docker build -t dockerimages/haproxy-docker git://github.com/dockerimages/haproxy-docker
ENV DOCKER_RUN /bin/bash -c "sudo docker rm -f proxy \ && sudo docker run -d -p 80:80 -v /usr/bin/docker:/usr/bin/docker --name=proxy --restart=always dockerimages/haproxy-docker"
ENV DOCKER_HOST tcp://172.17.42.1:4243
ENV YOUR_HOST dspeed.eu
RUN apt-get -y update && apt-get -y install haproxy
ADD ./init-haproxy /sbin/init
RUN chmod +x /sbin/init
CMD ["/sbin/init"]
