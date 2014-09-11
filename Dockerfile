FROM dockerimages/ubuntu-core:14.04
MAINTAINER Frank Lemanschik @ Direkt SPEED Europe <frank@github.dspeed.eu> @frank-dspeed
ENV DOCKER_BUILD docker build -t dockerimages/haproxy-docker git://github.com/dockerimages/haproxy-docker
ENV DOCKER_RUN /bin/bash -c echo $(sudo docker rm -f proxy) && sudo docker run -d -p 80:80 -v /var/run/docker.sock:/var/run/docker.sock --name=proxy dockerimages/haproxy-docker
ENV YOUR_HOST docker.local
RUN apt-get -y update && apt-get -y install haproxy git ca-certificates docker.io
RUN git clone https://github.com/dockerimages/haproxy-docker /haproxy-docker
RUN chmod +x /haproxy-docker/*
WORKDIR /haproxy-docker
CMD ["/haproxy-docker/init"]
