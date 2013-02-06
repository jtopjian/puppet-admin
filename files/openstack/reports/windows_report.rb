#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'
require 'json'
require 'time'
require 'date'

# Get the mysql login info
user, password, host = ''
if File.exists?('/root/.my.cnf')
  File.open('/root/.my.cnf').each do |line|
    case line
    when /^user=(.*)$/
      user = $1
    when /^password=(.*)$/
      password = $1
    when /^host=(.*)$/
      host = $1
    end
  end
else
  puts ".my.cnf file is needed."
  exit
end

# Parse the command-line arguments
if ARGV.length == 0
  # No arguments, so use the first and last day of last month
  cur_date = Date.new(Time.now.year, Time.now.month, 1)
  last_month = cur_date - 1
  start_date = "#{last_month.year}-#{last_month.month}-1"
  end_date = "#{last_month.year}-#{last_month.month}-#{last_month.day}"
else
  start_date = ARGV[0]
  end_date = ARGV.length > 1 ? ARGV[1] : Time.now.strftime("%Y-%m-%d")
end

# Print heading
puts "Windows Usage for #{start_date} to #{end_date}"
puts
printf("%-20s %-20s %-20s %s\n", "User", "Start", "End", "Hours")
75.times { print '-' }
puts

# Start and End dates
start_date = Time.parse(start_date).to_i
end_date   = Time.parse(end_date).to_i

# Connect to the DB
d = Mysql.new host, user, password, 'stacktach'

# Collect all of the compute.instance.create events
event_rs = d.query "select start_raw_id from stacktach_timing where start_when >= '#{start_date}' and end_when <= '#{end_date}' and name ='compute.instance.create'"
event_rs.each_hash do |row|
  # Get the raw data of the event
  json_rs = d.query "select json, stacktach_rawdata.when as w from stacktach_rawdata where id = '#{row['start_raw_id']}'"
  raw_row = json_rs.fetch_hash
  j = JSON.parse(raw_row['json'])
  if j[1].has_key?('payload')
    image_name = j[1]['payload']['image_name']
    # This might be an issue
    if image_name =~ /windows/i
      # We have the windows images that were launched. 
      tenant = j[1]['_context_project_name']
      instance_start = Time.at(raw_row['w'].to_i)
      instance_start_print = instance_start.strftime("%Y-%m-%d %H:%M")
      instance_id = j[1]['payload']['instance_id']
      
      # Let's try to find when they were destroyed, if at all
      instance_rs = d.query "select last_state, last_raw_id, stacktach_rawdata.when as w from stacktach_lifecycle inner join stacktach_rawdata on stacktach_lifecycle.last_raw_id=stacktach_rawdata.id where stacktach_lifecycle.instance = '#{instance_id}'"
      instance_hash = instance_rs.fetch_hash
      instance_end = ''
      instance_end_print = "Still running"
      duration = Time.now - instance_start
      if instance_hash['last_state'] == 'deleted'
        instance_end = Time.at(instance_hash['w'].to_i)
        instance_end_print = instance_end.strftime("%Y-%m-%d %H:%M")
        duration = instance_end - instance_start
      end

      # Calculate the duration
      hours = (duration / 60).to_i / 60

      # Print out the info
      printf("%-20s %-20s %-20s %-20s\n", tenant, instance_start_print, instance_end_print, hours)

    end
  end
end
