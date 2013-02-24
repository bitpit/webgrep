#!/usr/bin/env ruby
require 'open-uri'
require 'crawler.rb'


class Grep
    attr_accessor :target, :matched, :visited
        
    def init_t #for initializing from the command line
        #assumes that URL begins with http/https, search is string
        #and depth is int
        @target = Regexp.new ARGV[0]
        @base_url = ARGV[1]
        @depth = ARGV[2].to_i
    end
    
    
    def init(targ,url,depth) #for initializing otherwise
        @target = Regexp.new targ
        @base_url = url
        @depth = depth.to_i
        return @target,@base_url,@depth
    end
    
    
    def run
        top_page = Webgrep.new(@target,@base_url,@depth,[]) #make top page, tell it its top
        top_page.is_top=(true)
        results = top_page.run #recursively looks through pages; returns [matched, visited] sites
        @matched, @visited = results
        results = results[0]
        #results = results.delete_if {|x| x.length < 3}
        print_results(results)
        write_results?(results)
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
    
    
    def write_results?(results)
        
        str = 0
        
        while true
            begin
                print "Write to file (Y/N)? "
                system("stty raw -echo")
                str = STDIN.getc
                STDOUT.flush
                ensure
                system("stty -raw echo")
            end
            if str == 121
                fn = ""
                puts
                while fn.length < 1
                    print "Please enter file name (no overwrite checking): "
                    fn = STDIN.gets
                end
                begin
                    file = File.open(fn.chomp,'w')
                    results.each {|i| file.puts i}
                    file.close
                rescue Exception
                    puts "There was an error in saving your file. Sorry!"
                end
                return
            elsif str == 110
                puts
                return
            end
            puts
        end
    end
    
end

if ARGV.size == 3 #for running from command line
    g = Grep.new
    g.init_t
    g.run()
end
