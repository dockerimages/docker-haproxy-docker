#!/bin/bash
#running
while true; do
# Create ENV HAPROXY_DOMAIN
#DHOST="-H tcp://172.17.42.1:4243"
WKD="./"
docker ps | grep 80/tcp | awk '{print $1}' > ${WKD}running_web_container_cid
docker ps | grep 80/tcp | awk '{print $NF}' > ${WKD}running_web_container_name
docker ps | grep 80/tcp | docker $DHOST inspect --format '{{ .NetworkSettings.IPAddress }}' $(awk '{print $NF}') > ${WKD}running_web_container_ip
paste -d ' ' ${WKD}running_web_container_cid ${WKD}running_web_container_ip ${WKD}running_web_container_name > ${WKD}running_web_containers_cid_ip_name
# Removing Intermediated Files
rm -rf ${WKD}running_web_container_cid  ${WKD}running_web_container_ip ${WKD}running_web_container_name ${WKD}acl_list use_list ${WKD}backend_*


### Static
echo -e "acl by_host_cb hdr(host) -i cb.dspeed.eu"  >> ${WKD}acl_list
echo -e "use_backend cb if by_host_cb" >> ${WKD}use_list
echo -e "\n\
backend cb \n\
  balance leastconn \n\
  option httpclose \n\
  option forwardfor \n\
  cookie JSESSIONID prefix" > ${WKD}backend_cb
echo -e "    server cbmain 172.17.2.181:7081 cookie A check" >> ${WKD}backend_cb_nodelist
echo "Added CB Costum Backend with 172.17.2.181:7081"


# DYNAMIC binding using dspeed-docker-tools dcip and count
# create a file for every active node
while IFS=" " read cid ip name; do
# Adding node to backend 
# creating the backend and use role also acl
HAPROXY_DOMAIN="$(docker $DHOST inspect $cid | grep HAPROXY_DOMAIN | sed 's/\"//' | sed 's/HAPROXY_DOMAIN//' | sed 's/=//' | sed 's/\"//' | sed 's/,//')"
BACKEND=$(while IFS= read -r line; do printf "%s" "${line%_*}"; done <<EOF 
$name 
EOF
)

echo -e "
CID : $cid\n\
IP :\t $ip\n\
FULLNAME :\t $name\n\
BACKENDNAME: \t $BACKEND\n\
HAPROXY_DOMAIN:\t $HAPROXY_DOMAIN\n\
RZ:\t ${name}.s1.rz-h3.dspeed.eu -i ${cid}.s1.rz-h3.dspeed.eu -i ${BACKEND}.dspeed.eu\n\n"


#echo -e "backend_name $BACKEND"

# use ENV HAYPROY_DOMAIN
echo -e "acl by_host_$BACKEND hdr(host) -i ${name}.s1.rz-h3.dspeed.eu -i ${cid}.s1.rz-h3.dspeed.eu -i ${BACKEND}.dspeed.eu" ${HAPROXY_DOMAIN} >> ${WKD}acl_list
# echo -e "acl by_host_ hdr(host) -i ${cid}.s1.rz-h3.dspeed.eu" >> ${WKD}acl_list
# echo -e "acl by_host_$BACKEND hdr(host) -i ${backend}.dspeed.eu" >> ${WKD}acl_list
echo -e "use_backend $BACKEND if by_host_$BACKEND" >> ${WKD}use_list
echo -e "    server $cid $ip:80 cookie A check" >> "${WKD}backend_${BACKEND}_nodelist"
#echo -e "    server $cid $ip:80 cookie A check" >> "${WKD}backend_${BACKEND}_nodelist"

echo -e "\n\
backend $BACKEND \n\
  balance leastconn \n\
  option httpclose \n\
  option forwardfor \n\
  cookie JSESSIONID prefix" > backend_$BACKEND
done < ${WKD}running_web_containers_cid_ip_name



### Checks
# if [ -z "$BACKEND_ID" ]; then
#	echo "No Backend ID"
#	exit 1
#fi

##### check if we get a node
#if [ -z "$BACKEND_NODES" ]; then
#        echo "No Backend NODES"
#        exit 1
#fi


#### check if backend node runs the right image
#sudo docker ps | grep wp-plugins | awk '{print $1}' | \
#while read CMD; do
	# Create file for container  Insert ip via dcip into the file
#        sudo echo $(dcip "$CMD") | echo "server $CMD $(awk '{print $1}'):80 cookie A check"  > active-nodes/$CMD
#done
#COUNT=0
#COUNT=1 sudo docker ps | grep wp-plugins | dcip $(awk '{print $1}') | echo "server node1 $(awk '{print $1}'):80 cookie A check" > active-nocdes/


###################################
# METHOD Merge all HAPROXY-CFG & ACL & USE & BACKEND
##################################
rm -rf ${WKD}prepared.haproxy.cfg
cat << EOF > ${WKD}prepared.haproxy.cfg
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
#        user haproxy
#        group haproxy

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        contimeout 5000
        clitimeout 50000
        srvtimeout 50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http



frontend http-in
        bind *:80
 #       default_backend server
bind 0.0.0.0:443 transparent

#    default_backend server

# Define hosts
#        acl host_bacon hdr(host) -i h1.servers.dspeed.eu
#        acl host_milkshakes hdr(host) -i github.dspeed.eu
#        acl host_affmon hdr(host) -i affmon.dspeed.eu - affilatemanager.dspeed.eu

        ## figure out which one to use
#        use_backend bacon_cluster if host_bacon
#        use_backend milshake_cluster if host_milkshakes
#        use_backend affmon_cluster if host_affmon

#backend mmonit
#        balance leastconn
#        option httpclose
#        option forwardfor
#        cookie JSESSIONID prefix
#        server node1 127.0.0.1:64000 cookie A check

EOF
echo -e "\n # Acl Roles" >> ${WKD}prepared.haproxy.cfg
cat acl_list >> ${WKD}prepared.haproxy.cfg
echo -e "\n # Use Roles" >> ${WKD}prepared.haproxy.cfg
cat use_list >> ${WKD}prepared.haproxy.cfg
echo -e "\n # The Backends with nodes" >> ${WKD}prepared.haproxy.cfg
cat backend_* >> ${WKD}prepared.haproxy.cfg
echo "Done: prepared.haproxy.cfg"
rm -rf ${WKD}running_web_container_cid  ${WKD}running_web_container_ip ${WKD}running_web_container_name ${WKD}acl_list use_list ${WKD}backend_* ${WKD}running_web_containers_cid_ip_name
echo "Done: clean up rm -rf ${WKD}running_web_container_cid  ${WKD}running_web_container_ip ${WKD}running_web_container_name ${WKD}acl_list use_list ${WKD}backend_* ${WKD}running_web_containers_cid_ip_name"
sudo mv ${WKD}prepared.haproxy.cfg /etc/haproxy/haproxy.cfg
echo "Done: ----------COPY OVER------------------ "
sudo service haproxy restart
#cat ./prepared.haproxy.cfg
