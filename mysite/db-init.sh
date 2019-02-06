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

from django.core.management import call_command

call_command('migrate')

from django.contrib.auth.models import User

if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin')
EOF
