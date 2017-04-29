# Pantry

This is a simple script to backup your HOME's stuff.
If you are a _real developer_®, this script is too stupid for you and for sure you know dozens of awesome tools that do what this silly program does.  Don't waste your time with this dildo!

## Idea

I'm sick of configuring my computer from scratch evrytime I get a new machine. I always miss some important file from my old computer. I'm too dumb to learn how to use a chef recipes or one of those complicated dotfiles systems that make tons of things except what I really need. So I thought I need something super easy to config and super easy to maintain, and in a couple of hours I've build a pantry!

* Choose the important files or folders from your HOME or Applications Data (.ssh, .gitconfig, .zsh, sublime user settings ecc...)
* Choose a destination folder to backup (i.e a Drobpox folder)
* You can use a git repo to backup your files
* Set a cronjob to run the script as often as you want (once a day is enough for me. I've also set an action on Marathono)
* Update these files without worries
* When you'll get a new computer, just copy your backuped files in the right folder (untill a good developer will commit an authomatic restore procedure! :))

## Install

* Clone this repo wherever you want (maybe your user bin directory?)
* ```bundle install```
* Rename ```pantry_config.yml.sample``` to ```pantry_sample.yml```
* Edit the config to define your paths
* Set ```chmod``` to execute your ```pantry.rbv``` file [600 should be ok]
* Set a crontab (if you know how!) to run the script every x hours

## The easy way: use Dropbox or any other cloud system

If you wish to store your backup in a cloud system, just create a folder in your dropbox/drive and copy the absolute path in ```local_folder``` in ```pantry_config.yml```.

Every time the script runs, it copy all your stuff in this folder and you'll have a auomatic upload.

## The ninja dev way: use a repo GIT

If you know how to use GIT (and as you are reading this on github, you might know it), you can automatically backup your stuff.

How to do it:

* Create your private repo (github, bitbucket, gitlab or wherever you want)
* Clone it wherever you want in your computer
* Set ``` local_folder: [to-your-git-folder]``` in your ```pantry_config.yml```file
* Set ``` use_git: true``` in your ```pantry_config.yml```file
* Run the script and enjoy. Pantry checks the diff in the folder, adds new or updated files, creates the commit and push the stuff.

## The paranoid way

Use GIT, clone your private repo in a dropbox folder and set in it in the local_folder config variable. You'll have a double backup.


## To do (if you are a real-dev® and want to help)

* Find the best way to setup a crontab
* Restore stuff from pantry to setup a new environment
* Refactoring of the code to make it more solid and elegant
* Write a better ```README.md``` in english