ARG PYTHON_VERSION=3.12-slim-bullseye
FROM python:${PYTHON_VERSION}

# create a virtual environment
RUN python -m venv /opt/venv

# Set the virtual environment as the current location
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip
RUN pip install --upgrade pip

# Set python related environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install os dependencies for the project
RUN apt-get update && apt-get install -y \
    gcc \
    libjpeg-dev \
    libcairo2 \
    musl-dev \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    && apt-get clean rm -rf /var/lib/apt/lists/*

# Create the working directory
RUN mkdir -p /code

# Set the working directory
WORKDIR /code

# Copy the requirements file
COPY requirements.txt /tmp/requirements.txt

# Copy the project code to the working directory
COPY ./src /code

# Install the project dependencies
RUN pip install -r /tmp/requirements.txt

# set the project default name
ARG PROJ_NAME="saas"

RUN printf "#!/bin/bash\n" > ./paracord_runner.sh && \
  printf "RUN_PORT=\${PORT:-8000}\n" >> ./paracord_runner.sh && \
  printf "echo \"Running on port \$RUN_PORT\"\n" >> ./paracord_runner.sh && \
  printf "python manage.py migrate --no-input\n" >> ./paracord_runner.sh && \
  printf "gunicorn ${PROJ_NAME}.wsgi:application --bind \"0.0.0.0:\${RUN_PORT}\"\n" >> ./paracord_runner.sh

RUN chmod +x ./paracord_runner.sh

RUN apt-get remove --purge -y \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

CMD ["./paracord_runner.sh"]
