# Django template for Docker + Heroku

This is a template for Django applications that can be run with Docker Compose locally and Heroku in production.

It is how I set up Django projects to get up and running as quick as possible. In includes a few neat things:

- Static file compilation with Parcel, so you can use modern JS stuff and SCSS
- Static file serving with Whitenoise
- CI with GitHub actions
- [VSCode remote container config](https://code.visualstudio.com/docs/remote/containers) with linting, Black, refactoring, etc, all set up sensibly
- A custom User model, which [Django recommend doing when starting a project](https://docs.djangoproject.com/en/3.0/topics/auth/customizing/#substituting-a-custom-user-model)
- [Gevent workers and DB connection pooling, so you can serve up lots of requests on a Heroku hobby dyno](https://medium.com/@bfirsh/squeezing-every-drop-of-performance-out-of-a-django-app-on-heroku-4b5b1e5a3d44)
- Sentry for exception logging

## Getting started

To get started (replace `myapp` with the name of your app):

    $ docker run -it --rm -v "$PWD":/usr/src/app -w /usr/src/app django django-admin.py startproject --template https://github.com/bfirsh/django-docker-heroku-template/tarball/master --name .gitignore,.dockerignore,Dockerfile,README.md,app.json,package.json,script/clean myapp
    $ cd myapp
    $ chmod +x ./manage.py script/*

This readme file is now in your app's directory. You can delete this top bit and everything that follows is the start of your app's readme.

# {{ project_name }}

## Development environment

Install Docker, then run:

    $ docker-compose up --build

This will boot up everything that your app needs to run.

(Note: the `--build` argument is not required, but will ensure the Python and JS dependencies are always up-to-date.)

In another console, run these commands to set up the database and set up a user:

    $ docker-compose run web ./manage.py migrate
    $ docker-compose run web ./manage.py createsuperuser

The local development environment is now running at [http://localhost:8000](http://localhost:8000). The admin interface is at [http://localhost:8000/admin/](http://localhost:8000/admin/), accessible with the user/pass created above.

## Tests

To run the test suite:

    $ docker-compose run web ./manage.py test

## Deployment on Heroku

This app is designed to be deployed on Heroku.

These commands, roughly, will get you set up with an app. Replace `{{ project_name }}-production` with a name for the app:

```
$ heroku update beta
$ heroku plugins:install @heroku-cli/plugin-manifest
$ heroku apps:create --manifest --no-remote --stack=container {{ project_name}}-production
$ heroku config:set -a {{ project_name }}-production SECRET_KEY=$(openssl rand -hex 64)
```

In the Heroku web UI, go to the app, then the "Deploy" tab, then connect it to a GitHub repo. Then, click "Deploy branch" at the bottom to trigger a deploy. `./manage.py migrate` will be run on deploy.

On this page, you can also set up automatic deploys if you want. You probably want to check "Wait for CI to pass before deploy".
