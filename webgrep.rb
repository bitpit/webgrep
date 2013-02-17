#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'

class Webgrep
    attr_accessor :doc, :base_url
    
    def initialize(reg_target, url, depth)
        @target = reg_target
        @base_url = url
        @visited = []
        @next_visit = []
        @depth = depth
        @doc = Nokogiri::HTML(open(url))
        @depth_track = 0
        @contains_query = []
        
    end
    
    
    def links() #returns all the links off the page minus the ones already visited and the current page (obviously!)
        
        if @base_url[0,3].downcase == "htt" #gets the current "page.html"
            base_terminal = @base_url[6..@base_url.length].split(/\//)
        else
            base_terminal = @base_url[6..@base_url.length].split(/\//)
        end
        base_terminal = base_terminal.drop(base_terminal.length-1)
        base_url = @base_url.split(/\//)
        base_decoded = "http://"
        (2..base_url.length-2).each {|j|
            base_decoded << base_url[j]
            base_decoded << "/"
        }
        
        raw = @doc.css("a")
        processed = []
        raw.each {|x| 
            if x.values[0].length > 3 && x.values[0][0,3] != "jav" &&
                (/(\.edu|\.com|\.info|\.org|\.co.uk|\.ru|\.eu|\.net)/).match(x.values[0]) != nil &&
                (/mailto/).match(x.values[0]) == nil
                processed << x.values[0]
            end}
        
        
        processed -= base_terminal
        processed = processed.uniq()
        processed.each {|i|
            if i[0,3] != "htt"
                i.insert(0,base_decoded)
            end
        }
        processed -= @visited
        if (processed.uniq != nil)
            return processed.uniq
        else return processed
        end
    end 
    
    
    def search
        text = @doc.xpath("//text()")
        x = File.open("file.txt",'w')
        text.each {|z| x.puts z}
        x.close
    end
    
    
    def tester
        raw = @doc.css("a")
        processed = []
        raw.each {|x| 
            if x.values[0].length > 3 && x.values[0][0,3] != "jav"
                processed << x.values[0]
            end}
        return processed
    end

end


#g = Webgrep.new
# args = ("(H|h)elmuth","http://people.cs.umass.edu/~thelmuth/index.html",3)
#@doc.xpath("//text()") #all text