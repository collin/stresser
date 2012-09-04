$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'rspec'
require 'progressbar'
require_relative './../lib/httperf'
require_relative './../lib/mp_perf'
