class Bootstrapper
  def initialize(node,options)
    @node = node
    @options = options
  end

  def add_ssh_hostkey
    system "ssh -o 'StrictHostKeyChecking no' -o 'PasswordAuthentication no' no_such_user@#{@node.dns_name} >/dev/null 2>&1"
  end

  def execute(file_name)
    file = File.join(File.dirname(__FILE__), '..', 'assets', file_name)
    raise "#{file} does not exist" unless File.exists? file
    @node.scp file, '/var/tmp/.'
    @node.ssh "sudo bash /var/tmp/#{file_name}"

  end

  def install_gems
    @node.scp 'assets/Gemfile', 'infrastructure'
    command = ". /etc/profile.d/rubygems.sh && cd infrastructure && bundle install"
    @node.ssh command
  end

  def sync_source()
    require 'source'
    require 'puppet_node'
    config = SkewerConfig.instance
    source_dir = config.get(:puppet_repo)
    puts "Using Puppet Code from #{source_dir}"
    if @options[:role]
      puppet_node = PuppetNode.new
      puppet_node.nodes[:default] = @options[:role].to_sym
      puppet_node.render
    end
    # TODO: if there's no role, it should look it up from an external source
    Source.new(source_dir).rsync(@node)
  end

  def go
    add_ssh_hostkey
    execute('rubygems.sh')
    sync_source
    install_gems
  end


end
