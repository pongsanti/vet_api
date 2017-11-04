require 'json'
require 'sinatra'
require_relative './connection'

DATE_TIME_FORMAT = '%d/%m/%Y %H:%M'

# Hooks
before do
  req_body = request.body.read
  @payload = req_body.empty? ? {} : JSON.parse(req_body, symbolize_names: true)
end


CORS_HASH = {
  'Access-Control-Allow-Origin' => '*',
  'Access-Control-Allow-Methods' => 'HEAD,GET,PATCH,POST,DELETE,OPTIONS',
  'Access-Control-Allow-Headers' => 'X-Authorization, Content-Type' }

after do
  # CORS
  unless request.request_method == 'OPTIONS'
    headers CORS_HASH
  end
end

helpers do  
  def datetime_format datetime
    datetime ? datetime.strftime(DATE_TIME_FORMAT) : nil
  end
end

# CORS
options "*" do
  headers CORS_HASH
  200
end

# doctors
get '/doctors' do
  doctors = DB[:doctors].where(deleted_at: nil).order(:id)
  [200, JSON.generate(doctors: doctors.all)]
end

post '/doctors' do
  DB[:doctors].insert(@payload)
  [201, JSON.generate(message: 'OK')]
end

delete '/doctors/:id' do
  id = params[:id]
  if id
    DB[:doctors].where(id: id).update(deleted_at: DateTime.now)
  end
  [200, JSON.generate(message: 'OK')]
end

# vehicles
get '/vehicles' do
  vehicles = DB[:vehicles].where(deleted_at: nil).order(:id)
  [200, JSON.generate(vehicles: vehicles.all)]
end

post '/vehicles' do
  DB[:vehicles].insert(@payload)
  [201, JSON.generate(message: 'OK')]
end

delete '/vehicles/:id' do
  id = params[:id]
  if id
    DB[:vehicles].where(id: id).update(deleted_at: DateTime.now)
  end
  [200, JSON.generate(message: 'OK')]
end

# doctor apps
get '/doctor/apps' do
  apps = DB[:doctor_apps].left_join(:doctors, id: :doctor_id).order(Sequel[:doctor_apps][:id]).all

  apps = apps.map do |a|
    a[:start_at] = datetime_format a[:start_at]
    a[:end_at] =  datetime_format a[:end_at]
    a
  end

  [200, JSON.generate(apps: apps)]
end

post '/doctor/:doctor_id/apps' do
  doctor_id = params[:doctor_id]

  DB[:doctor_apps].insert(doctor_id: doctor_id,
    start_at: @payload[:start_at],
    end_at: @payload[:end_at]);
  [201, JSON.generate(message: 'OK')]  
end