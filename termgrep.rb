#!/usr/bin/env ruby
require 'open-uri'

class Webgrep
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
    
    def test
        doc = Nokogiri::HTML(open("http://people.cs.umass.edu/~thelmuth/index.html"))
    end
    
    def links(base_url, doc)
        raw = doc.css("a")
        processed = []
        #raw.each {|x|
    end   
    
end


g = Webgrep.new
#http://nokogiri.org/Nokogiri/HTML/Document.html
