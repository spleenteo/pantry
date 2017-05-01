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

def header(msg)
  puts "\n\n--------------------------------------"
  puts "==> #{msg}"
  puts "--------------------------------------"
end


@pantry_path = Pathname.new($0).realpath().sub("pantry.rb", "")
@config_file = "#{@pantry_path}pantry_config.yml"
@restore     ||= false
@test        ||= false

ARGV.each do|a|
  case a
    when "restore"
      @restore = true
    when "check"
      @check = true
  end
end


# Check if config file exists and load it
# If it does not exist, prompt a warning message and exit
# Also Check if config folders are valid


if File.exists?(@config_file)
  yml     = YAML.load_file(@config_file)
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
else
  die "Missing config file"
end


if @check
  header("Check Up")
  puts "Pantry path: #{@pantry_path}"
  puts "Local folder: #{@backup}"
  puts "Items in stuff: #{stuff.count}"

  puts "Items list:"
  stuff.each do |k, ctx|
    puts "- #{k}"
  end
  puts "Use GIT: #{use_git}"

  exit
end


if @restore
  header("Restore the system")

  stuff.each do |k, ctx|
    from = "#{@backup}/#{ctx}"
    dest_path = Pathname.new(ctx)
    dest = "#{@home}/#{dest_path}"
    a_path = ctx.split("/")

    # if its a root file, just copy it and go on
    if a_path.count == 1
      FileUtils.cp_r from, dest
      puts "Restore #{k} from backup"
      next
    end
    if a_path.count > 1
      # ok, path contains one or more directories

      if Pathname.new(from).directory?
        # let's create the whole tree
        FileUtils.mkpath dest

        # copy the source dir content to the target
        FileUtils.cp_r from, dest
        puts "Restore #{k} from backup"
      else
        # this is a file within a directory tree
        # I must create the correct tree
        FileUtils.mkpath Pathname.new(dest).dirname

        # and copy the single file in the last directory
        FileUtils.cp from, dest
        puts "Restore #{k} from backup"
      end
    end
  end
  header("Restore completed")
end


if not @restore
  # I want to copy a set of files or folders into a different specific (eg dropbox folder)
  # each file goes in a defined path

  header("Backup everything")
  stuff.each do |k, ctx|
    from = "#{@home}/#{ctx}"
    dest_path = Pathname.new(ctx)
    dest = "#{@backup}/#{dest_path}"
    a_path = ctx.split("/")

    # if its a root file, just copy it and go on
    if a_path.count == 1
      FileUtils.cp_r from, dest
      puts "Copying files for #{k}"
      next
    end

    if a_path.count > 1
      # ok, path contains one or more directories

      if Pathname.new(from).directory?
        # let's create the whole tree
        FileUtils.mkpath dest

        # copy the source dir content to the target
        FileUtils.cp_r from, dest
        puts "Copying files for #{k}"
      else
        # this is a file within a directory tree
        # I must create the correct tree
        FileUtils.mkpath Pathname.new(dest).dirname

        # and copy the single file in the last directory
        FileUtils.cp from, dest
        puts "Copying files for #{k}"
      end
    end
  end


  # if you have choosen to use GIT as backup system

  if use_git == true
    header("Backup on GIT")
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



