# Pantry

This is a simple script to backup your HOME's stuff.
If you are a *real developer*®, this script is too stupid for you and for sure you know dozens of awesome tools that do what this silly program does.  Don't waste your time with this dildo!

## Idea

I'm sick of configuring my computer from scratch evrytime I get a new machine. I always miss some important file from my old computer. I'm too dumb to learn how to use a chef recipes or one of those complicated dotfiles systems that make tons of things except what I really need. So I thought I need something super easy to config and super easy to maintain, and in a couple of hours I've build a pantry!

* Choose the important files or folders from your HOME or Applications Data (.ssh, .gitconfig, .zsh, sublime user settings ecc...)
* Choose a destination folder to backup (i.e a Drobpox folder)
* You can use a git repo to backup your files
* Set a cronjob to run the script as often as you want (once a day is enough for me. I've also set an action on Marathono)
* Update these files without worries
* When you'll get a new computer, just copy your backuped files in the right folder or use the ```restore```parameter to do the magic.

## Install

* Clone this repo wherever you want (maybe your user bin directory?)
* ```bundle install```
* Rename ```pantry_config.yml.sample``` to ```pantry_config.yml```
* Edit the configuration file to define your paths
* Set ```chmod``` to execute your ```pantry.rb``` file [600 should be ok?]
* Set a crontab (if you know how!) to run the script every x hours

## Run the CheckUP

Running ```./pantry.rb check``` will show some info grabbed from the config file. It's just a simple way to check if everything is ok.

# Usage 

## The easy way: use Dropbox or any other cloud system

Just create a folder in your dropbox/drive or other cloud storage system and copy the absolute path in ```local_folder``` in ```pantry_config.yml```.

Every time the script runs, it copies all your stuff in this folder and you'll get your stuff backuped on the cloud.

## The ninja dev way: use a repo GIT

If you know how to use GIT (and if you are using github and want to use Pantry, you might know it), you can automatically backup your stuff on a private repo.

How to do it:

* Create your private repo (github, bitbucket, gitlab or wherever you want)
* Clone it wherever you want in your computer
* Write the path to your local git folder in ``` local_folder: [to-your-git-folder]``` in the ```pantry/pantry_config.yml```file
* Always in the config file, set ``` use_git: true```
* Run the script and enjoy. Pantry checks the diff in the folder, adds new or updated files, creates the commit and push the stuff.

## The paranoid way

Use GIT, clone your private repo in a dropbox folder and set in it in the local_folder config variable. You'll have a double backup.


## Restore from backup

Once you have your software installed (ie. zsh, oh-my-zsh, sublime ecc) on your new mac/pc, you just have to clone your private repo and run ```./pantry.rb restore``` to copy all files in their original position, according to the path written in the config file, stuff section.

Restoring might be a delicate operation, since it overwrites files in your HOME. Do it carefully. If you don't know what you are doing, avoid the automatic restoring and copy the files manually from the backup folder.

## To do (if you are a real-dev® and want to help)

* Find the best way to setup a crontab
* Create a REPL to copy each file interactively
* Refactoring of the code to make it more solid and elegant
* Write a better ```README.md``` in english