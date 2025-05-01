#!/bin/bash

# Define project root directory
PROJECT_ROOT="hospital-management-system"

# Create root directory
mkdir -p "$PROJECT_ROOT" && cd "$PROJECT_ROOT"

# Create README and LICENSE files
touch README.md LICENSE .env

# Create backend structure
mkdir -p backend/core
mkdir -p backend/apps/{pacientes,citas,usuarios}
mkdir -p backend/requirements
mkdir -p backend/static
mkdir -p backend/media

# Create frontend structure
mkdir -p frontend/public
mkdir -p frontend/src/{assets,components,views,router,store,services}

# Create nginx and docker config directories
mkdir -p nginx
mkdir -p docker/{django,vue,nginx,postgres}

# Create requirements files
touch backend/requirements/{base.txt,dev.txt,prod.txt}

# Create frontend files
touch frontend/.env
touch frontend/vite.config.js
touch frontend/package.json

# Create nginx config files
touch nginx/dev.conf
touch nginx/prod.conf

# Create docker files
touch docker/django/Dockerfile
touch docker/vue/Dockerfile
touch docker/nginx/Dockerfile
touch docker/postgres/Dockerfile
touch docker/postgres/init.sql

# Create docker-compose file
touch docker-compose.yml

# Initialize Django project
cd backend
django-admin startproject core .

# Create apps structure
cd apps
for app in pacientes citas usuarios; do
    django-admin startapp $app
    
    # Create modular structure for each app
    mkdir -p $app/{models,serializers,views,services,tests}
    touch $app/{models/__init__.py,serializers/__init__.py,views/__init__.py,services/__init__.py}
    touch $app/{admin.py,apps.py,urls.py,permissions.py,tasks.py}
    
    # Create test files
    touch $app/tests/{__init__.py,test_models.py,test_views.py,test_serializers.py}
done

# Create initial Django settings with PostgreSQL config
cat <<EOT > core/settings/base.py
import os
from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Quick-start development settings - unsuitable for production
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', 'django-insecure-your-secret-key-here')

# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'apps.pacientes',
    'apps.citas',
    'apps.usuarios',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'core.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'core.wsgi.application'

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('POSTGRES_DB', 'hospital_db'),
        'USER': os.environ.get('POSTGRES_USER', 'hospital_user'),
        'PASSWORD': os.environ.get('POSTGRES_PASSWORD', 'hospital_password'),
        'HOST': os.environ.get('POSTGRES_HOST', 'localhost'),
        'PORT': os.environ.get('POSTGRES_PORT', '5432'),
    }
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'es-mx'
TIME_ZONE = 'America/Mexico_City'
USE_I18N = True
USE_L10N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# REST Framework settings
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.TokenAuthentication',
    ],
}

# CORS settings
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8080",
    "http://127.0.0.1:8080",
]
EOT

# Create dev and prod settings
cat <<EOT > core/settings/dev.py
from .base import *

DEBUG = True

ALLOWED_HOSTS = ['localhost', '127.0.0.1']

# Additional dev settings...
EOT

cat <<EOT > core/settings/prod.py
from .base import *

DEBUG = False

ALLOWED_HOSTS = ['your-production-domain.com']

# Security settings
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_SSL_REDIRECT = True

# Additional production settings...
EOT

# Create initial requirements
cat <<EOT > requirements/base.txt
Django==4.2
djangorestframework==3.14.0
psycopg2-binary==2.9.6
python-dotenv==1.0.0
django-cors-headers==4.2.0
EOT

cat <<EOT > requirements/dev.txt
-r base.txt
ipython==8.12.0
django-debug-toolbar==4.1.0
django-extensions==3.2.3
EOT

cat <<EOT > requirements/prod.txt
-r base.txt
gunicorn==21.2.0
whitenoise==6.5.0
EOT

# Create initial docker-compose file
cd ../..
cat <<EOT > docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: hms_postgres
    env_file:
      - .env
    volumes:
      - postgres_data:/var/lib/postgresql/data/
      - ./docker/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    networks:
      - hms_network

  django:
    build:
      context: .
      dockerfile: docker/django/Dockerfile
    container_name: hms_django
    command: gunicorn core.wsgi:application --bind 0.0.0.0:8000
    env_file:
      - .env
    volumes:
      - ./backend:/app
      - ./backend/staticfiles:/app/staticfiles
      - ./backend/media:/app/media
    ports:
      - "8000:8000"
    depends_on:
      - postgres
    networks:
      - hms_network

  vue:
    build:
      context: .
      dockerfile: docker/vue/Dockerfile
    container_name: hms_vue
    command: npm run dev
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "8080:8080"
    networks:
      - hms_network

  nginx:
    build:
      context: .
      dockerfile: docker/nginx/Dockerfile
    container_name: hms_nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - django
      - vue
    volumes:
      - ./nginx:/etc/nginx/conf.d
      - ./backend/staticfiles:/var/www/static
      - ./backend/media:/var/www/media
    networks:
      - hms_network

volumes:
  postgres_data:

networks:
  hms_network:
    driver: bridge
EOT

# Create sample Dockerfiles
cat <<EOT > docker/django/Dockerfile
FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements /tmp/requirements
RUN pip install --upgrade pip && \
    pip install -r /tmp/requirements/prod.txt

COPY backend /app

EXPOSE 8000
EOT

cat <<EOT > docker/vue/Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY frontend/package*.json ./
RUN npm install

COPY frontend .

EXPOSE 8080
EOT

cat <<EOT > docker/nginx/Dockerfile
FROM nginx:1.23-alpine

COPY nginx /etc/nginx/conf.d

EXPOSE 80
EXPOSE 443
EOT

# Create sample nginx config
cat <<EOT > nginx/dev.conf
upstream django {
    server django:8000;
}

upstream vue {
    server vue:8080;
}

server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://vue;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /api/ {
        proxy_pass http://django;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /admin/ {
        proxy_pass http://django;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /static/ {
        alias /var/www/static/;
    }

    location /media/ {
        alias /var/www/media/;
    }
}
EOT

# Create sample .env file
cat <<EOT > .env
# Django
DJANGO_SECRET_KEY=your-secret-key-here
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1

# PostgreSQL
POSTGRES_DB=hospital_db
POSTGRES_USER=hospital_user
POSTGRES_PASSWORD=hospital_password
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Vue
VUE_APP_API_URL=http://localhost:8000/api/
EOT

echo "Project structure created successfully!"
echo "Next steps:"
echo "1. Review and customize the generated files"
echo "2. Set up your virtual environment and install requirements"
echo "3. Run docker-compose build to build your containers"
