#!/bin/bash

# Nombre del proyecto
PROJECT_NAME="hospital-management-system"
DJANGO_PROJECT_NAME="core"

echo "🛠️ Creando estructura para $PROJECT_NAME..."

mkdir -p $PROJECT_NAME/{backend/{apps,requirements},frontend/public,nginx,docker/{django,vue,nginx}}

cd $PROJECT_NAME

# Crear proyecto Django (solo estructura)
cd backend
python3 -m venv venv
source venv/bin/activate
pip install django
django-admin startproject $DJANGO_PROJECT_NAME .
deactivate

# Crear carpetas de configuración Django
mkdir -p $DJANGO_PROJECT_NAME/settings
mv $DJANGO_PROJECT_NAME/settings.py $DJANGO_PROJECT_NAME/settings/base.py
touch $DJANGO_PROJECT_NAME/settings/{dev.py,prod.py}

# Crear requirements
touch requirements/{base.txt,dev.txt,prod.txt}

# Apps placeholder
mkdir -p apps/{pacientes,citas,usuarios}
for app in pacientes citas usuarios; do
    mkdir -p apps/$app/{models,serializers,views,tests}
    touch apps/$app/{urls.py,permissions.py,services.py,tasks.py,admin.py,apps.py}
done

# Crear manage.py si no se creó en raíz
if [ ! -f "manage.py" ]; then
    touch manage.py
fi

cd ..

# Frontend Vue (estructura base)
cd frontend
npm create vue@latest . -- --default

cd ..

# Docker y nginx placeholders
touch docker-compose.yml
touch .env .env.example

echo "server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://backend:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}" > nginx/dev.conf

echo "✅ Proyecto $PROJECT_NAME creado con éxito."
