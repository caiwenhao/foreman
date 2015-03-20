module Puppet::Parser::Functions
  newfunction(:get_tags,:type => :rvalue) do |args|
    tags = args[0]
    return(lookupvar(tags))
  end
end