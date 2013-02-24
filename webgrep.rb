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
        end
                
        
        if @depth > 0
            to_visit = links()
            @visited.concat(to_visit)
            @visited = @visited.uniq
            else
            to_visit = []
        end
        
        search_matches = []
        
        
        if @is_top 
            puts "searching "+to_visit.length.to_s+" subpages" 
        end
        
        to_visit.each_index {|i|
            if @is_top 
                puts "searching "+i+" of "+to_visit.length.to_s+" subpages" 
            end
            
            child = Webgrep.new(@regex_target,to_visit[i],@depth-1,@visited)
            
            child_matches, child_visited = child.run
            
            if !child_matches.is_a?(NilClass)
                child_matches = child_matches.to_a.flatten
                child_matches.each_index {|j|
                    temp = child_matches[j].strip
                    if !search_matches.include?(temp) && !temp.is_a?(NilClass)
                        search_matches << temp
                    end
                }
            end
            
            child_visited.flatten.each {|o|
                if o != nil && !@visited.include?(o)
                    @visited << o
                end
            }
            
        }
        
        if search() && !search_matches.include?(@page_url)
            search_matches << @page_url
        end
        
        return search_matches,@visited
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