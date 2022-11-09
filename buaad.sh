#!/bin/bash
cd "$(dirname "$0")" || exit

usage() {
  echo "usage: $0 [-[tp]]"
  exit 1
}

# as in login-v2.sh
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"

if [ -z "$JOURNAL_STREAM" ] && [ "$1" != -t ]; then
  log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") $*"
  }
else
  log() {
    echo "$*"
  }
fi

down=0
login() {
  log "$*"
  if [ $down = 1 ]; then
    log "login failed"
    exit 1
  fi
  down=1
  timeout -v 30 bash ./login-v2.sh login || \
  timeout -v 30 bash ./login-v2.sh login
  # login-v2.sh isn't putting a trailing newline
  echo
}

if [ "$1" = -p ]; then
  log 'ping daemon started'
  while true; do
    if ping -c 1 -w 2 mirrors4.tuna.tsinghua.edu.cn >/dev/null; then
      down=0
    else
      login Disconnected
    fi
    sleep 5
  done
elif [ -n "$1" ] && [ "$1" != -t ]; then
  usage
else
  never_up=1
  while true; do
    online=$(
curl -sSL "https://gw.buaa.edu.cn/cgi-bin/rad_user_info" \
-c cookie.jar \
-A "$UA" \
2>&1
    )
    r=$?
    if [ $r -ne 0 ]; then
      echo "$online"
      log "curl failed: $r" >&2
    elif grep -q "not_online_error" <<< "$online"; then
      login "Gateway not online: $online"
    else
      if [ $never_up = 1 ]; then
        log "online: $(cut -d, -f1 <<< "$online")"
        never_up=0
      fi
      down=0
    fi
    if [ "$1" = -t ]; then
      exit
    fi
    sleep 5
  done
fi
