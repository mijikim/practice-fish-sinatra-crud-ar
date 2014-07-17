require "sinatra"
require "gschool_database_connection"
# require "active_record"
require "rack-flash"
require_relative "lib/users_table"
require_relative "lib/fishes_table"


class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @users_table = UsersTable.new(
      GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
    )
    @fishes_table = FishesTable.new(
      GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
    )

  end

  get "/" do
    users = @users_table.users
    fishes = @fishes_table.fishes

    erb :root, :locals => {:users => users, :fishes => fishes}
  end

  get "/registration" do
    erb :registration
  end

  post "/registration" do
    if params[:username] == '' && params[:password] == ''
      flash[:registration] = "Please fill in username and password"
      redirect "/registration"
    elsif params[:password] == ''
      flash[:registration] = "Please fill in password"
      redirect "/registration"
    elsif params[:username] == ''
      flash[:registration] = "Please fill in username"
      redirect "/registration"
    else
      if @users_table.find_user(params[:username]) != []
        flash[:registration] = "Username is already in use, please choose another."
        redirect "/registration"
      end
      flash[:notice] = "Thank you for registering"
      @users_table.create(params[:username], params[:password])
      redirect "/"
    end
  end

  post "/login" do
    current_user = @users_table.find_user(params[:username]).first
    if current_user
    current_pass = @users_table.check_password(current_user["id"]).first.value
    end
    if current_user == nil
      flash[:not_logged_in] = "Incorrect username"
    elsif current_pass["password"] != params[:password]
      flash[:not_logged_in] = "Incorrect password"
    else
      session[:user_id] = current_user["id"]
      flash[:login] = "Welcome, #{params[:username].capitalize}"
    end
    redirect "/"
  end

  post "/sort" do
     if params[:order] == "asc"
      users = @users_table.users(params[:order])
    elsif params[:order] == "desc"
      users = @users_table.users(params[:order])
    end
    fishes = @fishes_table.fishes
    erb :root, :locals => {:users => users, :fishes => fishes}
  end


  get "/delete/:username_to_delete" do
    @users_table.delete_user(params[:username_to_delete].downcase)
    redirect "/"
  end

  get "/fishes/:users_fishes" do
    fishes = @fishes_table.find_by(params[:users_fishes])

    erb :users_fish, :locals => {:fishes => fishes}
  end

  post "/logout" do
    session[:user_id] = nil
    redirect "/"
  end

  get "/create_fish" do
    erb :create_fish
  end

  post "/create_fish" do
    @fishes_table.create(params[:fishname], params[:wikilink], session[:user_id])
    redirect "/"
  end

  post "/fish_list" do
    @fish = find_other_users_fish(params[:username])
    redirect back
  end

  private


  def find_other_users_fish(username)
    @database_connection.sql("select * from fish inner join users on fish.user_id = users.id where users.username = '#{username}'")
  end

end #end of class
