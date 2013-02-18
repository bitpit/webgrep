require 'open-uri'
require 'rubygems'
require 'nokogiri'


class Test
    
    
    attr_accessor :visited, :matched, :target
    
    def initialize(targ)
        @target = Regexp.new targ
    end
    
    
    def load_test()
        begin
            @visited = []
            @matched = []
            file1 = File.open("visited",'r')
            file2 = File.open("matched",'r')
            while (line = file1.gets)
                visited << line
            end
            while (line = file2.gets)
                matched << line
            end
            puts visited
            puts "visited"
            5.times {puts}
            puts matched
            puts "matched"
            5.times {puts}
            (0..@visited.length-1).each {|x| @visited[x] = @visited[x].strip}
            (0..@matched.length-1).each {|x| @matched[x] = @matched[x].strip}
        rescue Exception
            puts "something fucked up -exiting"
            exit
        end
    end
    
    
    def checker()
        puts
        puts "---------------------------------------------------------"
        puts "Visited"
        matches = 0
        bad_urls = 0
        misses = 0
        (0..@visited.length-1).each {|i|
            begin
                doc = Nokogiri::HTML(open(@visited[i]))
                if search(doc)
                    matches += 1
                    puts "-"+@visited[i]+" -- got a match detected"
                else
                    puts "-"+@visited[i]+" -- no match"
                    misses += 1
                end
            rescue Exception 
                puts "-"+@visited[i]+" -- bad url"
                bad_urls += 1
            end
        }
        puts
        puts ""+matches.to_s+" matches detected"
        puts ""+misses.to_s+" misses"
        puts ""+bad_urls.to_s+" bad urls"
        2.times {puts}
        puts "---------------------------------------------------------"
        puts "Matched"
        (0..@matched.length-1).each {|i|
            begin
                doc = Nokogiri::HTML(open(@visited[i]))
            if search(doc)
                puts "-"+@visited[i]+" -- got a match detected"
            else
                puts "-"+@visited[i]+" -- no match"
            end
            rescue Exception 
                puts "-"+@visited[i]+" -- bad url"
            end
        }
        2.times {puts}
    end
            
            
    def search(doc)
        text = doc.xpath("//text()")
        text.each {|x|
            if @target.match(x.content) != nil
                return true
            end
        }
        return nil
    end
    
end
