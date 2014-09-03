haproxy-internal
================

This HAPROXY Image is Running a update-config Script written by Frank Lemanschik from Direkt SPEED Europe 
it uses docker to do docker ps on a setted DOCKER_HOST that is coded via ENV var into this image to allow easy
replacement the dockerhost is hardcoded to 172.17.42.1:2434 whats the standart docker bridge and standart docker port

All Running Containers Where the Name Starts with WEB_ wich got a ENV HAPROXY_DOMAIN domain.tld get aded to backend domain.tld with port 80 if your application runns on other port set ENV HAPROXY_PORT in that Container to the port of your web application.

# TODO:
- Listen for Docker Container Created Events and then re run the Script 
- Modify it complet to Act on Container Create Base.

    
# USE:

We Bind Port 80 of the Host to 80 of the Container and set it to Always Restart as also bind
docker executeable in from host because we need to run same version of docker in host and container
You can Remove this Mount Step and add your docker binary in the right version with a other method
    
    docker run -d -p 80:80 -v /usr/bin/docker:/usr/bin/docker --restart="always" dockerimages/haproxy-internal)
    
# BUILD:

    docker build -t dockerimages/haproxy-docker git://github.com/dockerimages/haproxy-docker)
