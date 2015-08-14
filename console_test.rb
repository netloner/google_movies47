require 'mechanize'
require 'cgi'

search_url = "http://www.google.com.tw/movies?hl=zh-TW&near=%E5%8F%B0%E6%9D%B1&date=0&tid=a17fc5e483d8253"


@agent = Mechanize.new
page = @agent.get(search_url)
result_pages = []

doc = page.parser

theater_elements = doc.xpath(
      "//div[@class='movie_results']/div[@class='theater' and .//h2]"
      )