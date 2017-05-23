#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'json'
require 'better_errors'
require 'date'

set :bind, '0.0.0.0'

configure :development do
	use BetterErrors::Middleware
	BetterErrors.application_root = __dir__
end

content =
    { :date => Date.today,
      :author => '<your name here>',
      :title => 'NGINX Microservices Network Architecture Training',
      :body => 'Join us Friday, September, 9 for "Microservice Network Architectures with NGINX Plus". In this one day hands-on training, you will explore the Proxy, Router Mesh, and Fabric network architecture models through the NGINX Microservices Reference Architecture. In hands-on labs, you will create an NGINX proxy to a microservices application. You’ll then do centralized load balancing in the Router Mesh model. Finally, you’ll do container-to-container load balancing using the Fabric Model.

Audience: This class is for experienced developers and NGINX admins who understand microservices architectures.

What: A one day, hands-on, team-based learning experience with NGINX’s Chris Stetson and professional services team. Participants will explore three microservice network architectures through in class lectures and hands-on activities.

You will:

Learn how to deploy NGINX Plus as a HTTP gateway to their microservices application
Deploy NGINX Plus to act as a centralized load-balancer for interprocess communication between their microservices
Deploy NGINX Plus at the container level to create a fabric network of persistent SSL connections between their microservices
Collaborate and connect with other participants
Get your questions answered by experts from NGINX
Prerequisites/Requirements:

Solid understanding of web server functionality
Experience working with NGINX .conf files
Working knowledge of NGINX proxy and load balancing capabilities
Comfortable working on the command line in a UNIX environment
Attendees should bring a wifi-enabled laptop to the class'
    }

before do
  content_type 'application/json'
end

get '/' do
	"Sinatra is up!"
end

# Send back content
get '/content' do
  content.to_json
end
