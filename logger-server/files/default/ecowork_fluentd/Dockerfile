FROM debian:stable
MAINTAINER hiroshiyui@ecoworkinc.com
ENV DEBIAN_FRONTEND noninteractive

RUN mkdir /etc/fluent
RUN apt-get update && apt-get install -y build-essential curl procps && apt-get clean

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "source /etc/profile.d/rvm.sh"
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.1 && rvm cleanup all"

RUN /bin/bash -l -c "gem install fluentd --no-ri --no-rdoc"
RUN /bin/bash -l -c "fluentd --setup"

EXPOSE 24224
CMD /bin/bash -l -c "fluentd -vv"
