module Skewer
  # responsible for moving source to remote nodes
  class Source
    def initialize(path = nil)
      raise "I can't see the path #{path}" unless File.exists?(path)
      @path = path.sub(/\/$/, '')
    end

    def excludes
      '--exclude ' + ['.git'].join(' ')
    end

    def create_destination(node)
      begin
        node.ssh('mkdir -p infrastructure')
      rescue
        if node.respond_to? :public_ip_address
          location = node.public_ip_address
        else
          location = node.dns_name
        end
        raise "Couldn't SSH to #{location} with #{node.username}"
      end
    end

    def rsync_command(node)
      if node.respond_to? :public_ip_address
        location = node.public_ip_address
      else
        location = node.dns_name
      end
      "rsync #{self.excludes} --delete -arpze ssh #{@path}/. #{node.username}@#{location}:infrastructure/."
    end

    def mock_rsync(command)
      puts "MOCK: #{command}"
    end

    def real_rsync(node, command)
      if node.respond_to? :public_ip_address
        location = node.public_ip_address
      else
        location = node.dns_name
      end
      raise "Failed to rsync to #{location} with #{node.username}" unless system(command)
    end

    def rsync(node)
      puts rsync_command(node)
      if node.respond_to? :public_ip_address
        location = node.public_ip_address
      else
        location = node.dns_name
      end
      print "Copying code to #{location} ..."
      create_destination(node)
      command = self.rsync_command(node)

      if node.class.to_s =~ /StubNode/
        mock_rsync(command)
      else
        real_rsync(node, command)
      end
      puts " Done."
    end
  end
end
