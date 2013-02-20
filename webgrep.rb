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
    
    
    def run_valid_url_children(ls)
        if @is_top 
            puts "searching "+ls.length.to_s+" subpages" 
        end
        
        to_visit = ls
        @visited.concat(to_visit)
        @visited = @visited.uniq
        
        search_matches = []
        
        to_visit.each_index {|i|
            if @is_top 
                puts "searching "+to_visit.length.to_s+" subpages" 
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
    
    
    def run_valid_url_childless()
        if search()
            return @page_url,@visited
        else
            return nil,@visited
        end
    end
        
    
    def run 
        
        if @doc.is_a?(NilClass)
            return nil,@visited
        end
        
            
        if @depth > 0
            return run_valid_url_children(links())
        else
            return run_valid_url_childless
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
        
        allowed_reg = Regexp.new "(\\.edu|\\.com|\\.info|\\.org|\\.co.uk|\\.ru|\\.eu|\\.net|\\.gov|\\.biz)"
        disallowed_reg = Regexp.new "(?i:mailto|\\.pdf|\\.jpg|\\.png|\\.bmp|\\.js|\\.jpeg|\\.gif|goto)"
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
#g.init("[Cc]ontact [Uu]s","http://people.cs.umass.edu/~thelmuth/index.html",2)