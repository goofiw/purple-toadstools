# case 1: 
# 	if no open game
# 		create new game record > this user_id, this_users_selected_office
# case 2:
# 	if open game (game record with nil visitor id) && user.office_id == game.office_id
# 		add this_user_id to record, send_out_email/sound/notification w/ matched user and instructions
# 		 

get '/play' do
	@game = game_waiting
	if session[:office_id]  && !already_has_game?
		current_user_game = Game.find_by(user_id: session[:id]) 
		if !!@game && session[:id] != @game.user_id
	    @game.visitor_id = session[:id]
	    puts "need to send out a notification"
		else
			@game = Game.new(office_id: session[:office_id],
				               user_id: session[:id],
	                     visitor_id: 0,
	                     timeout: 900
				               )
			puts "Creating a new Game"
		end
				@game.save
				redirect '/'
	else
		if !session[:office_id]
			@game.errors.add(:no_office, "Must select office to FOOS!")
		elsif already_has_game?
			@game.errors.add(:already_waiting, 
				               "You're already waiting for a game in your office")
		end
		erb :index
	end
end

def game_waiting
  Game.find_by(visitor_id: 0, office_id: session[:office_id])
end

def already_has_game?
	!!Game.find_by(user_id: session[:id], office_id: session[:office_id])
end