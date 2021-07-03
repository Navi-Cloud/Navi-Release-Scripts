#!/bin/bash

BASE_FILE=$1 # Base File

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

function tell_verbose {
    TO_TELL=$1
    echo -e "${GREEN}${TO_TELL}${NOCOLOR}"
}

function tell_error {
    TO_TELL=$1
    echo -e "${RED}${TO_TELL}${NOCOLOR}"
}

function stop_server {
    TO_STOP_FILE=$1
    PID_NUMBER=$(pgrep -f $TO_STOP_FILE)

    if [ -z $PID_NUMBER ]
    then
        echo "Nope, PID Number is not found!"
    else
        echo "Found it. Killing with signal 15"
        kill -15 $PID_NUMBER
        sleep 5
    fi
}

function run_server {
    TO_UPDATE_PORT=$1
    TO_UPDATE_FILE=$2
    TO_UPDATE_NAME=$3

    # Execute Command to launch
    nohup java -jar $TO_UPDATE_FILE --spring.profiles.active=$TO_UPDATE_NAME --server.port=$TO_UPDATE_PORT &
    tell_verbose "Just executed server launch command.. waiting for 10 seconds."
    sleep 10
}

# Copy
tell_verbose "Copying files to destinations.."
cp -v $BASE_FILE $NEW_FILE
cp -v $BASE_FILE $SET_ONE_SERVER_FILE
cp -v $BASE_FILE $SET_TWO_SERVER_FILE

# Cleanup first
stop_server $SET_ONE_SERVER_FILE
stop_server $SET_TWO_SERVER_FILE

# Run
run_server $SET_ONE_PORT $SET_ONE_SERVER_FILE $SET_ONE_NAME
run_server $SET_TWO_PORT $SET_TWO_SERVER_FILE $SET_TWO_NAME