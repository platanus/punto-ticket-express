# P Ticket Ex [![Circle CI](https://circleci.com/gh/platanus/p-ticket-ex.svg?style=svg&circle-token=)](https://circleci.com/gh/platanus/p-ticket-ex)

This is a Rails application, initially generated using [Potassium](https://github.com/platanus/potassium) by Platanus.

## Local installation

Assuming you've just cloned the repo, run this script to setup the project in your
machine:

    $ ./script/setup

It assumes you have a machine equipped with Ruby, Mysql, etc. If not, set up
your machine with [boxen].

The script will do the following among other things:

- Install the dependecies
- Prepare your database
- Adds heroku remotes

After the app setup is done you can run it with [Heroku Local]

    $ heroku local

[Heroku Local]: https://devcenter.heroku.com/articles/heroku-local
[boxen]: http://github.com/platanus/our-boxen


## Internal dependencies

### Queue System

For managing tasks in the background, this project uses [DelayedJob](https://github.com/collectiveidea/delayed_job)
