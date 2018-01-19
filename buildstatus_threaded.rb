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
    when 99 # never
      "\e[1;#{red}m#{msg}\e[0m"
  end
end

build_status_codes = {
  -2 => "exception",
  -1 => "error",
  0  => "pending",
  1  => "claimed",
  2  => "started",
  3  => "cloned",
  4  => "readme",
  5  => "dockerfile",
  6  => "built",
  7  => "bundled",
  8  => "uploaded",
  9  => "pushed",
  10 => "done",
  98 => "Image not found",
  99 => "never",
}


repolisturl = 'https://hub.docker.com/v2/repositories/jameseckersall'

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

if ARGV.empty? then
  get_page(repolisturl)
else
  ARGV.each do |arg|
    @results << { 'name' => arg }
  end
end


@results.sort_by! { |hsh| hsh['name'] }

print "Fetching build status [#{' ' * @results.count}]"
print "\b" * (@results.count + 1)

build_status = []

threads = []
queue_in = Queue.new
@results.each do |k|
  queue_in.push k
end

queue_out = Queue.new

5.times do
  threads << Thread.new do
    loop do
      queue_item = queue_in.pop
      print "\e[32m.\e[0m"
      image_status = { 'name' => queue_item['name'] }

      build_result = `#{@curl_cmd} #{repolisturl}/#{queue_item['name']}/buildhistory`
      buildhistory = JSON.parse(build_result)

      if buildhistory['results'] then
        image_status['last_updated'] = Time.parse(buildhistory['results'][0]['last_updated'])
        image_status['build_status'] = buildhistory['results'][0]['status']
      else
        image_status['last_updated'] = Time.at(0)
        image_status['build_status'] = 99
      end
      queue_out << image_status
      sleep 1
    end
  end
end

# Wait until any currently running threads have finished their current work and returned to queue.pop
while threads.count - queue_in.num_waiting > 0 do
  #pending_threads = threads.count - queue_in.num_waiting
  #puts "Waiting for #{pending_threads} threads to finish"
  sleep 1
end

# Kill off each thread now that they're idle and exit
threads.each(&:exit)
#Process.exit(0)

#@results.each do |image|
#  print "\e[32m.\e[0m"
#  $stdout.flush
#  image_status = { 'name' => image['name'] }
#
#  build_result = `#{@curl_cmd} #{repolisturl}/#{image['name']}/buildhistory`
#  buildhistory = JSON.parse(build_result)
#
#  if buildhistory['results'] then
#    image_status['last_updated'] = Time.parse(buildhistory['results'][0]['last_updated'])
#    image_status['build_status'] = buildhistory['results'][0]['status']
#  else
#    image_status['last_updated'] = Time.at(0)
#    image_status['build_status'] = 99
#  end
#  build_status << image_status
#end
puts "\n\n"

while queue_out.length > 0 do
  build_status << queue_out.pop
end

build_status.sort_by { |hsh| hsh['last_updated'] }.each do |img|
  if img['build_status'] == 10 then
    status_desc = ""
  else
    status_desc = "Status is #{img['build_status']} - #{build_status_codes[img['build_status']]}"
  end
  puts format_build_status img['build_status'], "#{img['last_updated']} #{img['name']} #{status_desc}"
end

