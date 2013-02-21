#!/usr/bin/env ruby
require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'link-parser.rb'

class Webgrep
    attr_accessor :doc, :page_url, :regex_target, :is_top
        
    
    def initialize(regex_search_target, url, depth, visited=[], top_status=nil)
        @regex_target = regex_search_target
        @page_url = url
        @visited = visited << @page_url
        @depth = depth
        @is_top = top_status
        
        begin
            @doc = Nokogiri::HTML(open(url))
        rescue Exception
            @doc = nil
        end
    end
    
    
    def search()
        begin
            text = @doc.xpath("//text()")
            text.each {|x|
                if @regex_target.match(x.content) != nil
                    return true
                end
            }
            return nil
            rescue NoMethodError
            puts "tried to search an empty doc"
        end
    end

    
    def run 
        if @doc.is_a?(NilClass)
            return nil,@visited
        
        else
            return run_valid_url
        end
    end


    
    def links()
        begin
            return LinkParser.new.parse(@page_url,@doc.css("a"),@visited) 
        rescue Exception
            "tried to parse links on empty doc"
            exit
        end
    end
    
end


#g.init("[Cc]ontact [Uu]s","http://people.cs.umass.edu/~thelmuth/index.html",2)