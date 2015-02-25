FROM ruby-rvm-base
MAINTAINER hiroshiyui@ecoworkinc.com
ENV DEBIAN_FRONTEND noninteractive

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get install -y monit && apt-get clean
ADD monitrc /etc/monit/
RUN chmod 0700 /etc/monit/monitrc

RUN mkdir /etc/fluent
RUN /bin/bash -l -c "gem install fluentd --no-ri --no-rdoc"
RUN /bin/bash -l -c "fluentd --setup"

EXPOSE 24224
CMD /bin/bash -l -c "monit -d 10 -I -vv -c /etc/monit/monitrc -l /var/log/monit.log"
