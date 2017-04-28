# Pantry

This is a simple script to backup your HOME's stuff.
If you are a real developer, this script is too stupid for you and for sure you have dozen of better tools to do what this silly program does.  Don't waste your time with this dildo!

## Idea

I'm sick of configuring my computer from scratch evrytime I get a new machine. I always miss some important file from my old computer. I'm too dumb to learn how to use a chef recipes or one of those complicated dotfiles systems that make tons of things except what I really need. So I thought I need something super easy to config and super easy to maintain, and in a couple of hours I've build a pantry!

* Choose the important files or folders from your HOME or Applications Data (.ssh, .gitconfig, .zsh, sublime user settings ecc...)
* Choose a destination folder to backup (i.e a Drobpox folder)
* Set a cronjob to run the script as often as you want (once a day is enough for me. I've also set an action on Marathono)
* Update these files without worries
* When you'll get a new computer, just copy your backuped files in the right folder (untill a good developer will commit an authomatic restore procedure! :))

## Install

* clone this repo wherever you want (bin directory?)
* rename pantry_config.yml.sample to pantry_sample.yml
* edit your config to define your paths
* set permission 667 to your pantry.rb file
* set a crontab (if you can!) to run every x hours

## To do

* Find the best way to setup a crontab
* Restore stuff from pantry to setup a new environment
* Use a git repo as destination backup
