module Puppet::Parser::Functions
  newfunction(:get_ps1,:type => :rvalue) do |args|
    hostname = args[0]
    ip = args[1]
    port = args[2]
    name = hostname.split('-')
    return([name[0],name[1],name[2],ip,port,"A"].join('_'))
  end
end