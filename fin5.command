#!/bin/sh
ifconfig | grep 192.168

cd /Users/sandro/dev/workspace/fin5

pid="tmp/pids/server.pid"

if [ -e "$pid" ]
then
  echo "Killing PID: $(cat $pid)"
  kill -TERM $(cat $pid)
fi

DATABASE_URL=postgresql://localhost/fin5 rails server -b 0.0.0.0 -p 4000 -e production
