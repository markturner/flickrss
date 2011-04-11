require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'flickraw'

configure do  
  # Set API key
  FlickRaw.api_key="8e111f079960796424689d29fc4c5461"

  # get my user id
  @@user = flickr.people.findByUsername(:username => 'Mark Turner')
  user_id = @@user.id
    
  # get my photosets
  @@photosets = flickr.photosets.getList(:user_id => user_id).to_a
  
end

get '/' do
  haml(:index, :format => :html5)
end

get '/rss' do
  content_type 'application/rss+xml', :charset => 'utf-8'
  headers['Cache-Control'] = 'public, max-age=21600' # Cache for six hours
  
  array = []
  user = @@user
  
  @@photosets[0..4].each do |set|
    
    # get the primary photo for thumbnail and photoset url
    primary = flickr.photos.getInfo(:photo_id => set.primary)
    
    set.inspect
    
    # push sets to an array
    array << {  
      :title => set.title,
      :description => set.description,
      :count => set.photos,
      :thumbnail_url => FlickRaw.url_m(primary),
      :photoset_link_url => FlickRaw.url_photosets(primary) + set.id
    }
  end
  
  # return array as json object
  @sets = array
  @user = user
  
  haml(:rss, :format => :xhtml, :layout => false)
end