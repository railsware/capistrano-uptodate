# capistrano-uptodate

capistrano-uptodate is [capistrano](https://github.com/capistrano/capistrano) extension that automatically check your local repository with remote repository and if repository is not up-to-date:

* display corresponding message.
* ask to confirm recipe execution or abort recipe execution.

If you want to be sure that every developer in your team use recent version of deployment recipes before it starts deploy this extension might be handy.

## Installation

    gem install capistrano-uptodate

Add to `Capfile` or `config/deploy.rb`:

    require 'capistrano/uptodate'

## Configuration

You can tune *uptodate* recipe using next options:

* *:uptodate_scm* (:git) - SCM you use
* *:uptodate_scm_bynary* ('git') - path to SCM binary
* *:uptodate_remote_repository* ('origin') - remote repository
* *:uptodate_branch* ('master') - branch of repository to check
* *:uptodate_time* (60) - time in seconds for checking remote repository
* *:uptodate_behaviour* - (:confirm) 
  * *:confirm* - show outdated message and ask to confirm the further execution
  * *:abort* - show outdated message and abort further execution

## Example

    $ cap production deploy
      triggering load callbacks
    * == Currently executing `uptodate'
    * == Currently executing `uptodate:git'
    Local 'master' branch is not synchronized with 'origin' repository.
    Continue anyway? (y/N)

