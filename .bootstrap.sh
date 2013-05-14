#!/bin/bash
USER_HOME=$(eval echo ~${SUDO_USER})
echo "local dir `pwd`, and home $(USER_HOME)"; su -l -c 'cd ~/epiquery;cd ~/epiquery/storm ; ./setup.sh ; cd ~/epiquery ; make start;stew refresh; stew start;touch .bootstrapped' glgapp;

