#!/usr/bin/env ruby
require 'open-uri'
require 'rubygems'
require 'nokogiri'

class Webgrep
    attr_accessor :doc, :base_url, :target
    
    
    def initialize(reg_target, url, depth, visitede)
        if reg_target.class == String
            @target = Regexp.new reg_target
        else
            @target = reg_target
        end
        @base_url = url
        @visited = visitede
        @depth = depth.to_i
        @visited << @base_url
        @top = nil
        
        begin
            @doc = Nokogiri::HTML(open(url))
        rescue Exception
            @doc = nil
        end
    end
    
    
    def set_top()
        @top = true
    end
    
    
    def links() #returns all the links off the page minus the ones already visited and the current page (obviously!)
        
        base_url = @base_url.split(/\//)
        base_terminal = base_url[base_url.length-1]
        base_decoded = base_url[0]+"//"
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
        
        
        processed.delete(@base_url[0,@base_url.length-1])
        processed.delete("https"+@base_url[4,@base_url.length])
                        
        processed = processed.uniq()
        processed.each {|i|
            if i[0,3] != "htt"
                i.insert(0,base_decoded)
            end
        }
        processed -= @visited
        
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
        
        if @doc != nil
            next_visit = links()
        end
                
        if @doc == nil
            return nil,@visited
        
        elsif @depth > 0
            g = []
            
            next_visit.each {|x|
                temp = Webgrep.new(@target,x,@depth-1,@visited)
                xx = temp.run
                if xx[0] != nil && g.include?(xx[0]) == false
                    g << xx[0]
                end
                
                xx[1].each {|x|
                    if x != nil && @visited.include?(x) == false
                        @visited << x
                    end
                }
            }
            g = g.compact
            if search() != nil
                g << @base_url
            end
            return g,@visited
                
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