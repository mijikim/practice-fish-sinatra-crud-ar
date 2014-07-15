require "sinatra"
require "gschool_database_connection"
require "active_record"
require "rack-flash"


class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])

  end

  get "/" do
    @order_user_string = "SELECT username,id FROM users"
    if session[:user_id]
      puts "We still have a session id #{session[:id]}"
    end
    erb :root, :locals => {:send => @order_user_string}
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
    @order_user_string = "SELECT username,id FROM users"
    if session[:user_id]
      puts "We still have a session id #{session[:id]}"
    end
    if params[:order] == "asc"
      @order_user_string += " ORDER BY username ASC"
    elsif params[:order] == "desc"
      @order_user_string += " ORDER BY username DESC"
    end
    erb :root, :locals => {:send => @order_user_string}
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

  post "/delete" do
    delete_users(params[:delete_user])
    redirect "/"
  end

  post "/logout" do
    session[:user_id] = nil
    redirect "/"
  end

  post "/create_fish" do
    @database_connection.sql("insert into fish (name, url, user_id) values ('#{params[:fishname]}', '#{params[:wikilink]}', #{session[:user_id]})")
    redirect back
  end

  post "/fish_list" do
    @fish = find_other_users_fish(params[:username])
    p @fish
    redirect back
  end

  private

  def delete_users(user_id)
    @database_connection.sql("delete from users where id = '#{user_id}'")
  end

  def find_other_users_fish(username)
    @database_connection.sql("select * from fish inner join users on fish.user_id = users.id where users.username = '#{username}'")
  end

end #end of class
