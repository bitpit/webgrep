#!/usr/bin/env ruby
require 'open-uri'
require 'rubygems'
require 'nokogiri'

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

    
    def links() #returns all the links off the page minus the ones already visited and the current page (obviously!)
        
        begin
            css_format_links = @doc.css("a")
            url_last_stripped = links_strip_last(@page_url)
            processed_links = links_process(css_format_links,url_last_stripped)
            processed_links -= @visited
            return processed_links #this should always be an array of links to visit in String format
        rescue NoMethodError
            puts "tried to get links from an empty doc"
        end
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


#g.init("[Cc]ontact [Uu]s","http://people.cs.umass.edu/~thelmuth/index.html",2)