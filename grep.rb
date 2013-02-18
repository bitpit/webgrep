#!/usr/bin/env ruby
require 'open-uri'
require 'webgrep.rb'


class Grep
    
    
    def initialize
        if ARGV.size > 3 || ARGV.size < 3 && ARGV.size != 0 then
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
        else
            puts "ok"
        end
    end
    
    
    def run
        f = Webgrep.new(@target,@base_url,@depth,[])
        x = f.run
        return x.compact
    end
    
end


g = Grep.new
ex = g.run()
ex.each {|x| puts x}

