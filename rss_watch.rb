#!/usr/bin/env ruby

require 'rss/1.0'
require 'rss/2.0'
require 'yaml'

require 'rubygems'
require 'hipchat'

config = YAML.load_file('/usr/local/etc/rss_watch.yaml')

content = open(config['rss_feed']).read
rss = RSS::Parser.parse(content, false)

latest_link = ''

latest_link = File.open(config['state_file_name']).read if File.exists?(config['state_file_name'])

if latest_link != rss.items.first.link
  File.open(config['state_file_name'], 'w') do |f|
    f << rss.items.first.link
  end

  # notify people that a new status blog entry has been posted
  msg = "A new status blog entry has been posted <a href='#{rss.items.first.link}'>#{rss.items.first.link}</a>"
  client = HipChat::Client.new(config['hipchat_key'])
  client[config['hipchat_room']].send(config['hipchat_user'],msg,true)
end
