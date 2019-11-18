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
  puts "#{msg}"
  puts "---------------------------------------"
  puts " "
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

puts `brew list > ~/bin/brew.txt`
puts `brew cask list > ~/bin/cask.txt`
header("Brew and Cask: list of the installed software exported")


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

  if config["local_dev_folder"].nil? || config["local_dev_folder"] == "" || config["local_dev_folder"] == "[path-to-your-development-folders]"
    @dev = nil
  elsif check_path?("#{@home}/#{config["local_dev_folder"]}") == false
    die "The dev sites is not a valid folder."
  else
    @dev = "#{@home}/#{config["local_dev_folder"]}"
    if config["dev_files"].nil? || config["dev_files"] == ""
      puts "You haven't defined any dev files to backup"
      @dev = nil
    else
      @dev_folder = Pathname.new(@dev)
      @dev_files = config["dev_files"].split(":")
    end
  end


else
  die "Missing config file"
end


if @check
  header("Check Up")
  puts "Pantry path: #{@pantry_path}"
  puts "Local folder: #{@backup}"
  puts "Use GIT: #{use_git}"
  puts "Items in stuff: #{stuff.count}"

  puts "Items list:"
  stuff.each do |k, ctx|
    puts "- #{k}"
  end

  if @dev.nil?
    puts "You don't want to backup development special files."
  else
    header("DEV FILES")
    puts "Development special files backup is active."
    puts "File di sviluppo da backuppare: #{@dev_files.count}"
    puts @dev_files

    if @dev_folder.directory?
      header("DEV PROJECTS")
      puts "Directory development found: #{@dev_folder}"

      @dev_folder.children.select { |prj|
        next if !prj.directory?

        @project_dev_files = []
        @dev_files.each do |f|
          if File.exists?("#{prj}/#{f}")
            @project_dev_files.push(f)
          end
        end

        if @project_dev_files.count > 0
          puts "Project: #{prj.basename}"
          @project_dev_files.each do |name|
            puts "     > #{name} has been found"
          end
        end
      }
    end
  end

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


if !@restore
  # I want to copy a set of files or folders into a different specific (eg dropbox folder)
  # each file goes in a defined path

  header("Backup Files")
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
  if @dev_folder.directory?
    header("Backup Dev files")
    puts "Directory development found: #{@dev_folder}"

    @dev_folder.children.select { |prj|
      next if !prj.directory?

      @project_dev_files = []
      @dev_files.each do |f|
        if File.exists?("#{prj}/#{f}")
          @project_dev_files.push(f)
        end
      end

      if @project_dev_files.count > 0
        from = prj
        dest = "#{@backup}/#{config['local_dev_folder']}/#{prj.basename}"
        FileUtils.mkpath dest
        puts "Create directory: #{prj.basename}"

        @project_dev_files.each do |name|
          file_path = "#{prj}/#{name}"
          FileUtils.mkpath dest
          puts "     > Copying #{name}"
        end
      end
    }
  end

  # if you have choosen to use GIT as backup system

  if use_git == true
    header("Backup on GIT")
    g = Git.open(@backup)
    if g and g.index.readable? and g.index.writable?
      message = "New backup - #{Time.now}"
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



