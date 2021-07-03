#!/bin/bash

SET_ONE_SERVER_FILE=/working/SetOne.jar
SET_TWO_SERVER_FILE=/working/SetTwo.jar
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

# Main Starts here
stop_server $SET_ONE_SERVER_FILE
stop_server $SET_TWO_SERVER_FILE
