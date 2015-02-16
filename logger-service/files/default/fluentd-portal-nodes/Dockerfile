FROM fluentd-base
MAINTAINER hiroshiyui@ecoworkinc.com

ADD fluent.conf /etc/fluent/
RUN mkdir -p /var/log/fluent
RUN mkdir -p /srv/www/personal_cloud_portal/shared/log
RUN /bin/bash -l -c "gem install fluent-plugin-rewrite-tag-filter --no-ri --no-rdoc"
