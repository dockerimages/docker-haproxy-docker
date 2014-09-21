FROM dockerimages/ubuntu-core:14.04
MAINTAINER Frank Lemanschik @ Direkt SPEED Europe <frank@github.dspeed.eu> @frank-dspeed
ENV DOCKER_BUILD docker build -t dockerimages/haproxy-docker git://github.com/dockerimages/docker-haproxy-docker
ENV DOCKER_RUN sudo docker run -d -p 80:80 -v /var/run/docker.sock:/var/run/docker.sock --name=lb-host dockerimages/haproxy-docker
ENV YOUR_HOST docker.local
RUN apt-get -y update && apt-get -y install haproxy git ca-certificates nano ruby
RUN echo 'ENABLED=1 \n\
EXTRAOPTS="-de -m 16"' > /etc/default/haproxy
RUN git clone https://github.com/dockerimages/docker-haproxy-docker /haproxy-docker
RUN chmod +x /haproxy-docker/* 
VOLUME /etc/haproxy
WORKDIR /haproxy-docker
CMD ["/haproxy-docker/init"]
