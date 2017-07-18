# Aggressive-Squid-Cache

Docker container for aggressively caching http responses, good for speeding up `apt` calls when building containers. For the author, this generally cuts off a couple of minutes of container build time.

Works without requiring changes to the users Dockerfile, and does not affect the final container image.

Uses Squid in `offline_mode` as the caching server, and Dockers support for custom network DNS resolution.

## Dependencies

* Docker >= 1.10

## Usage 

Make a custom docker network:

    docker create build-net
    
Run aggressive-squid-cache in the custom network:

    docker run -d --rm --network build-net --name "squid" mrmagooey/aggressive-squid-cache

Point all of your builds towards this container, so when building your container instead of doing:

    // old method

    docker build . 
    
You do:
    
    // new method, with cache
    
    docker build --network build-net --build-arg http_proxy=http://squid:3128 .

This will build your container in the Docker network that contains the squid proxy, and via the `http_proxy` environment variable will route all of your http requests through the squid proxy. The first run will be the same speed, if not a bit slower, but all subsequent requests should be accelerated via the proxy.

Keep in mind that all this is doing is serving up old http requests. If you are expecting that a repository or dependency will be updated, then this cache will only keep serving up the first thing that it received. The easiest way refresh the cache is to kill and restart the squid proxy:

    // kill the old container
    docker kill squid
    // start a new one
    docker run -d --rm --network build-net --name "squid" mrmagooey/aggressive-squid-cache

## Benchmarks

The table shows the build time for each of the docker files in located in the `benchmarks/` directory. Obviously these results will change depending on your network setup.

| Benchmark   | Without cache (s) | With cache (s) | Speedup      |
|-------------|-------------------|----------------|--------------|
| apt-update  |               250 |              7 | ~35x faster  |
| apt-install |              1000 |            120 | ~8.3x faster |
| yum-update  |                15 |             10 | ~1.5x faster |
| yum-install |                36 |             30 | ~1.2x faster |
| npm-install |                54 |             49 | ~1.1x faster |

## Security

Due to the yum/apt security model, transferring packages over http (and so through this proxy) should be fine. This is ok for apt/yum mainly because of the package signing infrastructure that is already in place for that package manager. For other things (e.g. language package managers npm, pip etc), although you can force them to run over http and through this cache, they are losing security due to the lack of signing in their respective package ecosystems. However, see an npm install example in `benchmarks/`.

Currently https connections are not affected by the squid cache, and will go through untouched.
