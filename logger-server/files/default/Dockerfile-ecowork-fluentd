FROM debian:stable
MAINTAINER hiroshiyui@ecoworkinc.com
ENV DEBIAN_FRONTEND noninteractive

RUN mkdir /etc/fluent
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y curl procps && apt-get clean

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN /bin/bash -l -c "rvm requirements && rvm install 2.1 && rvm cleanup all"
RUN /bin/bash -l -c "gem install fluentd --no-ri --no-rdoc"
RUN /bin/bash -l -c "fluentd --setup"

EXPOSE 24224
CMD /bin/bash -l -c "fluentd -vv"
