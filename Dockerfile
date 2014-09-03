FROM dockerimages/ubuntu-core:14.04
MAINTAINER Frank Lemanschik @ Direkt SPEED Europe <frank@github.dspeed.eu> @frank-dspeed
ENV DOCKER_BUILD docker build -t dockerimages/haproxy-docker git://github.com/dockerimages/haproxy-docker
ENV DOCKER_RUN /bin/bash -c echo $(sudo docker rm -f proxy) && sudo docker run -d -p 80:80 -v /usr/bin/docker:/usr/bin/docker --name=proxy --restart=always dockerimages/haproxy-docker
ENV DOCKER_HOST tcp://172.17.42.1:4243
ENV YOUR_HOST dspeed.eu
RUN apt-get -y update && apt-get -y install haproxy git ca-certificates wget nano
RUN git clone https://github.com/dockerimages/haproxy-docker /app
WORKDIR /app
RUN chmod +x /app/*
RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego
RUN chmod u+x /usr/local/bin/forego
RUN wget https://github.com/jwilder/docker-gen/releases/download/0.3.2/docker-gen-linux-amd64-0.3.2.tar.gz
RUN tar xvzf docker-gen-linux-amd64-0.3.2.tar.gz
EXPOSE 80
CMD ["forego", "start", "-r"]
#WORKDIR /haproxy-docker

