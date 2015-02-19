require 'rubygems'
require 'sinatra'
require "instagram"
require 'twitter'
require 'koala'
require 'pry'

enable :sessions
set :session_secret, 'This is a secret key'
set :raise_errors, false
set :show_exceptions, false


#facebook setup ======================================================================
  ENV["FACEBOOK_APP_ID"] = ""
  ENV["FACEBOOK_SECRET"] = ""
  fb_access_token = ""
#facebook end ========================================================================

#instagram setup =====================================================================
  instagram_client_id = ""
  instagram_client_secret = ""

  Instagram.configure do |config|
    config.client_id = instagram_client_id
    config.client_secret = instagram_client_secret
    # For secured endpoints only
    #config.client_ips = '<Comma separated list of IPs>'
  end
#instagram end =======================================================================

#twitter setup =======================================================================
  twitter_consumer_key = ""
  twitter_consumer_secret = ""
  twitter_access_token = ""
  twitter_access_token_secret = ""
#twitter end =========================================================================



get '/' do
  #facebook ================================================
  session['access_token'] = fb_access_token
  @facebook = Koala::Facebook::API.new(session["access_token"])
  @posts = @facebook.get_connections("", "photos", :fields => "name, images, source").first(3)
  #facebook_end ============================================

  #twitter =================================================
  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ""
    config.consumer_secret     = ""
    config.access_token        = ""
    config.access_token_secret = ""
  end
  @timeline = @client.home_timeline.first(3)
  #twitter_end ============================================

  #instagram ==============================================
  @instagram = Instagram.user_recent_media("", {:count => 3})
  #instagram_end ==========================================

  erb :layout, :layout =>
    false do
      erb :main
    end
end

  get '/login' do
    # generate a new oauth object with your app data and your callback url
    session['oauth'] = Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_SECRET"], "#{request.base_url}/callback")
    # redirect to facebook to get your code
    redirect session['oauth'].url_for_oauth_code()
  end

  get '/logout' do
    session['oauth'] = nil
    session['access_token'] = nil
    redirect '/'
  end

  #method to handle the redirect from facebook back to you
  get '/callback' do
    #get the access token from facebook with your code
    session['access_token'] = session['oauth'].get_access_token(params[:code])
    redirect '/'
  end


