#!/usr/bin/env ruby

require 'fileutils'
require 'git'
require 'pathname'
require 'yaml'


def check_path?(directory)
  File.exists?(directory)
end

def die(msg)
  puts "HORROR!!!! #{msg}"
  exit
end


# Check if config file exists and load it
# If it does not exist, prompt a warning message and exit
# Also Check if config folders are valid


if File.exists?("pantry_config.yml")
  yml     = YAML.load_file("pantry_config.yml")
  config  = yml["pantry"]["config"]
  stuff   = yml["pantry"]["stuff"]
  use_git = yml["pantry"]["config"]["use_git"] || false

  if config["home"].nil? || config["home"] == "" || config["home"] == "[path-to-your-home]"
    die "Need to know your home path"
  elsif check_path?(config["home"]) == false
    die "Home is not a valid directory."
  else
    @home = config["home"]
  end

  if config["local_folder"].nil? || config["local_folder"] == "" || config["local_folder"] == "[path-to-your-dropbox-or-other-cloud-system]"
    die "Need to know your backup path"
  elsif check_path?(config["local_folder"]) == false
    die "Backup is not a valid folder."
  else
    @backup = config["local_folder"]
  end

  if stuff.nil? || stuff.empty?
    die "There's nothing to backup"
  end

  @restore ||= false
  ARGV.each do|a|
    if a == "restore"
      @restore = true
    end
  end

  if @restore
    puts "Restore the system"
  end

else
  die "Missing config file"
end




if not @restore
  # I want to copy a set of files or folders into a different specific (eg dropbox folder)
  # each file goes in a defined path

  stuff.each do |k, ctx|
    from = "#{@home}/#{ctx}"
    dest_path = Pathname.new(ctx)
    dest = "#{@backup}/#{dest_path}"
    a_path = ctx.split("/")

    # if its a root file, just copy it and go on
    if a_path.count == 1
      FileUtils.cp_r from, dest
      puts "Performing backups for #{k}"
      next
    end

    if a_path.count > 1
      # ok, path contains one or more directories

      if Pathname.new(from).directory?
        # let's create the whole tree
        FileUtils.mkpath dest

        # copy the source dir content to the target
        FileUtils.cp_r from, dest
        puts "Performing backups for #{k}"
      else
        # this is a file within a directory tree
        # I must create the correct tree
        FileUtils.mkpath Pathname.new(dest).dirname

        # and copy the single file in the last directory
        FileUtils.cp from, dest
        puts "Performing backups for #{k}"
      end
    end
  end


  # if you have choosen to use GIT as backup system

  if use_git == true
    g = Git.open(@backup)
    if g and g.index.readable? and g.index.writable?
      message = "Stuff backuped on #{Time.now}"
      g.add(:all=>true)

      if g.status.changed.count > 0
        g.commit(message)
        g.push
        puts "GIT STATUS: #{message}"
      else
        puts "GIT STATUS: nothing new to commit"
      end
    end
  end
end



