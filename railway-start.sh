#!/bin/sh
set -eu
PORT="${PORT:-8080}"
# Railway assigns PORT dynamically; make Tomcat listen on that port.
sed -i "s/port=\"8080\"/port=\"${PORT}\"/" /usr/local/tomcat/conf/server.xml
exec catalina.sh run
