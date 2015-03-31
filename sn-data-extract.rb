#!/usr/bin/env ruby

require 'rest-client'
require 'uri'
require 'yaml'
require 'awesome_print'

config_file_name = ARGV[0] || File.join(File.dirname(__FILE__), 'config.yml')
config = YAML::load(File.open(config_file_name))

abort('No instance provided in config') if config['instance'].nil?

extracts = config['extracts']

extracts.each_with_index do |extract, i|
	table = extract["table"]


	url = "https://#{config['instance']}.service-now.com/#{table}_list.do?XML"
	url += "&sysparm_query=#{URI.escape(extract['query'])}" if extract.include? 'query'

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