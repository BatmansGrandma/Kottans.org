require 'rspec'
require 'rack/test'
require 'pry'
require 'rspec-html-matchers'
require 'timecop'
require 'securerandom'
require 'sinatra'
require 'data_mapper'
require 'active_support/all'
require 'aes'
require_relative '../main.rb'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include RSpecHtmlMatchers
end
