#! /bin/bash

cd /django-mysite

# --static-map option based on Mode 3 from https://uwsgi-docs.readthedocs.io/en/latest/StaticFiles.html

python manage.py collectstatic

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
