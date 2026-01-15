#!/usr/bin/env bash

# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

alias reload="supervisorctl restart all"
alias stop="supervisorctl stop all"
alias start="supervisorctl start all"
alias status="supervisorctl status"
alias art="php artisan"