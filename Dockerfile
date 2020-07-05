FROM python:3.8.2
ENV PYTHONUNBUFFERED 1
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  # runs apt-get update
  && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get install -yq \
  # for VSCode autocompletion
  exuberant-ctags \
  # for script/test
  netcat \
  nodejs \
  postgresql-client \
  yarn
RUN mkdir /code
WORKDIR /code
# Install Python dependencies first so they are cached and updating code doesn't cause them to be installed again
COPY requirements.txt /code/
RUN pip install -r requirements.txt
COPY package.json yarn.lock /code/
RUN yarn install
COPY . /code/
# Run Parcel to bake compiled static assets into image
RUN yarn build
RUN SECRET_KEY=unset python manage.py collectstatic --no-input
# Number of gunicorn worker processes. This is the main lever to adjust memory usage.
ENV WEB_CONCURRENCY 3
# Number of gevent connections per worker process. This has some but smaller effect on memory usage, but mainly a lever to adjust CPU usage, network connections, etc.
ENV WORKER_CONNECTIONS 50
ENV PORT 8000
CMD gunicorn {{ project_name }}.wsgi -k gevent --worker-connections $WORKER_CONNECTIONS --bind 0.0.0.0:$PORT --config gunicorn_config.py --max-requests 10000 --max-requests-jitter 1000 --access-logfile -
