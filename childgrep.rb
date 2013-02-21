#!/usr/bin/env ruby
require 'webgrep.rb'
require 'childlessgrep.rb'

class Childgrep < Webgrep
    
    
    def initialize(regex_search_target, url, depth, visited=[], top_status=nil)
        super(regex_search_target, url, depth, visited=[], top_status=nil)
    end
    
    
    def run_valid_url
        to_visit = links()
        @visited.concat(to_visit)
        @visited = @visited.uniq
        
        search_matches = []
        
        if @is_top 
            puts "searching "+to_visit.length.to_s+" subpages" 
        end
        
        to_visit.each_index {|i|
            if @is_top 
                puts "searching "+to_visit.length.to_s+" subpages" 
            end
            
            if @depth-1 > 0
                child = Childgrep.new(@regex_target,to_visit[i],@depth-1,@visited)
                else
                child = Childlessgrep.new(@regex_target,to_visit[i],@depth-1,@visited)
            end
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
    

end