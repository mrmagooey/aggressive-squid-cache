FROM ubuntu:latest

RUN apt update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y squid \
     && mv /etc/squid/squid.conf /etc/squid/squid.conf.dist \
     && rm -rf /var/lib/apt/lists/*

# add custom squid.conf
COPY squid.conf /etc/squid/squid.conf
# add runscript
COPY run.sh /root/run.sh

CMD ["/root/run.sh"]
