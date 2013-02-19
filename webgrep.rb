#!/usr/bin/env ruby
require 'open-uri'
require 'rubygems'
require 'nokogiri'

class Webgrep
    attr_accessor :doc, :base_url, :target
    attr_writer :is_top
    
    
    def initialize(reg_target, url, depth, visitede)
        @target = reg_target
        @base_url = url
        @visited = visitede
        @depth = depth
        @visited << @base_url
        @is_top = nil
        
        begin
            @doc = Nokogiri::HTML(open(url))
            @next_visit = links()
        rescue Exception
            @doc = nil
        end
    end
    
    
    def links() #returns all the links off the page minus the ones already visited and the current page (obviously!)
        
        base_url = @base_url.split(/\//)
        base_terminal = base_url[base_url.length-1]
        base_decoded = base_url[0]+"//"
        if base_url.length > 3
            offset = 2
        else
            offset = 1
        end
        (2..base_url.length-offset).each {|j|
            base_decoded << base_url[j]
            base_decoded << "/"
        }
        raw = @doc.css("a")
        processed = []
        raw.each {|x| 
            if (/(\.edu|\.com|\.info|\.org|\.co.uk|\.ru|\.eu|\.net)/).match(x.values[0]) != nil &&
                (/(?i:mailto)/).match(x.values[0]) == nil &&
                (/(?i:\.pdf|\.jpg|\.png|\.bmp|\.js|\.jpeg|\.gif|goto)/).match(x.values[0]) == nil
                processed << x.values[0]
            elsif x.values[0].length > 3 && x.values[0][0,3] != "jav" && (/(?i:mailto)/).match(x.values[0]) == nil &&
                (/(?i:\.pdf|\.jpg|\.png|\.bmp|\.js|\.jpeg|\.gif|goto)/).match(x.values[0]) == nil
                if x.values[0][0..0] == "/"
                    processed << base_decoded+x.values[0][1..x.values[0].length-1]
                else
                    processed << base_decoded+x.values[0]
                end
            end
        }
                
        processed.delete(@base_url[0,@base_url.length-1])
        processed.delete("https"+@base_url[4,@base_url.length])
                        
        processed = processed.uniq()
        
        (0..processed.length-1).each {|i|
            if processed[i][0,3] != "htt"
                processed[i].insert(0,base_decoded)
            end
            if processed.is_a?(String)
                processed[i] = processed[i].strip
            end
        }
        
        processed.delete_if {|x| x.include? " "}
        
        if (processed.uniq != nil)
            return processed.uniq
        else 
            return processed
        end
    end 
    
    
    def write_to(file_name)
        text = @doc.xpath("//text()")
        file = File.open(file_name,'w')
        text.each {|i| file.puts i}
        file.close
    end
    
    
    def search()
        text = @doc.xpath("//text()")
        text.each {|x|
            if @target.match(x.content) != nil
                return true
            end
        }
        return nil
    end
    
    
    def run
        puts @base_url
        if @doc == nil
            return nil,@visited
        
        elsif @depth > 0
            matches = []
            if @is_top 
                puts "searching "+@next_visit.length.to_s+" subpages" 
            end
            
            (0..@next_visit.length-1).each {|x|
                if @is_top 
                    puts "searching subpage "+(x+1).to_s+" of "+@next_visit.length.to_s 
                end
                child = Webgrep.new(@target,@next_visit[x],@depth-1,@visited)
                child_matches, child_visited = child.run
                if child_matches != nil
                    if child_matches.is_a?(Array)
                        child_matches = child_matches.flatten
                        (0..child_matches.length-1).each {|i|
                            child_matches[i] = child_matches[i].strip }
                        child_matches.each {|x|
                            if !matches.include?(x)
                                matches << x
                            end
                        }
                            
                    else
                        child_matches = child_matches.strip
                        matches << child_matches
                    end
                end
                
                child_visited            
                child_visited.each {|x|
                    if x != nil && @visited.include?(x) == false
                        @visited << x
                    end
                }
            }

            matches = matches.compact
            if search() != nil
                matches << @base_url
            end
            return matches,@visited
                
        else
            if search() != nil
                return @base_url,@visited
            else
                return nil,@visited
            end
        end
    end
end


#g = Webgrep.new
# args = ("(H|h)elmuth","http://people.cs.umass.edu/~thelmuth/index.html",3)
#@doc.xpath("//text()") #all text
#g.init("contact","http://people.cs.umass.edu/~thelmuth/index.html",3)