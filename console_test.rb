require 'mechanize'
require 'cgi'

search_url = "http://www.google.com/movies?hl=zh-TW&near=%E5%9F%BA%E9%9A%86%E5%B8%82%2C+%E5%9F%BA%E9%9A%86%E5%B8%82&date=0"

@agent = Mechanize.new
page = @agent.get(search_url)