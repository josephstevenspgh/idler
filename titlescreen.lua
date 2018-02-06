function init_titlescreen()
	titlestate = 0
	titletimer = 0
	mx = 100
	my = 90
	sp_war = player_init(mx+60, my+10, "warrior")
	sp_thief = player_init(mx+60, my+40, "thief")
	sprite_setanimation(sp_war, "walk left")
	sprite_setanimation(sp_thief, "walk left")
end

function draw_titlescreen()
	if titletimer % 2 == 0 then
		love.graphics.setColor(30, 10, 50, 75)
		love.graphics.rectangle("fill",0, 0, screen.width, screen.height)
		love.graphics.setColor(255, 255, 255, 255)
	end
	lprint("Dirty Bumper", 100, 30)
	lprint("- a game by setz -", 70, 50)
	lprint("follow the development!\ntwitter.com/splixel", 2, screen.height-20)
	if titlestate == 0 then
		lprint("new game", mx, my)
		lprint("load game", mx, my+10)
		draw_cursor(mx-10, my+menuposy*10)
	elseif titlestate == 1 then
		lprint("choose a class", mx, my)
		lprint("warrior", mx, my+20)
		sprite_playanimation(sp_war)
		sprite_playanimation(sp_thief)
		sprite_draw(sp_war)
		sprite_draw(sp_thief)
		lprint("thief", mx, my+50)
		draw_cursor(mx-10, my+20+30*menuposy)
	end
end

function update_titlescreen()
	titletimer = titletimer + 1
	if titletimer > 10000 then
		titletimer = 0
	end

	if titlestate == 0 then
		menu_controls(0,2)
		if action_button.justpressed then
			if menuposy == 0 then
				--select class
				titlestate = 1
			elseif menuposy == 1 then
				--load game
				loadgame(1)
			end
		end
	elseif titlestate == 1 then
		menu_controls(0,2)
		if action_button.justpressed then
			if menuposy == 0 then
				--warrior
				new_game("warrior")
			elseif menuposy == 1 then
				--thief
				new_game("thief")
			end
		end
		if cancel_button.justpressed then
			titlestate = 0
			menuposy = 0
			menuposx = 0
		end
	end

	--quit game
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
end