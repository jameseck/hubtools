#!/usr/bin/env ruby

require 'time'
require 'pp'
require 'json'

@curl_cmd = "curl -sSL -H 'Content-Type: application.json'"

def format_build_status (status, msg)
  red = 31
  green = 32
  yellow = 33
  blue = 34
  pink = 35
  light_blue = 36

  case status
    when nil # no status
      "\e[#{blue}m#{msg}\e[0m"
    when -2 # exception
      "\e[#{red}m#{msg}\e[0m"
    when -1 # error
      "\e[#{red}m#{msg}\e[0m"
    when 0 # pending
      "\e[#{yellow}m#{msg}\e[0m"
    when 1 # claimed
      "\e[#{light_blue}m#{msg}\e[0m"
    when 2 # started
      "\e[#{yellow}m#{msg}\e[0m"
    when 3 # cloned
      "\e[#{light_blue}m#{msg}\e[0m"
    when 4 # readme
      "\e[#{light_blue}m#{msg}\e[0m"
    when 5 # dockerfile
      "\e[#{light_blue}m#{msg}\e[0m"
    when 6 # built
      "\e[#{light_blue}m#{msg}\e[0m"
    when 7 # bundled
      "\e[#{light_blue}m#{msg}\e[0m"
    when 8 # uploaded
      "\e[#{light_blue}m#{msg}\e[0m"
    when 9 # pushed
      "\e[#{light_blue}m#{msg}\e[0m"
    when 10 # done
      "\e[#{green}m#{msg}\e[0m"
  end
end

build_status_codes = {
  "-2" => "exception",
  "-1" => "error",
  0    => "pending",
  1    => "claimed",
  2    => "started",
  3    => "cloned",
  4    => "readme",
  5    => "dockerfile",
  6    => "built",
  7    => "bundled",
  8    => "uploaded",
  9    => "pushed",
  10   => "done"
}


#PP.pp JSON.parse `curl -sSL -H 'Content-Type: application/json' https://hub.docker.com/v2/repositories/1and1internet/ubuntu-16`
#PP.pp JSON.parse `curl -sSL -H 'Content-Type: application/json' https://hub.docker.com/v2/repositories/1and1internet/ubuntu-16/buildhistory/`

repolisturl = 'https://hub.docker.com/v2/repositories/1and1internet'

@results = []

def get_page (url)
  puts "Grabbing #{url}\n"
  result_temp = JSON.parse(`#{@curl_cmd} #{url}`)
  @results += result_temp['results']
  if result_temp.include? 'next' then
    if result_temp['next']
      get_page(result_temp['next'])
    end
  end
  @results
end

get_page(repolisturl)
@results.sort_by! { |hsh| hsh['name'] }

@results.each do |image|
  buildhistory = JSON.parse(`#{@curl_cmd} #{repolisturl}/#{image['name']}/buildhistory`)
  if buildhistory['results'] then
    last_updated = Time.parse(buildhistory['results'][0]['last_updated'])
    status = buildhistory['results'][0]['status']
  else
    last_updated = nil
    status = nil
  end
  #puts "\e[32m#{last_updated} #{image['name']}\e[0m\n"
  puts format_build_status status, "#{last_updated} #{image['name']}"
end

