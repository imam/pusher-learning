require 'sinatra'
require 'sequel'
require 'mysql2'
require 'htmlentities'
require 'gon-sinatra'
require 'json'
require 'pusher'
require 'dotenv/load'

Sinatra::register Gon::Sinatra

DB = Sequel.connect(ENV['DB'])

class Status < Sequel::Model(:status)
end

pusher_client = Pusher::Client.new(
  app_id: ENV['PUSHER_ID'],
  key: ENV['PUSHER_KEY'],
  secret: ENV['PUSHER_SECRET'],
  cluster: ENV['PUSHER_CLUSTER'],
  encrypted: true
)

def get_request_body(request)
	data = JSON.parse request.body.read
	return data
end

def get_model_values(model)
	data = []
	model.each{|m| data << m.values}
	return data
end

get '/' do
	gon.status = get_model_values Status.reverse_order(:id)
	@status = Status.all
	erb :index
end

post '/' do
	status = get_request_body(request)['data']['status']
	Status.create(:status => status)
	pusher_client.trigger('status','status-update',{
		status: get_model_values(Status.reverse_order(:id))	
	})
	"Ok"
end

delete '/' do
	status_id = get_request_body(request)['id']
	Status[status_id].delete
	pusher_client.trigger('status','status-update',{
		status: get_model_values(Status.reverse_order(:id))	
	})
	"ok"
end