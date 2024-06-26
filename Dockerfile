# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3-slim AS build-env

EXPOSE 8000

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install pip requirements, create new Django project and configure the settings
COPY requirements.txt .
RUN\
    python -m pip install -r requirements.txt\
    && python -m django startproject project

COPY drf_hf_hub project/drf_hf_hub
RUN\
    echo "INSTALLED_APPS += ['drf_hf_hub', 'drf_redesign', 'rest_framework']" >> project/settings.py\
    && echo "from django.urls import include" >> project/urls.py\
    && echo "urlpatterns += [path('', include('drf_hf_hub.urls')), path('', include('rest_framework.urls'))]" >> project/urls.py

COPY . /app
WORKDIR /app

FROM gcr.io/distroless/python3
COPY --from=build-env /app /app
WORKDIR /app

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "project.wsgi"]
