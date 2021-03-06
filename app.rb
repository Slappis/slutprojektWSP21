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

get('/home') do
    slim(:home)
end

post('/user/new') do
    # Från register.slim formuläret
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
  
    if (password == password_confirm)
      #Lägg till användare
      password_digest = BCrypt::Password.create(password)
      db.execute("INSERT INTO users (username,password) VALUES (?,?)",username,password_digest)
      redirect('/')
  
    else
      #Felhantering
      "Lösenorden matchade inte"
    end
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db.results_as_hash = true
  
    allUsers = db.execute("SELECT username FROM users")
  
    if allUsers.include?({"username" => username})
        result = db.execute("SELECT * FROM Users WHERE username = ?",username).first
        pwdigest = result["password"]
        id = result["userID"]
  
        if BCrypt::Password.new(pwdigest) == password
            session[:id] = id
            redirect('/home')
         
        else
            "Fel Lösenord" 
        end
  
    else
        "Användarnamnet existerar inte"
    end
end

get('/items') do
    db.results_as_hash = true
    result = db.execute("SELECT * FROM itemPool")
    slim(:"items", locals:{items:result})
end

get('/builds') do
    id = session[:id].to_i
    db.results_as_hash = true
    result = db.execute("SELECT * FROM buildContent WHERE creatorId = ?", id)
    items = db.execute("SELECT * FROM itemPool")
    slim(:"builds", locals:{content:result, items:items})
end

