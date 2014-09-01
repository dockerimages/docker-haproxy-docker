FROM dockerimages/ubuntu-core:14.04
MAINTAINER Frank Lemanschik @ Direkt SPEED Europe <frank@github.dspeed.eu> @frank-dspeed

ENV DOCKER_HOST tcp://172.17.42.1:4243
EXPOSE 80

RUN apt-get -y update && apt-get -y install haproxy

ADD ./init-haproxy /sbin/init
RUN chmod +x /sbin/init
CMD ["/sbin/init"]
