require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'flickraw'
require 'cgi'

configure do  
  # Set API key
  FlickRaw.api_key="8e111f079960796424689d29fc4c5461"

  # get my user id
  user_id = flickr.people.findByUsername(:username => 'Mark Turner').id
  
  # get my photosets
  @@photosets = flickr.photosets.getList(:user_id => user_id).to_a
  
end

get '/' do
  content_type 'application/rss+xml'
  headers['Cache-Control'] = 'public, max-age=21600' # Cache for six hours
  
  array = []
  
  @@photosets.each do |set|
    
    # get the primary photo for thumbnail and photoset url
    primary = flickr.photos.getInfo(:photo_id => set.primary)
    
    # push sets to an array
    array << {  
      :title => CGI.escapeHTML(set.title), 
      :description => CGI.escapeHTML(set.description),
      :count => set.photos,
      :thumbnail_url => FlickRaw.url_m(primary),
      :photoset_link_url => FlickRaw.url_photoset(primary) 
    }
  end
  
  # return array as json object
  @array = array
  
  haml(:rss, :format => :xhtml, :escape_html => true, :layout => false)
end