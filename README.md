# Maven Cache Docker Image

A docker image leveraging NGinx to cache content from public Maven repositories into your local network.
(An Amazon VPC is a local network for the purpose of this tool)

It is meant to be used as a replacement for Jenkins workspace caching. So instead of relying on Jenkins to
cache content of your `.m2` local repository between builds, you configure Maven to fetch artifacts from
this fast mirror.

It can be seen as counter intuitive, but today's network are actually extremely fast, usually more than storage
attached to cloud VM (which is actually generally backed by the network, like AWS EBS for example).

So, it's better to download from a fast mirror than relying on a network attached storage device which IO performances can
be sometimes random. And for build reproducibility, it's much better to just start fresh for each build.

## Usage

The image is available from Docker Hub. Just run:

    docker run --rm -v cache:/cache --net=host ydubreuil/maven-cache-image

This command line

* store cache content on a Docker volume to make it persistent across container restarts
* use `--net=host` to bind NGinx to the host network stack and to avoid being slowed down by NAT and a veth device (you want a crazy fast mirror, don't you?)

Cache policy can be configured with these environment variables:

* `CACHE_SIZE_METADATA`: size of the metadata cache (POM, SHA1 and MD5), default to 10G.
* `CACHE_SIZE_ARTIFACT`: size of the artifact cache (all the rest), default to 30G
* `CACHE_EXPIRE`: cached data expiration time, defaults to 30 days

### Kernel tuning on the host

If you want things to go really fast, you need to tune the TCP stack of the Docker host. These kernel parameters need to be changed:

```
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_early_retrans = 1
net.ipv4.tcp_fastopen = 3
net.core.default_qdisc = fq_codel
```

You can add them all to `/etc/sysctl.d/99-tune-tcp.conf` and load them with `sysctl --system`. They will persist across reboots.

## Maven configuration

In order to use the cache instead of the upstream Maven repositories, you need to configure the mirror section
in `settings.xml` like this:

```
<settings>
  <mirrors>
    <mirror>
      <id>maven-cache-central</id>
      <url>http://HOSTNAME/mirrors/central</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
    <mirror>
      <id>maven-cache-jenkins</id>
      <url>http://HOSTNAME/mirrors/jenkins</url>
      <mirrorOf>repo.jenkins-ci.org</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

Detailed documentation for mirror settings can be found on the official Maven documentation: https://maven.apache.org/guides/mini/guide-mirror-settings.html

## NGinx tips links

NGinx configuration was written with the following knowledge in mind:

* https://www.nginx.com/blog/nginx-high-performance-caching/
* https://www.nginx.com/blog/cache-placement-strategies-nginx-plus/
* https://www.nginx.com/blog/thread-pools-boost-performance-9x/
