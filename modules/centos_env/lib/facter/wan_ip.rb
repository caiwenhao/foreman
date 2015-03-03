#wan_ip.rb
require 'net/http'
require 'ipaddr'
Facter.add(:wan_ip) do
  url = URI.parse('http://183.61.135.114:30062/plain')
  req = Net::HTTP::Get.new(url.path)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  setcode do
    if !(IPAddr.new(res.body) rescue nil).nil? == true
      res.body
    end
  end
end