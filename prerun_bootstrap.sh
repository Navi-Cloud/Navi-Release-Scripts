#!/bin/bash
/working/bootstrap.sh /working/baseServer.jar # Initial Bootup
service nginx restart
java -jar /working/updaterServer.jar --server.port=8085