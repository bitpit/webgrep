#!/usr/bin/env ruby
require 'open-uri'
require 'webgrep.rb'
require 'debug_class.rb' ###bug testing line


class Grep
        
    def init_t
        @target = Regexp.new ARGV[0]
        @base_url = ARGV[1]
        @depth = ARGV[2].to_i
    end
    
    
    def init(targ,url,depth)
        @target = Regexp.new targ
        @base_url = url
        @depth = depth.to_i
        return @target,@base_url,@depth
    end
    
    
    def run
        top_page = Webgrep.new(@target,@base_url,@depth,[]) #make top page, tell it its top
        top_page.is_top=(true)
        results = top_page.run #recursively looks through pages; returns [matched, visited] sites
        bugger = Test.new(@target) ###bug testing line
        bugger.write_test(results) ###bug testing line
        bugger.load_test() ###bug testing line
        results = results[0].compact.uniq #.compact.uniq shouldn't be needed but can't hurt
        results = results.delete_if {|x| x.length < 3}
        print_results(results)
        return bugger ###bug testing line
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

if ARGV.size == 3
    g = Grep.new
    g.init_t
    g.run()
end
