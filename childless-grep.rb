#!/usr/bin/env ruby
require 'webgrep.rb'

class  Childlessgrep < Webgrep

    
    def initialize(regex_search_target, url, depth, visited=[], top_status=nil)
        super(regex_search_target, url, depth, visited=[], top_status=nil)
    end
    
    
    def run_valid_url()
        if search()
            return @page_url,@visited
        else
            return nil,@visited
        end
    end
        
end