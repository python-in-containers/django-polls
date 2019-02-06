#! /bin/bash

cd /django-mysite

# Wait for SQL Database container to be ready

cat <<-EOF | python manage.py shell
import socket
import time
from django.conf import settings

# Read Database config from project settings.py file, as described at https://docs.djangoproject.com/en/2.1/topics/settings/#using-settings-in-python-code

db_host = settings.DATABASES['default']['HOST']
db_port = int(settings.DATABASES['default']['PORT'])

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
while True:
    try:
        s.connect((db_host, db_port))
        s.close()
        break
    except socket.error as ex:
        print('DB Engine not ready')
        time.sleep(0.1)
EOF

python manage.py migrate

echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell

python manage.py collectstatic

# --static-map option based on Mode 3 from https://uwsgi-docs.readthedocs.io/en/latest/StaticFiles.html

uwsgi --chdir=/django-mysite \
    --module mysite.wsgi:application \
    --env DJANGO_SETTINGS_MODULE=mysite.settings \
    --master --pidfile=/tmp/project-master.pid \
    --socket 0.0.0.0:8001 \
    --static-map /static=/django-mysite/static \
    --processes=5 \
    --harakiri=20 \
    --max-requests=5000 \
    --vacuum
