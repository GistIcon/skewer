require 'skewer/config'
require 'skewer/strategy/bundler'
require 'skewer'

module Skewer
  # puts all of puppet's dependencies on
  class Bootstrapper
    include Skewer
    MAX_CACHE = 3600
    attr_writer :mock

    def initialize(node,installer,options)
      @node = node
      @options = options
      @mock = false
      @installer = installer
    end

    def host_key_exists(host)
      File.read(ENV['HOME'] + '/.ssh/known_hosts').grep(/#{host}/)
    end

    def add_ssh_hostkey
      location = get_location(@node)
      unless self.host_key_exists(location)
        system "ssh -o 'StrictHostKeyChecking no' -o 'PasswordAuthentication no' no_such_user@#{location} >/dev/null 2>&1"
      else
        logger.debug("SSH Host Key exists; not making it again")
      end

    end

    def add_key_to_agent(executor = Kernel, homedir = ENV['HOME'])
      key_name = config.get(:key_name)
      key_path = File.join(homedir, '.ssh', "#{key_name}.pem")
      logger.debug "****Looking for #{key_path}"
      if File.exists?(key_path)
        executor.system("ssh-add #{key_path}")
      end
    end

    def sync_source()
      require 'skewer/source'
      require 'skewer/puppet_node'
      source_dir = config.get(:puppet_repo)
      logger.debug "Using Puppet Code from #{source_dir}"
      role = @options[:role]
      if role
        PuppetNode.new({:default => role.to_sym}).render
      end
      # TODO: if there's no role, it should look it up from an external source
      if @mock
        logger.debug "Mock: would normally rsync now"
        else
        Source.new(source_dir).rsync(@node)
      end

    end

    def lock_file
      File.join('/tmp', 'skewer-' + get_location(@node))
    end

    def lock_file_expired?(lock_file)
      now = Time.now
      lock_file_time = File.stat(lock_file).mtime
      age = now - lock_file_time
      age > MAX_CACHE
    end

    def destroy_lock_file()
      FileUtils.rm_f(self.lock_file)
    end

    def should_i_run?
      lock_file = lock_file()
      if File.exists?(lock_file)
        if lock_file_expired?(lock_file)
          destroy_lock_file
          return true
        else
          return false
        end
      else
        FileUtils.touch(lock_file)
        true
      end
    end

    def prepare_node
      add_ssh_hostkey
      install_rubygems()
      add_key_to_agent
    end

    def go
      i_should_run = should_i_run?
      @installer.install if i_should_run
      sync_source
      @installer.preflight if i_should_run
    end
  end
end
