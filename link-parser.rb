class LinkParser
    
  
    def parse(url,links,visited)
        css_format = links
        url_last_stripped = strip_last(url)
        processed_links = process(css_format,url_last_stripped)
        processed_links -= visited
        return processed_links
    end
    
    
    def strip_last(url)
        
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
    
    
    def process(css_format,url_last_stripped)
        
        is_full? = Regexp.new "^http"
        disallowed_reg = Regexp.new "(?i:mailto|\\.pdf|\\.jpg|\\.png|\\.bmp|\\.js|\\.jpeg|\\.gif|goto)"
        processed_links = []
        
        css_format.each {|css_link|
            link_value = css_link.values[0]
            if is_full?.match(link_value) && !disallowed_reg.match(link_value)
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
