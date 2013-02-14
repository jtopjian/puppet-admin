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

# Windows Image Information
IMAGES = {
  'fffee34c-d3d0-47a0-9716-47ce16244769' => 'Windows 7',
  '7eecedab-5123-422d-b766-1d513b45396e' => 'Windows 2008 R2',
  '0decc679-e437-487f-8077-3c89b32fae58' => 'Windows 2008 R2',
  '87ef156c-de7f-4760-ae1f-2f04d041728e' => 'Windows 2008 R2',
}

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
jan1_date = Time.parse('2013-01-01').to_i
start_date = Time.parse(start_date).to_i
end_date   = Time.parse(end_date).to_i
# 11:59:59 of the last day of the month
end_date += 86399

# Connect to the DB
d = Mysql.new host, user, password, 'stacktach'

# Tenant hash
tenants = {}

# Collect all of the compute.instance.create events from Jan 1 and on
event_rs = d.query "select start_raw_id from stacktach_timing where start_when >= '#{jan1_date}' and name = 'compute.instance.create' order by start_when"
event_rs.each_hash do |row|
  # Get the raw data of the event
  json_rs = d.query "select json, stacktach_rawdata.when as w from stacktach_rawdata where id = '#{row['start_raw_id']}'"
  raw_row = json_rs.fetch_hash
  j = JSON.parse(raw_row['json'])
  if j[1].has_key?('payload')
    base_image_ref = j[1]['payload']['image_meta']['base_image_ref']
    # Was the instance a windows image?
    if IMAGES.keys.include?(base_image_ref)
      # Hash for instances
      instance = {}

      # Get the starting time of the instance
      instance_start = Time.at(raw_row['w'].to_i)
      instance_id = j[1]['payload']['instance_id']
      instance['instance_id'] = instance_id
      instance['start'] = instance_start
      instance['end'] = nil
      
      # Let's try to find when they were destroyed, if at all
      instance_rs = d.query "select stacktach_rawdata.when as w from stacktach_rawdata where instance = '#{instance_id}' and event = 'compute.instance.delete.start'"
      instance_hash = instance_rs.fetch_hash
      instance['duration'] = ((Time.now - instance['start']) / 60).to_i / 60
      if instance_hash
        instance_end = Time.at(instance_hash['w'].to_i)
        instance['end'] = instance_end
        instance['duration'] = ((instance_end - instance_start) / 60).to_i / 60
      end

      # Filter unwanted instances
      next if instance['start'].to_i < start_date 
      next if instance['start'].to_i > end_date
      next if instance['end'].to_i > end_date
      next if instance['duration'] < 1

      # Add an entry to the tenants hash
      tenant = j[1]['_context_project_name']
      tenants[tenant] = [] if ! tenants.has_key?(tenant)
      tenants[tenant].push(instance)

    end
  end
end

grand_total = 0
tenants.each do |tenant, instances|
  puts tenant
  total = instances.length
  x = {}
  instances.each do |instance|
    # Print out the info
    end_print = instance['end'] ? instance['end'].strftime("%Y-%m-%d %H:%M") : 'Still Running'
    start_print = instance['start'].strftime("%Y-%m-%d %H:%M")
    hours = instance['duration']
    printf("%-20s %-20s %-20s %-20s\n", '', start_print, end_print, hours)
  end

  # Figure out overlapping instances
  total = instances.length
  x = []
  instances.each do |instance|
    instances.each do |instance2|
      next if instance['instance_id'] == instance2['instance_id']
      next if ! instance2['end']
      next if x.include?(instance['instance_id'])
      if instance['start'] > instance2['end']
        x.push(instance['instance_id'])
        total -= 1
      end
    end
  end
  printf("%-20s %-20s %-20s %-20s\n", '', 'Total Concurrent', '', total)
  puts

  grand_total += total

end

puts "Grand total: #{grand_total}"
