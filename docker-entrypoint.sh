#!/usr/bin/env bash

set -e

function log {
    echo `date` $ME - $@
}

RANCHER_METADATA=rancher-metadata.rancher.internal

function checkrancher {
    log "checking rancher network..."
    
    a="`ip a s dev eth0 &> /dev/null; echo $?`"
    while  [ $a -eq 1 ];
    do
        a="`ip a s dev eth0 &> /dev/null; echo $?`"
        sleep 1
    done

    b="`ping -c 1 ${RANCHER_METADATA} &> /dev/null; echo $?`"
    while [ $b -eq 1 ];
    do
        b="`ping -c 1 ${RANCHER_METADATA} &> /dev/null; echo $?`"
        sleep 1
    done
}

function saveconfig {
    log "Saving config into ${SERVER_WORK_DIR} directory..."
    
    if [ ! -e "${SERVER_WORK_DIR}/config" ]; then
        mkdir ${SERVER_WORK_DIR}/config
    fi

    if [ ! -e "${GOCD_HOME}/config" ]; then
        ln -s ${SERVER_WORK_DIR}/config ${GOCD_HOME}/config
    else
        if [ ! -L "${GOCD_HOME}/config" ]; then
            rm -rf ${GOCD_HOME}/config
            ln -s ${SERVER_WORK_DIR}/config ${GOCD_HOME}/config
        fi
    fi
}

function savesshkey {
    log "saving SSH key"

    if [ ! -e "${USER_HOME}/.ssh" ]; then
        mkdir ${USER_HOME}/.ssh
    fi

    echo "$SSH_KEY" > ${USER_HOME}/.ssh/id_rsa
}

checkrancher
saveconfig
savesshkey

log "[ Starting gocd server... ]"
exec /opt/go-server/server.sh

exec "$@"