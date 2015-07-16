require 'mongoid'

Mongoid.load!('mongoid.yml', :development)

require 'nokogiri'
require 'open-uri'
require 'pp'
require 'rest-client'
require 'parallel'
require 'pry'

require './local.rb'
require './especialidade.rb'
require './prestador.rb'

require './bradesco.rb'

# Bradesco.new

pp Prestador.where(plano: 'Bradesco').pluck(:uf).uniq