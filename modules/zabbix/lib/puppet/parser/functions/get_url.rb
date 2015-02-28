require 'net/http'
module Puppet::Parser::Functions
  newfunction(:get_url,:type => :rvalue) do |args|
    url = args[0]
    response = Net::HTTP.get_response(URI(url))
    return(response.body)
  end
end