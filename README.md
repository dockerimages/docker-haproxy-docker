haproxy_internal
================

Special Dockerimage that Runs HaProxy inside a container that querys a dockerhost for all containers running with exposed port 80 and assignes hosts


dockerhost is hardcoded to 172.17.42.1.2434

    
#USE

    HAPROXY_INTERNAL=$(docker run -d -P dockerimages/haproxy_internal)
    
#BUILD 

    BUILD_HAPROXY_INTERNAL=$(docker build -t dockerimages/haproxy_internal git://github.com/dockerimages/haproxy_internal)
