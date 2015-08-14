# encoding: UTF-8
require 'nokogiri'
require 'chronic_duration'

module GoogleMovies47
  class Parser
    
    attr_accessor :movies, :theaters
    
    def initialize(language = 'en')
      @language = language
      @language_parser = GoogleMovies47::LanguageParser.new(language)
      @genre_parser = GoogleMovies47::GenreParser.new(language)
      @theaters = []
      @movies = Hash.new
    end
    
    def parse_show_times(doc)
      theater_elements = doc.xpath(
      "//div[@class='movie_results']/div[@class='theater' and .//h2]"
      )
      theater_elements.each do |t|
        theater_name = t.search(".//h2[@class='name']/text()").text
        theater_link = t.search(".//h2[@class='name']/a").attr('href').value rescue nil
        theater_id   = CGI::parse(theater_link)["tid"][0] rescue nil
        theater_info = t.search(".//div[@class='info']/text()").text
        showtimes = []
        movie_elements = t.search(".//div[@class='showtimes']//div[@class='movie']")
        
        movie_elements.each do |m|
          movie_name = m.search(".//div[@class='name']/a/text()").text.strip
          movie_link = m.search(".//div[@class='name']/a").attr('href').value
          movie_id   = CGI::parse(movie_link)["mid"][0] rescue nil
          movie_info_line = m.search(".//span[@class='info']/text()").text
          movie_info = parse_movie_info(movie_info_line)
          
          @movies[movie_name] = { :mid => movie_id, :name => movie_name, :info => movie_info } if @movies[movie_name].nil?
          
          movie_times = m.search(".//div[@class='times']/span/text()")
          times = []
          movie_times.each do |mt|
            time = mt.text.strip
            times << time
          end
          
          showtimes << { :mid => movie_id, :name => movie_name, :language => movie_info[:language], :times => times }
        end
        
        @theaters << { :tid => theater_id, :name => theater_name, :info => theater_info, :movies => showtimes }
      end
      
    end
    
    def parse_movie_info(info_line)
      duration = ChronicDuration.parse(info_line)
      genre = @genre_parser.parse(info_line)
      language = @language_parser.parse(info_line)
      
      { :duration => duration, :genre => genre, :language => language }
    end

  end
end