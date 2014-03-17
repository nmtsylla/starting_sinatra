require 'rubygems'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-facebook'
require 'omniauth-twitter'
#TODO require 'omniauth-att'


configure do
  set :sessions, true
  set :inline_templates, true
end

use OmniAuth::Builder do
  provider :facebook, '431041210359043','086713cf8f7b64e4b8de71a1a19e731b', :scope => 'publish_stream,email,offline_access'
  provider :twitter, 'SBNm4VHQtY9RvZG155dvww', 'wqXwcGjlHjBdQniuCZgcp7avXtiluc5LGlQ5aBOf0'
  #provider :att, 'client_id', 'client_secret', :callback_url => (ENV['BASE_DOMAIN']
end

get '/' do
  erb "
  <a href='http://localhost:4567/auth/facebook'>Login with facebook</a><br>
  <a href='http://localhost:4567/auth/twitter'>Login with twitter</a><br>
  <a href='http://localhost:4567/auth/att-foundry'>Login with att-foundry</a>"
end


get '/auth/:provider/callback' do
  session[:authenticated] = true
  erb "<h1>#{params[:provider]}</h1>
       <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
end

get '/auth/failure' do
  erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
end

get '/auth/:provider/deauthorized' do
  erb "#{params[:provider]} has deauthorized this app."
end

get '/protected' do
  throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
  erb "<pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
       <a href='/logout'>Logout</a>"
end

get '/logout' do
  session[:authenticated] = false
  redirect '/'
end
