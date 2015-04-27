FROM debian:stable
MAINTAINER hiroshiyui@ecoworkinc.com
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
apt-get dist-upgrade -y && \
apt-get install -y curl libcurl4-gnutls-dev procps less g++ make libboost-dev libssl-dev && \
apt-get clean

WORKDIR /tmp

RUN curl -O http://www.stunprotocol.org/stunserver-1.2.7.tgz && \
tar xvfz stunserver-1.2.7.tgz && \
mv stunserver /opt/ && \
rm /tmp/stunserver-1.2.7.tgz

WORKDIR /opt/stunserver

RUN make
