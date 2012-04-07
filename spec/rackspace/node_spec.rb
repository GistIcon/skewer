require 'rspec'
require 'rackspace/node'

describe Skewer::Rackspace::Node do
  it "should build out a basic rackspace node" do
    lambda {
      Fog.mock!
      Skewer::Rackspace::Node.new
    }.should raise_exception Fog::Errors::MockNotImplemented
  end

  it "should be able to find the node by IP" do
    service = stub('rackspace_service')
    servers = stub('servers')
    node = stub('node')
    service.should_receive(:servers).and_return(servers)
    servers.should_receive(:select).and_return(node)
    node.should_receive(:size).and_return(1)
    node.should_receive(:[]).and_return(true)
    Skewer::Rackspace::Node.find_by_ip('192.168.0.1', service)
  end

  it "should have a delete method" do

    node = stub('node')
    node.should_receive(:delete).and_return(true)
    Skewer::Rackspace::Node.new(nil, nil, nil,node).node.delete.should == true

  end

  it "should find a uk service" do
    Fog.unmock!
    service = Skewer::Rackspace::Node.find_service('lon')
    service.class.should == Fog::Compute::Rackspace::Real
    puts service.inspect
    service.instance_variable_get(:@rackspace_auth_url).should == 'lon.auth.api.rackspacecloud.com'
  end

  it "should find a the other service" do
    Fog.unmock!
    begin
      Skewer::Rackspace::Node.find_service('usa')
    rescue Exception => e
      puts e.message
      e.message.should match /auth.api.rackspacecloud.com/
    end
  end
end
