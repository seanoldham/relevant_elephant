load '~/relevant_elephant/secrets.rb'
require 'rubygems'
require 'mini_magick'
require 'json'
require 'httparty'
require 'twitter'

def image_merge
  elephant = MiniMagick::Image.open('elephant.png')
  bg = MiniMagick::Image.open(@image_url)
  elephant_height = (bg.height / 1.5)
  elephant_width = (bg.width / 1.5)
  elephant.resize "#{elephant_height}x#{elephant_width}"
  output = bg.composite(elephant) do |c|
    c.gravity 'SouthEast'
  end
  output.draw "text " "0,10 " "'Photo Credit: #{@image_copyright}' "
  output.format 'jpeg'
  output.write 'output.jpg'
end

def fetch_image
  @item = @response[@item_number]['multimedia'][0]
end

def tweet
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = CONSUMER_KEY
    config.consumer_secret     = CONSUMER_SECRET
    config.access_token        = ACCESS_TOKEN
    config.access_token_secret = ACCESS_TOKEN_SECRET
  end
  client.update_with_media(@image_title, File.new("./output.jpg"))
end

@item_number = 0
nyt_url = 'http://api.nytimes.com/svc/topstories/v1/home.json?api-key=' + API_KEY

while @item_number < 10
  @response = HTTParty.get(nyt_url)['results']
  fetch_image
  if @item.to_s != ""
    @image_url = @item['url'].gsub(/(thumb).*$/, "superJumbo.jpg")
    @image_copyright = @item['copyright'].to_s
    @image_title = @response[@item_number]['title'] + " With Elephants"
    @item_number = 10
  else
    @item_number += 1
    puts "No images found for top story."
    fetch_image
  end
end

puts @image_title
image_merge
tweet
