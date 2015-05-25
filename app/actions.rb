require_relative 'twilio_helper'
require_relative 'user_authentication'
require_relative 'play_button'
require_relative 'office_creation'

# Homepage (Root path)

helpers do
	
	def all_offices
		Office.all
	end

	def all_games
		Game.all
	end

  def all_user_offices
    #should scrub session[:id]
    Office.find_by_sql("SELECT * FROM offices
                  JOIN offices_users
                  ON offices.id=offices_users.office_id
                  WHERE user_id = #{session[:id]}")
  end

  def active_games
    Game.find_by_sql("SELECT * FROM games
                      WHERE visitor_id = 0")
    # User.find(home_player)
  end

  def your_recent_matches
    games = Game.find_by_sql("SELECT * FROM games
                      WHERE user_id = #{session[:id]}
                      AND matched_at IS NOT NULL")
    recent_games = []
    
    games.each do |game| 
      puts (game.matched_at - Time.now)
      if game.matched_at
        recent_games << game if (Time.now - game.matched_at).to_i < 300
      end
    end

    recent_games
  end

  def get_office_mod_name(office)
    User.find(office.mod[:user_id]).username
  end

  def get_office_contact_email(office)
    User.find(office.mod[:user_id]).email
  end

end

get '/matched' do
  puts Time.now.to_i
  games = your_recent_matches
  puts games
  erb :_matched, layout:false if !games.empty? #if your game#matched
  #game#matched = false
end

get '/game_list' do
  erb :_active_game_list, layout: false
end

get '/' do
  @user = User.new
  erb :index, :layout => (request.xhr? ? false : :layout)
end

get '/office/:id' do
  session[:office_id] = params[:id]
  session[:office_name] = Office.find(params[:id]).name
  session[:company_name] = Office.find(params[:id]).company_name

  redirect '/#intro'
end

get '/game/destroy/:id' do
  #should delete the game with id params[:id]
  Game.find(params[:id]).destroy
  redirect '/#games'
end