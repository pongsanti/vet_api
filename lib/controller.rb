require 'json'
require 'sinatra'
require_relative './connection'

# Hooks
before do
  req_body = request.body.read
  @payload = req_body.empty? ? {} : JSON.parse(req_body, symbolize_names: true)
end

# doctors
get '/doctors' do
  doctors = DB[:doctors].order(:id)
  [200, JSON.generate(doctors: doctors.all)]
end

post '/doctors' do
  DB[:doctors].insert(@payload)
  [201, JSON.generate(message: 'OK')]
end

# vehicles
get '/vehicles' do
  vehicles = DB[:vehicles].order(:id)
  [200, JSON.generate(vehicles: vehicles.all)]
end

post '/vehicles' do
  DB[:vehicles].insert(@payload)
  [201, JSON.generate(message: 'OK')]
end

# doctor apps
post '/doctor/:doctor_id/apps' do
  doctor_id = params[:doctor_id]

  DB[:doctor_apps].insert(doctor_id: doctor_id,
    start_at: @payload[:start_at],
    end_at: @payload[:end_at]);
  [201, JSON.generate(message: 'OK')]  
end