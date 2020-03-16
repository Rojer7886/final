# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :restaurants do
  primary_key :id
  String :name
  String :description, text: true
  String :contact
  String :address
  String :website
  String :lat
  String :long
end
DB.create_table! :rsvps do
  primary_key :id
  foreign_key :restaurant_id
  foreign_key :user_id
  String :date
  String :time
  Integer :number_of_ppl
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :phone_number
  String :email
  String :password
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :restaurant_id
  foreign_key :user_id
  Float :scores
  String :comments
end

# Insert initial (seed) data
restaurants_table = DB.from(:restaurants)
users_table = DB.from(:users)
reviews_table = DB.from(:reviews)

restaurants_table.insert(name: "Peppercorns", 
                    description: "Peppercorns Kitchen is a chef-driven contemporary Chinese restaurant located at Evanston, IL. Our mission is to deliver a brand-new culinary experience mixing authentic Szechuan cuisine and creative American-Chinese fusion.",
                    contact: "(847) 563-8461",
                    address: "620 Davis St Peppercorns Kitchen, Evanston, IL  60201 USA",
                    website: "https://peppercornskitchen.com/",
                    lat: "42.046751", 
                    long: "-87.680503")

restaurants_table.insert(name: "Red Hot Chilli Pepper", 
                    description: "We are part of the highly acclaimed and hugely popular “Red Hot Chilli Pepper Group” based in Kolkata, India.
Aptly named “Red Hot Chilli Pepper”, we take inspiration from the vibrant flavors of Asia, using fresh produce, meat, seafood and poultry with the aim to provide you with an exceptional dining experience!",
                    contact: "(847) 563-8085",
                    address: "500 Davis St, Evanston, IL 60201, USA",
                    website: "http://rhcponline.com/",
                    lat: "42.046023",
                    long: "-87.678719")

reviews_table.insert(restaurant_id: "1",
                    user_id: "1",
                    scores: "4",
                    comments: "very cool!")

reviews_table.insert(restaurant_id: "2",
                    user_id: "1",
                    scores: "3",
                    comments: "I like it!")



