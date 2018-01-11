require 'json'
require 'sinatra'
require_relative './connection'
require_relative './mail_setup'

DATE_TIME_FORMAT = '%d/%m/%Y %H:%M'.freeze

# Hooks
before do
  req_body = request.body.read
  @payload = req_body.empty? ? {} : JSON.parse(req_body, symbolize_names: true)
end

CORS_HASH = {
  'Access-Control-Allow-Origin' => '*',
  'Access-Control-Allow-Methods' => 'HEAD,GET,PATCH,POST,DELETE,OPTIONS',
  'Access-Control-Allow-Headers' => 'X-Authorization, Content-Type'
}.freeze

after do
  # CORS
  headers CORS_HASH unless request.request_method == 'OPTIONS'
end

helpers do
  def datetime_format(datetime)
    datetime ? datetime.strftime(DATE_TIME_FORMAT) : nil
  end
end

# CORS
options '*' do
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
  DB[:doctors].where(id: id).update(deleted_at: Time.now) if id
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
  DB[:vehicles].where(id: id).update(deleted_at: DateTime.now) if id
  [200, JSON.generate(message: 'OK')]
end

# doctor apps

def select_doctor_app
  da = Sequel[:doctor_apps]
  doc = Sequel[:doctors]

  DB[:doctor_apps]
    .select(da[:id], da[:doctor_id],
            da[:creator_name], da[:creator_tel],
            doc[:name], da[:start_at], da[:end_at])
    .left_join(:doctors, id: :doctor_id)
    .order(da[:id])
end

get '/doctor/apps' do
  apps = select_doctor_app.all

  apps = apps.map do |a|
    a[:start_at] = datetime_format a[:start_at]
    a[:end_at] = datetime_format a[:end_at]
    a
  end

  [200, JSON.generate(apps: apps)]
end

delete '/doctor/apps/:id' do
  id = params[:id]

  DB[:doctor_apps].where(id: id).delete if id

  [201, JSON.generate(message: 'OK')]
end

post '/doctor/:doctor_id/apps' do
  doctor_id = params[:doctor_id]

  app_id = DB[:doctor_apps]
           .insert(doctor_id: doctor_id,
                   start_at: @payload[:start_at],
                   end_at: @payload[:end_at],
                   creator_name: @payload[:creator_name],
                   creator_tel: @payload[:creator_tel])

  # send email
  da = Sequel[:doctor_apps]
  send_doctor_app_mail(select_doctor_app
    .where(da[:id] => app_id).first)

  [201, JSON.generate(message: 'OK')]
end

# vehicle apps
def select_vehicle_app
  va = Sequel[:vehicle_apps]
  v = Sequel[:vehicles]

  DB[:vehicle_apps]
    .select(va[:id], va[:vehicle_id], v[:plate], v[:type], va[:start_at], va[:end_at])
    .left_join(:vehicles, id: :vehicle_id).order(va[:id])
end

get '/vehicle/apps' do
  # va = Sequel[:vehicle_apps]
  # v = Sequel[:vehicles]

  apps = select_vehicle_app.all

  apps = apps.map do |a|
    a[:start_at] = datetime_format a[:start_at]
    a[:end_at] = datetime_format a[:end_at]
    a
  end

  [200, JSON.generate(apps: apps)]
end

delete '/vehicle/apps/:id' do
  id = params[:id]

  DB[:vehicle_apps].where(id: id).delete if id

  [201, JSON.generate(message: 'OK')]
end

post '/vehicle/:vehicle_id/apps' do
  vehicle_id = params[:vehicle_id]

  app_id = DB[:vehicle_apps].insert(vehicle_id: vehicle_id,
                                    start_at: @payload[:start_at],
                                    end_at: @payload[:end_at])

  # send email
  va = Sequel[:vehicle_apps]
  send_vehicle_app_mail(select_vehicle_app
    .where(va[:id] => app_id).first)

  [201, JSON.generate(message: 'OK')]
end
