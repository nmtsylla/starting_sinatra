require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'json'
require 'omniauth'
require 'omniauth-facebook'
require 'omniauth-twitter'
require 'sinatra/flash'
gem 'social-share-button'


DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

class Message
  include DataMapper::Resource

  property :id, Serial
  property :title, Text, :required => true
  property :content, Text, :required => true
  property :episode, Integer, :required => false
  property :dinama_nekh, Integer, :default => 0
  property :published, Boolean, :default => false
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user
end

class User
  include DataMapper::Resource

  property :id,         Serial
  property :uid,        String
  property :name,       String
  property :nickname,   String
  property :email,      String
  property :provider,   String
  property :created_at, DateTime

  has n, :messages
  has n, :acteurs
end

class Acteur
  include DataMapper::Resource

  property :id,         Serial
  property :nickname,   String
  property :created_at, DateTime

end

class FacebookOauth
  include DataMapper::Resource

  property :id,   Serial
  property :access_token,  String
  property :user_id,  Integer

end
DataMapper.finalize.auto_upgrade!



configure do
  set :sessions, true
end



use OmniAuth::Builder do
  provider :facebook, '431041215459043', '086713cf927b64e4b8de71a1a19e731b'
  provider :twitter, 'SBNm4VHQtY9RvZG155dvtw', 'wqXfcGjlHjBdQniuCZgcp7avXtiluc5LGlQ5aBOf0'
  #provider :att, 'client_id', 'client_secret', :callback_url => (ENV['BASE_DOMAIN']
end



def herb(template, options={}, locals={})
	render 'html.erb', template, options, locals
end


helpers do

  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end

  def protected!
    unless current_user
      flash[:error] = 'Get connected please!'
      redirect '/'
    end
  end

	def partial(template,locals=nil)
	  if template.is_a?(String) || template.is_a?(Symbol)
	    template=('_' + template.to_s).to_sym
	  else
	    locals=template
	    template=template.is_a?(Array) ? ('_' + template.first.class.to_s.downcase).to_sym : ('_' + template.class.to_s.downcase).to_sym
	  end
	  if locals.is_a?(Hash)
	    erb(template,{:layout => false},locals)      
	  elsif locals
	    locals=[locals] unless locals.respond_to?(:inject)
	    locals.inject([]) do |output,element|
	      output <<     erb(template,{:layout=>false},{template.to_s.delete('_').to_sym => element})
	    end.join('\n')
	  else 
	    erb(template,{:layout => false})
  	  end
	end
end




get '/auth/:provider/callback' do
  auth = request.env['omniauth.auth']
  user = User.first_or_create({ :uid => auth['uid']}, {
      :uid => auth['uid'],
      :nickname => auth['info']['nickname'],
      :name => auth['info']['name'],
      :provider => auth['provider'],
      :created_at => Time.now })
  session[:user_id] = user.id
  redirect '/'
end


get '/auth/failure' do
  erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
end


get '/auth/:provider/deauthorized' do
  erb '#{params[:provider]} has deauthorized this app.'
end




get '/add' do
  protected!
  @title = 'Ajouter un post'
  herb :add
end

get '/' do
  #protected!
	@notes = Message.all(:order => [ :id.desc ], :limit => 20)
  @top = Message.all(:order => [ :dinama_nekh.desc ], :limit => 3)
	@title = 'Daro facts'
	herb :article
end


get '/messages' do
  @notes = Message.all(:order => [ :id.desc ])
  @title = 'Tous les posts'
  herb :articles
end


post '/' do
  protected!
	n = Message.new
	n.content = params[:content]
	n.title = params[:title]
  n.user = current_user
  n.episode = params[:episode]
	n.created_at = Time.now
	n.updated_at = Time.now
	n.save
	redirect '/'
end


get '/message/:id' do
  protected!
	@note = Message.get params[:id]
	@title = "Edition ##{params[:id]}"
	herb :edit
end


put '/message/:id' do
  protected!
  n = Message.get params[:id]
  n.content = params[:content]  
  n.title = params[:title]
  n.episode = params[:episode]
  n.updated_at = Time.now  
  n.save  
  redirect '/'  
end  


get '/message/:id/delete' do
  protected!
  n = Message.get params[:id]
  if n.user == current_user
    n.destroy
    flash[:success] = 'Post successfully deleted'
  else
    flash[:error] = 'Hey dont delete other''s post'
  end
  redirect '/'
end  

get '/dinama_nekh/:id' do
  protected!
  n = Message.get params[:id]
  n.dinama_nekh += 1
  n.save
  redirect '/'
end

get '/logout' do
  session[:user_id] = nil
  redirect '/'
end
