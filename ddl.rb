require_relative './lib/connection'

DB.drop_table? :doctor_apps, :vehicle_apps, :doctors, :vehicles

DB.create_table(:doctors) do
  primary_key :id
  String      :name, null: false
end

DB.create_table(:vehicles) do
  primary_key :id
  String      :type
  String      :plate, null: false
end

DB.create_table(:doctor_apps) do
  primary_key :id
  foreign_key :doctor_id, :doctors
  DateTime    :start_at
  DateTime    :end_at
end

DB.create_table(:vehicle_apps) do
  primary_key :id
  foreign_key :vehicle_id, :vehicles
  DateTime    :start_at
  DateTime    :end_at
end