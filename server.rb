require 'sinatra'
require 'sinatra/json'
require 'json'
require 'data_mapper'
require 'thin'

enable :sessions

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Site
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :content, Text
  property :priority, Integer
end

class Blog
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :priority, Integer

  has n, :posts
end

class Post
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :content, Text

  belongs_to :blog, :key => true
end

class Element
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :code, Text
  property :priority, Integer
end

DataMapper.finalize.auto_upgrade!

use Rack::Session::Cookie, :key => 'rack.session',
                           :secret => 'adminha!@#$00555'

helpers do

  def login?
    if session[:admin].nil?
      return false
    else
      return true
    end
  end

end

before do
  @firstelement = Element.first(:order => [ :priority.asc ])
  if @firstelement
    @title = @firstelement.code
  else
    @title = nil
  end
end

before '/admin/*' do
  unless login?
    redirect '/adminlogin'
  end
end

before '/admin' do
  unless login?
    redirect '/adminlogin'
  end
end

get '/' do
  @script = "/js/server.js"
  @sites = Site.all :order => :priority.asc
  @elements = Element.all :order => :priority.asc
  @blogs = Blog.all :order => :priority.asc


  erb :index
end

get '/adminlogin' do
  erb :adminlogin
end

get '/adminlogout' do
  session.clear
  redirect '/'
end

post "/adminlogin" do
  username = "username"
  password = "password"

    if (params[:username] == username) && (params[:password] == password)
      session[:admin] = true
      redirect "/admin"
    end
  "wrong password :/"
end

get '/site/:id' do

  content_type :json

  site = Array.new
  site << Site.get(params[:id].to_i).title
  site << Site.get(params[:id].to_i).content.gsub(/\n/, '<br>')

  json :site => site

end

get '/blog/:bid/post/:id' do

  content_type :json
  
  #p = Blog.first
  p = Post.get(params[:id].to_i,params[:bid].to_i)
  site = Array.new
  site << p.title
  site << p.content.gsub(/\n/, '<br>')

  json :blogpost => site

end

get '/admin' do
  @sites = Site.all :order => :priority.asc
  @elements = Element.all :order => :priority.asc
  @blogs = Blog.all :order => :priority.asc
  erb :admin
end


get '/admin/blog' do
  erb :blog
end


post '/admin/blog' do
  n = Blog.new
  n.title = params[:title]
  n.priority = Blog.count
  n.save
  redirect '/admin'
end

get '/admin/blog/:id' do
  @blog = Blog.get(params[:id].to_i)
  erb :editblog
end

put '/admin/blog/:id' do
  n = Blog.get(params[:id].to_i)
  n.title = params[:title]
  n.save
  redirect '/admin'
end

get '/admin/blog/:id/inc' do
  s = Blog.get(params[:id].to_i)
  new_priority = s.priority.to_i-1
  s.priority = new_priority
  s.save
  redirect '/admin'
end

get '/admin/blog/:id/dec' do
  s = Blog.get(params[:id].to_i)
  new_priority = s.priority.to_i+1
  s.priority = new_priority
  s.save
  redirect '/admin'
end

get '/admin/blog/:id/delete' do
  @blog = Blog.get(params[:id].to_i)
  erb :deleteblog
end

delete '/admin/blog/:id' do
  n = Blog.get(params[:id].to_i)
  n.destroy
  redirect '/admin'
end

get '/admin/blog/:id/post' do
  erb :blogpost
end


post '/admin/blog/:id/post' do
  b = Blog.get(params[:id].to_i)
  b.posts.new(:title => params[:title], :content => params[:content])
  b.save
  redirect "/admin/blog/#{params[:id]}"
end

get '/admin/blog/:bid/post/:id' do
  #blog = Blog.get(params[:bid].to_i)
  #@post = blog.comments.get(params[:id].to_i)
  #@post = Post.first(params[:id],params[:bid])
  @post = Post.get(params[:id].to_i,params[:bid].to_i)
  erb :editpost
end

put '/admin/blog/:bid/post/:id' do
  #post = Post.first(params[:id],params[:bid])
  post = Post.get(params[:id].to_i,params[:bid].to_i)
  post.title = params[:title]
  post.content = params[:content]
  post.save
  redirect "/admin/blog/#{params[:bid]}"
end

get '/admin/blog/:bid/post/:id/delete' do
  #@post = Post.first( params[:id],params[:bid])
  @post = Post.get(params[:id].to_i,params[:bid].to_i)
  erb :deleteblogpost
end

delete '/admin/blog/:bid/post/:id' do
  #n = Post.first(params[:id],params[:bid])
  n = Post.get(params[:id].to_i,params[:bid].to_i)
  n.destroy
  redirect "/admin/blog/#{params[:bid]}"
end


get '/admin/site' do
  erb :site
end


post '/admin/site' do
  n = Site.new
  n.content = params[:content]
  n.title = params[:title]
  n.priority = Site.count
  n.save
  redirect '/admin'
end

get '/admin/site/:id' do
  @site = Site.get(params[:id].to_i)
  erb :editsite
end

put '/admin/site/:id' do
  n = Site.get(params[:id].to_i)
  n.title = params[:title]
  n.content = params[:content]
  n.save
  redirect '/admin'
end

get '/admin/site/:id/inc' do
  s = Site.get(params[:id].to_i)
  new_priority = s.priority.to_i-1
  s.priority = new_priority
  s.save
  redirect '/admin'
end

get '/admin/site/:id/dec' do
  s = Site.get(params[:id].to_i)
  new_priority = s.priority.to_i+1
  s.priority = new_priority
  s.save
  redirect '/admin'
end

get '/admin/site/:id/delete' do
  @site = Site.get(params[:id].to_i)
  erb :deletesite
end

delete '/admin/site/:id' do
  n = Site.get(params[:id].to_i)
  n.destroy
  redirect '/admin'
end

get '/admin/element' do
  erb :element
end


post '/admin/element' do
  n = Element.new
  n.code = params[:code]
  n.title = params[:title]
  n.priority = Element.count
  n.save
  redirect '/admin'
end

get '/admin/element/:id' do
  @element = Element.get(params[:id].to_i)
  erb :editelement
end

put '/admin/element/:id' do
  n = Element.get(params[:id].to_i)
  n.title = params[:title]
  n.code = params[:code]
  n.save
  redirect '/admin'
end

get '/admin/element/:id/inc' do
  s = Element.get(params[:id].to_i)
  new_priority = s.priority.to_i-1
  s.priority = new_priority
  s.save
  redirect '/admin'
end

get '/admin/element/:id/dec' do
  s = Element.get(params[:id].to_i)
  new_priority = s.priority.to_i+1
  s.priority = new_priority
  s.save
  redirect '/admin'
end

get '/admin/element/:id/delete' do
  @element = Element.get(params[:id].to_i)
  erb :deleteelement
end

delete '/admin/element/:id' do
  n = Element.get(params[:id].to_i)
  n.destroy
  redirect '/admin'
end