#!/usr/bin/env ruby

require 'rest-client'
require 'yaml'
require 'awesome_print'

config_file_name = ARGV[0] || File.join(File.dirname(__FILE__), 'config.yml')
config = YAML::load(File.open(config_file_name))

abort('No instance provided in config') if config['instance'].nil?

tablenames = config['tables']

tablenames.each_with_index do |table, i|
	url = "https://#{config['instance']}.service-now.com/#{table}_list.do?XML"
	username = config['username']
	pass = config['password']

	puts "#{i}: #{url}"
	resource = RestClient::Resource.new url, username, pass

	resource.get do |response, request, result|
		case response.code
		when 200
			# Invalid table names return a HTTP200
			if response == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><error message=\"invalid table name\" table_name=\"#{table}\"/>"
				puts "ERROR: Invalid table: #{table}"
			else
				File.open(File.join(File.dirname(__FILE__), 'data', "#{table}.xml"), 'w') do |f|
					f << response
				end
			end
			 	 
		when 401
			abort("HTTP401: Incorrect username/password. Check the configuration file")
		else
			puts "ERROR: HTTP#{response.code}"
			ap response
			abort('An error occurred')
		end
	end
end