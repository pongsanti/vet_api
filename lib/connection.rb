require 'sequel'

HOST = 'localhost'
USER = 'vet'
PASS = 'vet'
DBNAME = 'vet'

DB = Sequel.connect("postgres://#{USER}:#{PASS}@#{HOST}/#{DBNAME}")