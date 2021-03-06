# encoding: UTF-8
require 'mechanize'
require 'cgi'

module GoogleMovies47
  class Crawler
    
    const_set("MissingLocationArgument", Class.new(StandardError))
    const_set("WrongDaysAheadArgument", Class.new(StandardError))
    
    def initialize(options = {})
      
      raise MissingLocationArgument unless options[:city]
      
      language = options[:language] || 'en'
      
      days_ahead = options[:days_ahead] || 0
      raise WrongDaysAheadArgument if !days_ahead.kind_of? Integer or 0 > days_ahead
      
      @parser = GoogleMovies47::Parser.new(language)
      
      search_url = "http://www.google.com.tw/movies?hl=#{language}&near=#{options[:city]}&date=#{days_ahead}"

      @agent = Mechanize.new
      page = @agent.get(search_url)
      
      crawl_result_pages(page)
      
    end
    
    def movies
      @parser.movies
    end
    
    def theaters
      @parser.theaters
    end
    
    private
    
    def crawl_result_pages(page)
      result_pages = []
      
      doc = page.parser
      result_pages << doc
      
      doc.xpath("//div[@id='navbar']/table//tr/td[not(@class='b')]/a").each do |p|
        result_pages << @agent.get(p['href']).parser
      end
     
      result_pages.each do |rp|
        @parser.parse_show_times(rp)
      end
    end
  end
end