#!/usr/bin/env ruby
require 'open-uri'
require 'rubygems'
require 'nokogiri'

class Webgrep
    attr_accessor :doc, :page_url, :regex_target
    attr_writer :is_top
    
    
    def initialize(regex_target, url, depth, visited=[], top_status=nil)
        @regex_target = regex_target
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

    
    def write_to(file_name)
        text = @doc.xpath("//text()")
        file = File.open(file_name,'w')
        text.each {|i| file.puts i}
        file.close
    end
    
    
    def search()
        text = @doc.xpath("//text()")
        text.each {|x|
            if @regex_target.match(x.content) != nil
                return true
            end
        }
        return nil
    end
    
    
    def run            
        begin
            @next_visit = links()
            @visited.concat(@next_visit)
            @visited = @visited.flatten
        rescue Exception
            #yep
        end
        
        puts ""+@page_url.inspect+"   @depth "+@depth.inspect
        
        if @doc.is_a?(NilClass)
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
                child = Webgrep.new(@regex_target,@next_visit[x],@depth-1,@visited)
                child_matches, child_visited = child.run
                if !child_matches.is_a?(NilClass)
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
                        if !matches.include?(child_matches)
                            matches << child_matches
                        end
                    end
                end
                
                child_visited = child_visited.flatten
                         
                child_visited.each {|x|
                    if x != nil && !@visited.include?(x)
                        @visited << x
                    end
                }          
            }

            matches = matches.compact
            if search() != nil
                matches << @page_url
            end
            return matches,@visited
                
        else
            if search() != nil
                return @page_url,@visited
            else
                return nil,@visited
            end
        end
    end
    
    
    def links() #returns all the links off the page minus the ones already visited and the current page (obviously!)
        
        url_last_stripped = links_strip_last(@page_url)
        css_format_links = @doc.css("a")
        processed_links = links_process(css_format_links,url_last_stripped)
        processed_links -= @visited
        return processed_links #this should always be an array of links to visit in String format
    end
    
    
    def links_strip_last(url)
        
        split_url = url.split(/\//)
        
        if split_url.length > 3
            built_up = split_url[0]+"//"
            terminal = split_url.last
            (2..split_url.length-2).each {|j|
                built_up << split_url[j]
                built_up << "/" }
            return built_up
            
            else
            if url[url.length-1..url.length-1] != "/"
                return url+"/"
                else
                return url
            end
        end
    end
    
    
    def links_process(css_format,url_last_stripped)
        
        allowed_reg = Regexp.new "(\.edu|\.com|\.info|\.org|\.co.uk|\.ru|\.eu|\.net|\.gov|\.biz)"
        disallowed_reg = Regexp.new "(?i:mailto|\.pdf|\.jpg|\.png|\.bmp|\.js|\.jpeg|\.gif|goto)"
        processed_links = []
        
        css_format.each {|css_link|
            link_value = css_link.values[0]
            if allowed_reg.match(link_value) && !disallowed_reg.match(link_value)
                processed_links << link_value
                elsif link_value.length > 3 && link_value[0,4] != "java" && !disallowed_reg.match(link_value)
                if link_value[0..0] == "/"
                    processed_links << url_last_stripped.chop+link_value
                    else
                    processed_links << url_last_stripped+link_value
                end
            end
        }
        
        processed_links = processed_links.uniq.flatten
        processed_links.each_index {|i|
            processed_links[i] = processed_links[i].strip }
        processed_links.delete_if {|x| x.include? " "}
        return processed_links
    end
end


#g = Webgrep.new
# args = ("(H|h)elmuth","http://people.cs.umass.edu/~thelmuth/index.html",3)
#@doc.xpath("//text()") #all text
#g.init("[Cc]ontact","http://people.cs.umass.edu/~thelmuth/index.html",2)