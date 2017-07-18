#!/bin/bash

BENCHMARK_NETWORK=bench-net
CONTAINER_NAME=squid
CONTAINER_PORT=3128

start_squid () {
    docker run -d --rm --network $BENCHMARK_NETWORK --name $CONTAINER_NAME mrmagooey/aggressive-squid-cache
}

kill_squid () {
    docker kill $CONTAINER_NAME
}

docker network list | grep $BENCHMARK_NETWORK >/dev/null
build_net_created=$?

if [ $build_net_created -eq 0 ]
then
    echo "Network \"$BENCHMARK_NETWORK\" exists"
else
    echo "Creating \"$BENCHMARK_NETWORK\" network"
    docker network create $BENCHMARK_NETWORK
fi

docker ps --filter network=$BENCHMARK_NETWORK --format {{.Names}} | grep "^$CONTAINER_NAME$" >/dev/null;
squid_running=$?
if [ $squid_running -eq 0 ]; then
   echo "Squid is currently running, will kill and restart"
   kill_squid
   sleep 5
   start_squid
else
    start_squid
fi

