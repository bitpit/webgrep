#!/usr/bin/env ruby
require 'open-uri'
require 'webgrep.rb'


class Grep
    
    
    def initialize
        if ARGV.size > 3 || ARGV.size < 3 || ARGV.size == 0 then
            puts "Please run with arguements in this form: "
            puts "     \"(Re|gex| tar|get)\" http://start_page.com 'depth of pages to search in int'"
            exit
        elsif ARGV.size != 0 then
            @target = ARGV[0]
            @base_url = ARGV[1]
            @visited = []
            @next_visit = []
            @depth = ARGV[2]
            @depth_track = 0
        end
    end
    
    
    def run
        f = Webgrep.new(@target,@base_url,@depth,[])
        f.top=(true)
        x = f.run
        x = x[0].compact
        return x.uniq
    end
    
end


g = Grep.new
ex = g.run()
if ex.length == 0
    puts "Found no matches."
elsif ex.length == 1
    puts "Found 1 match at:"
    puts ex
else
    puts "Found "+ex.length.to_s+" matches at:"
    puts ex
end


