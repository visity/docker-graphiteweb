FROM      python:2.7

# Install required packages
RUN       apt-get update && \
          apt-get install -y libcairo2-dev memcached python-cairo sqlite3 && \
          apt-get clean && \
          rm -rf /var/lib/apt/lists/*

# Take the graphite-web version from master branch end of 2015          
RUN       pip install --install-option="--prefix=/opt/graphite" git+git://github.com/graphite-project/graphite-web.git@3c3c6113831df8c37d7a5f2f6d648756dd871196
COPY      requirements.txt /tmp/
RUN       pip install -r /tmp/requirements.txt

# Create users
RUN       addgroup --gid 30100 graphiteweb
RUN       useradd -u 30106 -g graphiteweb -s /bin/false graphiteweb

# Copy configs into place and create needed dirs
COPY      local_settings.py /opt/graphite/webapp/graphite/
RUN       mkdir -p /opt/graphite/storage/log/webapp

# Setup DB for graphite webapp
RUN	      export PYTHONPATH=$PYTHONPATH:/opt/graphite/webapp && \
          cd /opt/graphite/webapp/graphite && \
          /usr/local/bin/django-admin.py syncdb --settings=graphite.settings --noinput

# Setup a default NGINX file in case this docker is fronted with NGINX
RUN       mkdir -p /etc/nginx/conf.d
COPY      nginx-graphite.conf /etc/nginx/conf.d/default.conf

COPY      docker-entrypoint.sh /

# Default port
EXPOSE    80

ENV       PYTHONPATH /opt/graphite/webapp
ENV       TERM xterm
ENV       CARBON_HOST carbon

# Share volumes when serving via NGINX
VOLUME    /opt/graphite/webapp/content
VOLUME    /etc/nginx/conf.d

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD       ["gunicorn", "--bind=0.0.0.0:80", "graphite.wsgi", "--user=graphiteweb", "--settings=graphite.settings"]
