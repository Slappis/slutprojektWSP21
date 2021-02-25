require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
db = SQLite3::Database.new('db/WSP21slutprojekt.db')

get('/') do
    slim(:register)
end

get('/showlogin') do
    slim(:login)
end

post('/user/new') do
    # Från register.slim formuläret
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if (password == password_confirm)
      #Lägg till användare
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/WSP21slutprojekt.db')
      db.execute("INSERT INTO users (username,password) VALUES (?,?)",username,password_digest)
      redirect('/')
  
    else
      #Felhantering
      "Lösenorden matchade inte"
    end
  end