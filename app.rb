require "sinatra"
require "active_record"
require "rack-flash"
require "./lib/database_connection"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    if session[:user_id]
      puts "We still have a session id #{session[:id]}"
    end
    erb :root
  end

  get "/registration" do
    erb :registration
  end

  post "/registration" do
    if params[:username] == '' && params[:password] == ''
      flash[:notice] = "Please fill in username and password"
      redirect "/registration"
    elsif params[:password] == ''
      flash[:notice] = "Please fill in password"
      redirect "/registration"
    elsif params[:username] == ''
      flash[:notice] = "Please fill in username"
      redirect "/registration"
    else
      if @database_connection.sql("SELECT id FROM users WHERE username = '#{params[:username]}'") != []
        flash[:notice] = "Username is already in use, please choose another."
        redirect "/registration"
      end
      flash[:notice] = "Thank you for registering"
      @database_connection.sql("INSERT INTO users (username, password) VALUES ('#{params[:username]}', '#{params[:password]}')")
      redirect "/"
    end
  end

  post "/sort" do
    if order == asc
      p "==-=-=-=-"
      suffix = "ORDER BY username ASC"
    elsif order == desc
      p ">>>"
      suffix = "ORDER BY username DESC"
    end
    redirect "/"
  end

  post "/sort?order=asc" do
    p ".,.,..,.,.>>><><"
  end


  post "/login" do
    current_user = @database_connection.sql("SELECT * FROM users WHERE username='#{params[:username]}' AND password='#{params[:password]}';").first
    puts "user is #{current_user["username"]}"
    session[:user_id] = current_user["id"]
    # p "the session id is #{session[:user_id]}"
    flash[:not_logged_in] = true
    flash[:notice] = "Welcome, #{params[:username]}"
    redirect "/"
  end

  post "/logout" do
    session[:user_id] = nil
    redirect "/"
  end
end #end of class