#!/usr/bin/env ruby
require 'open-uri'
require 'webgrep.rb'


class Grep
    
    
    def make
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
    
    
    def testes(to_write)
        begin
            file1 = File.open("matched",'w')
            file2 = File.open("visited",'w')
            to_write[0].each {|i| file1.puts i}
            to_write[1].each {|i| file2.puts i}
            file1.close
            file2.close
        rescue Exception
            puts "something cocked up"
        end
    end
    
    
    def run
        top_page = Webgrep.new(@target,@base_url,@depth,[]) #make top page, tell it its top
        top_page.is_top=(true)
        results = top_page.run #recursively looks through pages; returns [matched, visited] sites
        testes(results)
        results = results[0].compact.uniq #shouldn't be needed but doesn't hurt
        results = results.delete_if {|x| x.length < 3}
        print_results(results)
    end
    
    
    def print_results(results)
        if results.length == 0
            puts "Found no matches."
        elsif results.length == 1
            puts "Found 1 match at:"
            puts results
        else
            puts "Found "+results.length.to_s+" matches at:"
            puts results
        end
    end
        
    
end


g = Grep.new
g.make
g.run()
