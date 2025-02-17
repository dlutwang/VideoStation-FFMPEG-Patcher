#!/bin/bash

#########################
# VARS
#########################

pid=$$
child=""
stderrfile="/tmp/ffmpeg-$pid.stderr"
logfile="/tmp/ffmpeg.log"
errcode=0

#########################
# UTILS
#########################

function log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" >> $logfile
}
function newline() {
  echo "" >> $logfile
}
function info() {
  log "INFO" "$1"
}

function handle_error() {
  log "ERROR" "An error occurred, here is the $stderrfile content: "
  newline
  cat "$stderrfile" >> $logfile
  newline
  errcode=1
  endprocess
}

function endprocess() {
  info "========================================[end ffmpeg $pid]"
  newline
  rm -f "$stderrfile"

  if [[ "$child" != "" ]]; then
    kill -9 "$child"
  fi

  exit $errcode
}

#########################
# ENTRYPOINT
#########################

trap endprocess SIGTERM
trap handle_error ERR

newline
info "========================================[start ffmpeg $pid]"
info "DEFAULT_ARGS: $*"

/var/packages/@ffmpeg_version@/target/bin/ffmpeg "$@" <&0 2> $stderrfile &

child=$!
wait $child

endprocess
