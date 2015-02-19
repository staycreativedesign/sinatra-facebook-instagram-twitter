require './main'
require 'rubygems'
require 'bundler/setup'
Bundler.require

run Sinatra::Application
