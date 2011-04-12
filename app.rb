require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'flickraw'

FlickRaw.api_key = "8e111f079960796424689d29fc4c5461"
set :haml, :format => :html5

get '/' do
  if params[:user] == 'error'
    @error = true
  end
  
  haml(:index)
end

get '/link' do
  @link = "http://flickrss.heroku.com/rss/#{params[:user]}"
  begin
    @user = flickr.people.getInfo(:user_id => params[:user])
  rescue
    redirect to '/?user=error'  # in case the ID is not recognised
  end

  haml(:link)
end

get '/rss/*' do
  content_type 'application/rss+xml', :charset => 'utf-8'
  headers['Cache-Control'] = 'public, max-age=21600' # Cache for six hours
  
  # have this populated by input form
  user_id = params["splat"].first
  user = flickr.people.getInfo(:user_id => user_id)
    
  # get my photosets
  photosets = flickr.photosets.getList(:user_id => user_id).to_a
  
  array = []
  
  photosets[0..19].each do |set|
    
    # get the primary photo for thumbnail and photoset url
    primary = flickr.photos.getInfo(:photo_id => set.primary)
        
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
  @sets = array.reverse # so they appear in the right order chronologically
  @user = user
  
  haml(:rss, :format => :xhtml, :layout => false)
end

get '/style.css' do
  sass :style
end