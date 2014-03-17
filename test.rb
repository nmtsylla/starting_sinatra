require 'sinatra'
require 'koala'

enable :sessions
#set :raise_errors, false
#set :show_exceptions, false

#use Rack::Session::Cookie, :secret => 'A1 sauce 1s so good you should use 1t on a11 yr st34ksssss'
FACEBOOK_SCOPE = 'user_likes,user_photos,user_photo_video_tags'
APP_ID = '431041210359043'
APP_SECRET = '086713cf8f7b64e4b8de71a1a19e731b'


get '/' do
  if session['access_token']
    begin
      @graph = Koala::Facebook::GraphAPI.new(session['access_token'])
      @profile = @graph.get_object('me')
      @graph.put_connections("me", "feed", :message => "I am writing on my wall!")
      @a = 'You are logged in! <a href="/logout">Logout</a> '
      rescue => e
        @error =  e.backtrace
    end
    erb :index



    # do some stuff with facebook here
    # for example:
    #@graph = Koala::Facebook::GraphAPI.new(session["access_token"])
    # publish to your wall (if you have the permissions)
    #@graph.put_wall_post("I'm posting from my new cool app!")
    # or publish to someone else (if you have the permissions too ;) )
    # @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")
  else
    '<a href="/login">Login</a>'
  end
end

get '/login' do
  # generate a new oauth object with your app data and your callback url
  session['oauth'] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, "#{request.base_url}/callback")
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
  session['infos'] = session['oauth'].get_user_info_from_cookies(request.cookies)
  redirect '/'
end