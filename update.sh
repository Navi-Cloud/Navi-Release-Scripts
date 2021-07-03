#!/bin/bash

# ----------------------------------
# Colors from https://gist.github.com/jonsuh/3c89c004888dfc7352be
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

# Deployed file is located on /tmp/newServer.jar
# First Replica's file should be on /tmp/SetOne.jar
# Second Replica's file should be on /tmp/SetTwo.jar

# We need to determine which replica to change.

CURRENT_PROFILE=$(curl -s http://localhost/profile)

# Global New File
NEW_FILE=/tmp/newServer.jar

# Metadata for Set one
SET_ONE_NAME="Navi-Set1"
SET_ONE_PORT=8080
SET_ONE_SERVER_FILE=/tmp/SetOne.jar

# Metadata for Set Two
SET_TWO_NAME="Navi-Set2"
SET_TWO_PORT=8081
SET_TWO_SERVER_FILE=/tmp/SetTwo.jar

function tell_verbose {
    TO_TELL=$1
    echo -e "${GREEN}${TO_TELL}${NOCOLOR}"
}

function tell_error {
    TO_TELL=$1
    echo -e "${RED}${TO_TELL}${NOCOLOR}"
}

# Switch_set(toSwitchTargetPort: Int)
function switch_set {
    TARGET_SET_PORT=$1 # Argument from caller
    echo "set \$service_url http://127.0.0.1:${TARGET_SET_PORT};" | tee /etc/nginx/conf.d/service-url.inc
    service nginx reload
}

function stop_server {
    TO_STOP_FILE=$1
    PID_NUMBER=$(pgrep -f $TO_STOP_FILE)

    if [ -z $PID_NUMBER ]
    then
        tell_error "Nope, PID Number is not found!"
    else
        tell_verbose "Found it. Killing with signal 15"

        kill -15 $PID_NUMBER
        sleep 5
    fi
}

# update_set(toUpdatePort: int, toUpdateFile: string)
function update_set {
    TO_UPDATE_PORT=$1
    TO_UPDATE_FILE=$2
    TO_UPDATE_NAME=$3

    # Need to stop first tho
    stop_server $TO_UPDATE_FILE

    # Copy to fresh-version
    if [ -f "$TO_UPDATE_FILE" ]; then
        tell_error "File ${TO_UPDATE_FILE} already exists! Removing.."
        rm -f $TO_UPDATE_FILE
    fi
    cp -v $NEW_FILE $TO_UPDATE_FILE

    # Execute Command to launch
    nohup java -jar $TO_UPDATE_FILE --spring.profiles.active=$TO_UPDATE_NAME --server.port=$TO_UPDATE_PORT &

    tell_verbose "Just executed server launch command.. waiting for 10 seconds."

    sleep 10
}

if [ $CURRENT_PROFILE == "Navi-Set1" ]
then
    # Set 1 is running, So switch to set 2
    tell_verbose "Switching to Second Replica.."
    switch_set $SET_TWO_PORT

    # Update Set 1
    tell_verbose "Updating First Replica.."
    update_set $SET_ONE_PORT $SET_ONE_SERVER_FILE $SET_ONE_NAME
    # Test Set 1

    # Re-Switch to Set 1
    tell_verbose "Updating First Replica completed. Now, Let server to use First Replica.." 
    switch_set $SET_ONE_PORT

    # Post update set 2
    tell_verbose "Server is now set to First replica[functional], post-updating Second replica.."
    update_set $SET_TWO_PORT $SET_TWO_SERVER_FILE $SET_TWO_NAME
elif [ $CURRENT_PROFILE == "Navi-Set2" ]
then
    # Set 2 is running, so switch to set 1
    tell_verbose "Switching to First Replica.."
    switch_set $SET_ONE_PORT

    # Update Set 2
    tell_verbose "Updating Second Replica.."
    update_set $SET_TWO_PORT $SET_TWO_SERVER_FILE $SET_TWO_NAME

    # Re-Switch to Set 2
    tell_verbose "Updating Second Replica completed. Now, Let server to use Second Replica.."
    switch_set $SET_TWO_PORT

    # Post update set 2
    tell_verbose "Server is now set to second replica[functional], post-updating first replica.."
    update_set $SET_ONE_PORT $SET_ONE_SERVER_FILE $SET_ONE_NAME
else
    tell_error "Unsupported Profile: $CURRENT_PROFILE"
fi
