# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

restaurants_table = DB.from(:restaurants)
rsvps_table = DB.from(:rsvps)
users_table = DB.from(:users)
reviews_table = DB.from(:reviews)



before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts "params: #{params}"

    pp restaurants_table.all.to_a
    @restaurants = restaurants_table.all.to_a
    view "restaurants"
end

get "/restaurants/:id" do
    puts "params: #{params}"

    # @users_table = users_table
    @restaurant = restaurants_table.where(id: params[:id]).to_a[0]
    @review = reviews_table.where(restaurant_id: @restaurant[:id]).to_a
    @average = reviews_table.where(restaurant_id: @restaurant[:id]).avg(:scores)
    @lat_long = "#{@restaurant[:lat]},#{@restaurant[:long]}"
    @google = ENV["GoogleAPI"]
    view "restaurant"
end

post "/restaurants/:id/rsvps/create" do
    puts "params: #{params}"

    # first find the event that rsvp'ing for
    @restaurant = restaurants_table.where(id: params[:id]).to_a[0]
    # next we want to insert a row in the rsvps table with the rsvp form data
    rsvps_table.insert(
        restaurant_id: @restaurant[:id],
        user_id: session["user_id"],
        date: params["date"],
        time: params["Time"],
        number_of_ppl: params["#people"],
        comments: params["comments"]
    )

    accout_sid = ENV["TWILIO_ACCOUNT_SID"]
    auth_token = ENV["TWILIO_AUTH"]
    client = Twilio::REST::Client.new(account_sid, auth_token)

    client.messages.create(
    from: "+12056515499", 
    to: @current_user[:phone_number],
    body: "Your booking details:"
    )

    redirect "/restaurants/#{@restaurant[:id]}"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts "params: #{params}"


    # if there's already a user with this email, skip!
    existing_user = users_table.where(email: params["email"]).to_a[0]
    if existing_user
        view "error"
    else
    users_table.insert(
        name: params["name"],
        phone_number: params["phone"],
        email: params["email"],
        password: BCrypt::Password.create(params["password"])

    )
        redirect "/logins/new"
    end
    view "create_user"
end

get "/logins/new" do


    view "new_login"
end

post "/logins/create" do
    puts "params: #{params}"

    # step 1: user with the params["email"] ?
    @user = users_table.where(email: params["email"]).to_a[0]

    if @user
        # step 2: if @user, does the encrypted password match?
        if BCrypt::Password.new(@user[:password]) == params["password"]
            # set encrypted cookie for logged in user
            session["user_id"] = @user[:id]
            redirect "/"
        else
            view "create_login_failed"
        end
    else
        view "create_login_failed"
    end
end

get "/logout" do
    # remove encrypted cookie for logged out user
    session["user_id"] = nil
    redirect "/logins/new"
end

get "/restaurants/:id/writeareview/new" do
    puts "params: #{params}"

    # @users_table = users_table
    @restaurant = restaurants_table.where(id: params[:id]).to_a[0]

    view "writeareview"
end

post "/restaurants/:id/writeareview/create" do
    puts "params: #{params}"

    # first find the event that rsvp'ing for
    @restaurant = restaurants_table.where(id: params[:id]).to_a[0]
    # next we want to insert a row in the rsvps table with the rsvp form data
    reviews_table.insert(
        restaurant_id: @restaurant[:id],
        user_id: session["user_id"],
        scores: params["exampleRadios"],
        comments: params["comments"]
    )

    redirect "/restaurants/#{@restaurant[:id]}"
end