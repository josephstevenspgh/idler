function init_pausemenu()
	gamepaused = true
	pausestate = -1
	menuposx = 0
	menuposy = 0
end

function pause_logic()
	if pausestate == -1 then
		--menu select
		menu_controls(0, 6)
		if action_button.justpressed then
			--enter menu
			pausestate = menuposy
			menuposy = 0
			menuposx = 0
			optionsstate = 0
		end
		if cancel_button.justpressed then
			gamepaused = false
		end
	elseif pausestate == 0 then
		--no status allowed
		pausestate = -1
	elseif pausestate == 1 then
		--item menu
		menu_controls(2, 4)
		if action_button.justpressed then
			--use item
			if sp_player.itemsowned[1+menuposy+menuposx*4] > 0 then
				sp_player.itemsowned[1+menuposy+menuposx*4] = sp_player.itemsowned[1+menuposy+menuposx*4] - 1
			else
				--error
			end
		end
		if cancel_button.justpressed then
			pausestate = -1
			menuposx = 0
			menuposy = 1
		end
	elseif pausestate == 2 then
		--equip screen
		menu_controls(8, 4)
		if action_button.justpressed then
			--equip/remove item
			if menuposy == 0 then
				--swords
				if sp_player.swordequipped == menuposx+1 then
					sp_player.swordequipped = 0
				else
					if sp_player.swordsowned[menuposx+1] then
						sp_player.swordequipped = menuposx+1
					end
				end
			elseif menuposy == 1 then
				--armor
				if sp_player.armorequipped == menuposx+1 then
					sp_player.armorequipped = 0
				else
					if sp_player.armorsowned[menuposx+1] then
						sp_player.armorequipped = menuposx+1
					end
				end
			elseif menuposy == 2 then
				--shield
				if sp_player.shieldequipped == menuposx+1 then
					sp_player.shieldequipped = 0
				else
					if sp_player.shieldsowned[menuposx+1] then
						sp_player.shieldequipped = menuposx+1
					end
				end
			elseif menuposy == 3 then
				--ring
				if sp_player.ringequipped == menuposx+1 then
					sp_player.ringequipped = 0
				else
					if sp_player.ringsowned[menuposx+1] then
						sp_player.ringequipped = menuposx+1
					end
				end
			end
		end
		if cancel_button.justpressed then
			pausestate = -1
			menuposx = 0
			menuposy = 2
		end
	elseif pausestate == 3 then
		--ability screen
		menu_controls(0,6)
		if action_button.justpressed then
			--change ability
			if menuposy+1 == sp_player.currentability then
				sp_player.currentability = 0
			else
				if sp_player.abilitieslearned[menuposy+1] then
					sp_player.currentability = menuposy+1
				end
			end
		end
		if cancel_button.justpressed then
			pausestate = -1
			menuposx = 0
			menuposy = 3
		end
	elseif pausestate == 4 then
		--config screen options
		if optionsstate == 0 then
			menu_controls(0, 6)
			if action_button.justpressed then
				if menuposy == 0 then
					--set up controls
					optionsstate = 1
					joysticks = get_joysticks()
					currentbutton = 1
				elseif menuposy == 1 then
					--adjust text speed
					optionsstate = 2
				elseif menuposy == 2 then
					--music volume
					optionsstate = 3
				elseif menuposy == 3 then
					--sfx volume
					optionsstate = 4
				elseif menuposy == 4 then
					--default settings
					textspeed = 4
					musiclevel = 4
					sfxlevel = 4
				elseif menuposy == 5 then
					--title screen
					init_titlescreen()
					gamestate = gamestate_title
				end
			end
			if cancel_button.justpressed then
				pausestate = -1
				menuposx = 0
				menuposy = 4
			end
		elseif optionsstate == 1 then
			--show button config
			--poll for gamepad inputs
			for i=1,#joysticks do
				--check axis first
				--[[
				local acount = joysticks[i]:getAxisCount()
				if acount > 0 then
					for j=1,acount do
						--log("axis "..j..": "..joysticks[i]:getAxis(j))
					end
				end
				--now hats
				local hcount = joysticks[i]:getHatCount()
				if hcount > 0 then
					for j=1,hcount do
						log("hat: "..j..": "..joysticks[i]:getHat(j))
						if joysticks[i]:getHat(j) ~= "c" then
							--direction pressed
						end
					end
				end]]
				--now buttons
				local bcount = joysticks[i]:getButtonCount()
				if bcount > 0 then
					for j=1,bcount do
						if joysticks[i]:isDown(j) then
							log("button "..j..": down")
						else
							log("button "..j..": up")
						end
					end
				end
			end
		elseif optionsstate == 2 then
			--text speed
			menu_controls(8, 0)
			if action_button.justpressed then
				textspeed = menuposx+1
				optionsstate = 0
				menuposy = 1
			end
			if cancel_button.justpressed then
				optionsstate = 0
				menuposy = 1
			end
		elseif optionsstate == 3 then
			--bgm volume
			menu_controls(8, 0)
			if action_button.justpressed then
				musiclevel = menuposx+1
				optionsstate = 0
				menuposy = 2
			end
			if cancel_button.justpressed then
				optionsstate = 0
				menuposy = 2
			end
		elseif optionsstate == 4 then
			--sfx volume
			menu_controls(8, 0)
			if action_button.justpressed then
				sfxlevel = menuposx+1
				optionsstate = 0
				menuposy = 3
			end
			if cancel_button.justpressed then
				optionsstate = 0
				menuposy = 3
			end
		end
	elseif pausestate == 5 then
		--save the game
		savegame(1)
		pausestate = -1
	end
	if pause_button.justpressed then
		gamepaused = false
	end
end


function draw_pausemenu()
	sidebarbg = init_textbox_art(8, 8)
	portraitbg = init_textbox_art(7, 7)
	mainbg = init_textbox_art(24, 18)
	love.graphics.draw(portraitbg, 16, 12)
	love.graphics.draw(sidebarbg, 12, 92)
	love.graphics.draw(mainbg, 100, 12)
	local sx = 24
	local sy = 20
	local portraitart = sprite_init("", gfx_portraits, 56, 56, {0, 0, 0, 0})
	portraitart.x = sx
	portraitart.y = sy
	if sp_player.class == "warrior" then
		portraitart.currentframe = 1
	elseif sp_player.class == "thief" then
		portraitart.currentframe = 2
	end
	sprite_draw(portraitart)
	sx = 24
	sy = 102
	love.graphics.print("stats", sx, sy)
	love.graphics.print("items", sx, sy+10)
	love.graphics.print("equip", sx, sy+20)
	love.graphics.print("ability", sx, sy+30)
	love.graphics.print("config", sx, sy+40)
	love.graphics.print("save", sx, sy+50)
	local mx = 108
	local my = 20
	if pausestate == -1 then
		--selecting menu
		draw_cursor(sx-8, sy+menuposy*10)
		if menuposy == 0 then
			pausemenu_showstats(mx, my)
		elseif menuposy == 1 then
			pausemenu_showitems(mx, my)
		elseif menuposy == 2 then
			pausemenu_showequip(mx, my)
		elseif menuposy == 3 then
			pausemenu_showabilities(mx, my)
		elseif menuposy == 4 then
			pausemenu_showoptions(mx, my)
		elseif menuposy == 5 then
			pausemenu_showsave(mx, my)
		end
	elseif pausestate == 0 then
		pausemenu_showstats(mx, my)
	elseif pausestate == 1 then
		pausemenu_showitems(mx, my)
		draw_cursor(mx-8+menuposx*90, my+24+menuposy*20)
		if sp_player.itemsowned[menuposx*4+menuposy+1] > 0 then
			lprint(items[menuposx*4+menuposy+1].description, mx, my+10)
		end
	elseif pausestate == 2 then
		pausemenu_showequip(mx, my)
		draw_cursor(mx-8+menuposx*25, my+34+menuposy*30)
	elseif pausestate == 3 then
		pausemenu_showabilities(mx, my)
		draw_cursor(mx-8+menuposx, my+24+menuposy*20)
	elseif pausestate == 4 then
		pausemenu_showoptions(mx, my)
		if optionsstate == 0 then
			draw_cursor(mx-8, my+20+menuposy*20)
		elseif optionsstate == 2 then
			draw_cursor(mx+menuposx*16, my+50)
		elseif optionsstate == 3 then
			draw_cursor(mx+menuposx*16, my+70)
		elseif optionsstate == 4 then
			draw_cursor(mx+menuposx*16, my+90)
		end
	end
end

function pausemenu_showabilities(mx, my)
	love.graphics.print("abilities", mx, my)
	local abilitystrings = {"cut\nvery sharp",
							"burn\nburns them all",
							"bomb\nwalls have no chance",
							"poison\npoisons enemies",
							"warp\nreturn home",
							"test",
							"test2",
							"test3"}
	for i=1,6 do
		if sp_player.abilitieslearned[i] then
			showicon(i, mx, my+20*i, "ability")
			lprint(abilitystrings[i], mx+20, my+20*i)
		else
			showicon(0, mx, my+20*i, "ability")
		end
	end
	--highlight equipped ability
	if sp_player.currentability > 0 then
		love.graphics.setColor(255, 255, 255, 50)
		love.graphics.rectangle("fill", mx, my+20*sp_player.currentability, 16, 16)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function pausemenu_showoptions(mx, my)
	love.graphics.print("options", mx, my)
	lprint("gamepad controls", mx, my+20)
	lprint("text speed", mx, my+40)
	lprint(" 1 2 3 4 5 6 7 8", mx, my+50)
	lprint("music level", mx, my+60)
	lprint(" 1 2 3 4 5 6 7 8", mx, my+70)
	lprint("sound effect level", mx, my+80)
	lprint(" 1 2 3 4 5 6 7 8", mx, my+90)
	lprint("default options", mx, my+100)
	lprint("(wont clear gamepad)", mx, my+110)
	lprint("exit to title", mx, my+120)
	draw_cursor(mx-15+textspeed*16, my+50)
	draw_cursor(mx-15+musiclevel*16, my+70)
	draw_cursor(mx-15+sfxlevel*16, my+90)
	if optionsstate == 1 then
		configbg = init_textbox_art(14, 2)
		love.graphics.draw(configbg, 32, 32)
		lprint("press a button twice in a\nrow to set it. all buttons\nwill go through in order.", 40, 40)
		lprint("current button: "..buttonnames[currentbutton], 40, 70)
	end
end

function pausemenu_showsave(mx, my)
	--show save data
	love.graphics.print("saving not implemented", mx, my)
end

function pausemenu_showequip(mx, my)
	love.graphics.print("equipment", mx, my)
	love.graphics.print("sword", mx, my+20)
	show_equiprow(sp_player.swordsowned, mx-25, my+30, "weapon")
	love.graphics.print("armor", mx, my+50)
	show_equiprow(sp_player.armorsowned, mx-25, my+60, "armor")
	love.graphics.print("shield", mx, my+80)
	show_equiprow(sp_player.shieldsowned, mx-25, my+90, "shield")
	love.graphics.print("ring", mx, my+110)
	show_equiprow(sp_player.ringsowned, mx-25, my+120, "ring")
	love.graphics.setColor(255, 255, 255, 50)
	if sp_player.swordequipped > 0 then
		love.graphics.rectangle("fill", mx-25+25*sp_player.swordequipped, my+30, 16, 16)
	end
	if sp_player.armorequipped > 0 then
		love.graphics.rectangle("fill", mx-25+25*sp_player.armorequipped, my+60, 16, 16)
	end
	if sp_player.shieldequipped > 0 then
		love.graphics.rectangle("fill", mx-25+25*sp_player.shieldequipped, my+90, 16, 16)
	end
	if sp_player.ringequipped > 0 then
		love.graphics.rectangle("fill", mx-25+25*sp_player.ringequipped, my+120, 16, 16)
	end
	love.graphics.setColor(255, 255, 255, 255)
	--draw name
	if pausestate == 2 then
		if menuposy == 0 then
			if sp_player.swordsowned[menuposx+1] then
				--val = val + items[8+sprite.swordequipped].power
				lprint(items[8+menuposx+1].name, mx+100, my)
				lprint(items[8+menuposx+1].description, mx, my+10)
			end
		elseif menuposy == 1 then
			if sp_player.armorsowned[menuposx+1] then
				lprint(items[24+menuposx+1].name, mx+100, my)
				lprint(items[24+menuposx+1].description, mx, my+10)
			end
		elseif menuposy == 2 then
			if sp_player.shieldsowned[menuposx+1] then
				lprint(items[16+menuposx+1].name, mx+100, my)
				lprint(items[16+menuposx+1].description, mx, my+10)
			end
		elseif menuposy == 3 then
			if sp_player.ringsowned[menuposx+1] then
				lprint(items[32+menuposx+1].name, mx+100, my)
				lprint(items[32+menuposx+1].description, mx, my+10)
			end
		end
	end
end

function show_equiprow(equiptype, x, y, t)
	for i=1,8 do
		if equiptype[i] then
			showicon(i, x+25*i, y, t)
		else
			showicon(0, x+25*i, y)
		end
	end	
end

function pausemenu_showstats(mx, my)
	love.graphics.print("stats", mx, my)
	love.graphics.print("level: "..sp_player.level, mx, my+20)
	love.graphics.print("experience: "..sp_player.exp.."/"..sp_player.exptable[sp_player.level], mx, my+30)
	showicon(1, mx, my+40)
	love.graphics.print(get_playerstat(sp_player, "attack"), mx+20, my+44)
	showicon(2, mx+40, my+40)
	love.graphics.print(get_playerstat(sp_player, "defence"), mx+60, my+44)
	showicon(3, mx+80, my+40)
	love.graphics.print(get_playerstat(sp_player, "agility"), mx+100, my+44)
	showicon(4, mx+120, my+40)
	love.graphics.print(sp_player.gold, mx+140, my+44)
	love.graphics.print("equipment", mx, my+90)
	showicon(sp_player.swordequipped, mx, my+104, "weapon")
	love.graphics.print("sword", mx+20, my+108)
	showicon(sp_player.shieldequipped, mx, my+124, "shield")
	love.graphics.print("shield", mx+20, my+128)
	showicon(sp_player.armorequipped, mx+100, my+104, "armor")
	love.graphics.print("armor", mx+120, my+108)
	showicon(sp_player.ringequipped, mx+100, my+124, "ring")
	love.graphics.print("ring", mx+120, my+128)
end

function pausemenu_showitems(mx, my)
	love.graphics.print("items", mx, my)
	for i=1,4 do
		if sp_player.itemsowned[i] > 0 then
			showicon(i, mx, my+20*i, "item")
			lprint("x"..sp_player.itemsowned[i], mx+20, my+20*i)
			lprint(items[i].name, mx+20, my+10+20*i)
		else
			showicon(0, mx, my+20*i)
		end
		if sp_player.itemsowned[i+4] > 0 then
			showicon(i+4, mx+90, my+20*i, "item")
			lprint("x"..sp_player.itemsowned[i+4], mx+110, my+20*i)
			lprint(items[i+4].name, mx+110, my+10+20*i)
		else
			showicon(0, mx+90, my+20*i)
		end
	end
	love.graphics.print("key items", mx, my+100)
	--push ability
	if sp_player.canpush then
		showicon(1, mx, my+110)
		lprint("gloves", mx+20, my+114)
	else
		showicon(0, mx, my+110)
	end

	--climbing hooks
	if sp_player.hooks then
		showicon(1, mx+90, my+110)
		lprint("hooks", mx+110, my+114)
	else
		showicon(0, mx+90, my+110)
	end

	--swimming
	if sp_player.canswim then
		showicon(1, mx, my+130)
		lprint("swim", mx+20, my+130)
	else
		showicon(0, mx, my+130)
	end

	--jumping
	if sp_player.canjump then
		showicon(1, mx+90, my+130)
		lprint("jump", mx+110, my+130)
	else
		showicon(0, mx+90, my+130)
	end
end