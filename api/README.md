# Venue

### Setup

* Copy `config/database.yml.example` to `config/database.yml` and configure your database connection.
* Run `$ rake db:create`
* Run `$ rake db:migrate`
* Run `$ rake db:seed`

### Config

Before launching the Rails server, please follow these steps:

* Copy the file `config/application.yml.example` to `config/application.yml` and fill in the credentials and settings specified in the file.


### Deployment

Once the app has been deployed to Heroku, please follow these steps:

* Run `$ heroku run rake db:migrate`
* Run `$ bundle exec rake figaro:heroku` <sup>1</sup>


----
[1] This will copy all settings/credentials specified in the `config/application.yml` file and set them as ENV variables in Heroku.
