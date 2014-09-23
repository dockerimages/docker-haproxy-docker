#!/usr/bin/env ruby
# Docker Event Listener
# Author: Kelly Becker <kbecker@kellybecker.me>
# She is a nice girl i call her my Cherry Apple because she works at Apple but is more elegant like a Cherry :D
# Website: http://kellybecker.me
# Original Code: https://gist.github.com/KellyLSB/4315a0323ed0fe1d79b6
# License: MIT

# Set up a proper logger
require 'logger'
log_file = ARGV.first || '-'
log = Logger.new(log_file == '-' ? $stdout : log_file)

# Create a PID file for this service
File.open('/var/run/docker_event_listner-up.pid', 'w+') { |f| f.write($$) }

# Capture the terminate signal
trap("INT") do
  log.info "Caught INT Signal... Exiting."
  File.unlink('/var/run/docker_event_listner.pid')
  sleep 1
  exit
end

# Welcome message
log.info "Starting Docker Dynamic DNS - Event Handler"
log.info "Maintainer: Kelly Becker <kbecker@kellybeckr.me>"
log.info "Website: http://kellybecker.me"

# Default Configuration
ENV['DOCKER_PID'] ||= "/var/run/docker.pid"

# Ensure docker is running
time_waited = Time.now.to_i
until File.exist?(ENV['DOCKER_PID'])
  if (Time.now.to_i - time_waited) > 600
    log.fatal "Docker daemon still not started after 10 minutes... Please Contact Your SysAdmin!"
    exit 1
  end

  log.warn "Docker daemon is not running yet..."
  sleep 5
end

log.info "Docker Daemon UP! - Listening for Events..."

# To Docker.io Events
events = IO.popen('docker events')

# Keep Listening for incoming data
while line = events.gets

  # Container Configuration
  ENV['CONTAINER_EVENT']    = line.split.last
  ENV['CONTAINER_CID_LONG'] = line.gsub(/^.*([0-9a-f]{64}).*$/i, '\1')
  ENV['CONTAINER_CID']      = ENV['CONTAINER_CID_LONG'][0...12]
  ENV['CONTAINER_NAME']	    =  %x(docker ps -a | grep #{ENV['CONTAINER_CID']} | awk '{print $NF}')
    
  # Event Fired info
  # debug log.info "Event Fired (#{ENV['CONTAINER_CID']} / #{ENV['CONTAINER_NAME']}): #{ENV['CONTAINER_EVENT']}."
  

  if ENV['CONTAINER_NAME'].include? "proxy"
  #debug     log.info " i think i am: #{ENV['CONTAINER_NAME']}"
  else 
      case ENV['CONTAINER_EVENT']
	 when 'start'
          #Run Add to Bind9
          # add-zone.sh $CONTAINER_CID_LONG
          log.info "Reloading because #{ENV['CONTAINER_EVENT']}: #{ENV['CONTAINER_NAME']}"
         
	 %x(service haproxy reload)
	 when 'stop'
   	  log.info "Reloading because #{ENV['CONTAINER_EVENT']}: #{ENV['CONTAINER_NAME']}"
	  %x(service haproxy reload)
      end
  end
end
exit
