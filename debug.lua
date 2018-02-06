log("hi")
function init_ingame()
	--main state
	gamepaused = false
	pausestate = 0
	dolevelup = false
	--sprites	
	fadetimer = 0
	gameactive = true
	--current map
   	currentmap = {}
   	currenttilemap = {}
   	currentcollision = {}
   	npcgroup = {}
   	drawgroup = {}
   	decaytext = {}
   	--quest flags
   	quest = {}
   	quest["lookforboy"] = false
   	quest["boyfound"] = false
   	quest["toldmom"] = false
   	quest["lookforprincess"] = false
   	--pickupables
   	pickupable_pickedup = {}
   	for i=1,1000 do
   		pickupable_pickedup[i] = false
   	end
end

function draw_parallax(img, xscale, yscale)
	local cx = sp_player.x - screen.width/2
	local cy = sp_player.y - screen.height/2
	--bounds
	if cx < 0 then cx = 0 end
	if cy < 0 then cy = 0 end
	if cx > currentmap.width - screen.width then cx = currentmap.width - screen.width end
	if cy > currentmap.height - screen.height then cy = currentmap.height - screen.height end

	love.graphics.translate(-math.floor(cx/xscale), -math.floor(cy/yscale))
	love.graphics.draw(img, 0, 0)
	love.graphics.origin()	
end

function draw_ingame()
	--draw_parallax(gfx_bg_mountains, 32, 4)
	--sort by y position
	table.sort(npcgroup, function(a,b) return sprite_getbottom(a)<sprite_getbottom(b) end)
	local playerdrawn = false
	camera_center(sp_player)
	love.graphics.draw(mapbatch)
	--draw enemy group
	for i=1,#npcgroup do
		if npcgroup[i].state ~= 200 then
			if not playerdrawn and sprite_getbottom(sp_player) < sprite_getbottom(npcgroup[i]) then
				playerdrawn = true
				draw_player()
			end
			if gameactive then
				sprite_playanimation(npcgroup[i])
			end
			sprite_draw(npcgroup[i])
			sprite_drawhealthbar(npcgroup[i])
			sprite_drawhitbox(npcgroup[i])
		end
	end
	if not playerdrawn then
		draw_player()
	end
	--damage numbers
	for i=#decaytext,1,-1 do

		smoothscale(decaytext[i])
		local alpha = 255 - (decaytext[i].timer/60) * 255
		love.graphics.setColor(255,255,255,alpha)
		sprite_draw(decaytext[i])
		decaytext[i].y = decaytext[i].y - .5
		decaytext[i].timer = decaytext[i].timer + 1
		if decaytext[i].timer >= 60 then
			table.remove(decaytext, i)
			i = i - 1
			dnum = i - 1
		end
	end

	love.graphics.origin()
	--hud
	love.graphics.draw(gfx_hud, 0, 0)

   	love.graphics.setFont(font_hud)
	love.graphics.print("hp: "..sp_player.hp, 26, 4)
	--sp_player.exp > sp_player.exptable[sp_player.level] then
	local expcent = math.floor((sp_player.exp/sp_player.exptable[sp_player.level])*100)
	love.graphics.print("exp: "..expcent.."%", 29, 22)
   	love.graphics.setFont(font_classic)
	--ability cooldown display
	showicon(sp_player.currentability, 4, 5, "ability")

	if sp_player.cooldown > 0 then
		love.graphics.setColor(0, 0, 0, 200)
		local sy = 5+16
		local sh = 0
		sy = sy - (sp_player.cooldown/sp_player.maxcooldown)*16
		sh = sh + (sp_player.cooldown/sp_player.maxcooldown)*16
		love.graphics.rectangle("fill", 4, sy, 16, sh)
		love.graphics.setColor(255, 255, 255, 255)
	end

	if gamepaused then
		draw_pausemenu()
	end
	if shopopen then
		draw_shop()
	end
	if dolevelup then
		--show level up menu
		local sx = 30
		local sy = 30
		local sw = screen.width-sx*2
		local sh = screen.height-sy*2
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle("fill", sx, sy, sw, sh)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("level up!", sx+4, sy+4)
		love.graphics.print("increase a stat", sx+4, sy+14)
		love.graphics.print("strength\nagility\ndefence", sx+14, sy+40)
		love.graphics.print(">", sx+4, sy+40+menuposy*8)
		lprint("you've gained a new ability!", sx+4, sy+80)
		if sp_player.level == 1 then
			lprint("cut - you can now cut\ndown trees", sx+8, sx+90)
		end
	elseif talking then
		--show textbox
		local sx = screen.width - (2+textbox.width)*8
		sx = sx/2
		local sy = 32
		local sw = screen.width-sx*2
		local sh = screen.height-sy*2
		love.graphics.draw(textbox.bg, sx, sy)
		love.graphics.print(textbox.displaytext, sx+8, sy+8)
		--questions
		if textbox_question then
			sx = sx + textbox.width*8 - questionbox.width*8
			sy = sy + (textbox.height+3)*8
			love.graphics.draw(questionbox.bg, sx, sy)
			lprint(questionbox.text, sx+8, sy+8)
			if string.len(textbox.text) == string.len(textbox.displaytext) then
				lprint(">", sx+16, sy+16+menuposy*8)
			end
		end
	end

	--fadeout
	if fadetimer > 0 then
		local alph = (fadetimer/40) * 255
		love.graphics.setColor(0, 0, 0, alph)
		love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)
		love.graphics.setColor(255, 255, 255, 255)
	end

	--debug
	love.graphics.print("x: "..sp_player.x.." y: "..sp_player.y)
	--love.graphics.print("FPS: "..love.timer.getFPS().." delta: "..love.timer.getDelta())
	if sp_player.pushing then
		love.graphics.print("pushing", 1, 20)
	end
	if sp_player.climbing then
		love.graphics.print("climbing", 1, 30)
	end
end

function update_ingame()
	gameactive = false
	if shopopen then
		shop_update()
	elseif gamepaused then
		pause_logic()
	elseif talking then
		textbox_logic()
	elseif dolevelup then
		--level up menu
		menu_controls(0, 3)
		if action_button.justpressed then
			levelup_gainstats(sp_player, menuposy)
		end
	elseif fadetimer > 0 then
		fadetimer = fadetimer - 1
	else
		gameactive = true
		player_controls(sp_player)
		enemy_ai()
		player_enemy_behavior()
	end
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	--[[enemy spawner
	if #npcgroup < 3 then
		table.insert(npcgroup, slime_init(60, 230))		
	end]]
	--remove dead enemies
	for i=#npcgroup,1,-1 do
		if npcgroup[i].state == 200 then
			table.remove(npcgroup, i)
		end
	end
end

function draw_player()
	if gameactive and not sp_player.climbing then
		sprite_playanimation(sp_player)
	end
	playerdrawn = true
	sprite_draw(sp_player)
	sprite_drawhealthbar(sp_player)
	--sprite_drawhitbox(sp_player)
	if cantakeaction(sp_player) then
		lprint("!", sp_player.x, sp_player.y)
	end
end

function make_damage_num(sprite, damage, color)
	local numart = love.graphics.newCanvas(40,8)
	love.graphics.setCanvas(numart)

   	love.graphics.setFont(font_damage)
   	if color then
   		love.graphics.setColor(color)
   	end
	love.graphics.print("-"..damage, 0, 0)
	love.graphics.setColor(255, 255, 255, 255)
   	love.graphics.setFont(font_classic)
	local tempart = love.graphics.newImage(numart:getImageData())
	local dsprite = sprite_init("damage number", tempart, 40, 8, {0, 0, 0, 0})

	--local dsprite = sprite_init("slime", gfx_slime, 24, 24, {7, 5, 10, 14})
	dsprite.x = sprite.x + sprite.boundsx 
	dsprite.y = sprite.y
   	love.graphics.setFont(font_classic)
	love.graphics.setCanvas(canvas)
	dsprite.scaley = 1.8
	dsprite.scalex = 1.3
	table.insert(decaytext, 1, dsprite)
end

function makequestionbox(text, options)
	textbox_question = true
	menuposy = 0
	questionbox.options = options
	for i=1,#options do
		text = text.."\n  "..options[i]
	end
	text = text.."\n"
	--get dimensions

	local lines = explode(text, "\n")
	local h = #lines
	if h <= 0 then 
		h = 1 
	end
	local w = 0
	for i=1,#lines do
		if string.len(lines[i]) > w then
			w = string.len(lines[i]) + 3
		end
	end
	questionbox.bg, questionbox.width, questionbox.height = init_textbox_art(w, h)
	questionbox.text = text
end

function maketextbox(portrait, text)
	init_textbox()
	if portrait == "hero" then
		textbox.name = portrait
		textbox.art = gfx_pc
	end
	textbox.text = text
	lines = explode(text, "\n")

	local h = #lines
	if h <= 0 then 
		h = 1 
	end

	local w = 0
	for i=1,#lines do
		if string.len(lines[i]) >= w - 3 then
			w = string.len(lines[i]) + 3
		end
	end
	textbox.bg, textbox.width, textbox.height = init_textbox_art(w, 1)
end

function textbox_logic()
	if textbox_question then
		if string.len(textbox.displaytext) == string.len(textbox.text) then
			menu_controls(0, #questionbox.options)
			if action_button.justpressed then
				questionbox.answer[menuposy]()
				return
			end
		end
	end
	textbox.delay = textbox.delay + 1
	if textbox.delay >= 2 then
		textbox.delay = 0
		if string.len(textbox.displaytext) < string.len(textbox.text) then
			--add characters
			nextchar = string.sub(textbox.text, string.len(textbox.displaytext)+1, string.len(textbox.displaytext)+1)
			nextnextchar = string.sub(textbox.text, string.len(textbox.displaytext)+2, string.len(textbox.displaytext)+2)
			if not talkingpaused then
				play_sfx(sfx_textblip)
			end
			if  nextchar == "|" then
				talkingpaused = true
				--pause on |
			else
				--insert text
				if nextchar == "\n" then
					--resize if newline
					if nextnextchar == "|" then
					else
						textbox.bg, textbox.width, textbox.height = init_textbox_art(textbox.width, textbox.height+1)
					end
				end
				textbox.displaytext = textbox.displaytext .. nextchar
			end
		end
	end
	if action_button.justpressed then
		if talkingpaused then
			textbox.displaytext = ""
			textbox.text = string.sub(textbox.text, string.find(textbox.text, "|")+1)
			textbox.bg, textbox.width, textbox.height = init_textbox_art(textbox.width, 1)
			talkingpaused = false
		elseif string.len(textbox.displaytext) == string.len(textbox.text) then
			talking = false
		else
			nextpos = string.find(textbox.text, "|")
			if nextpos ~= nil then
				textbox.displaytext = textbox.displaytext .. string.sub(textbox.text, string.len(textbox.displaytext)+1, string.find(textbox.text, "|")-1)
				local lines = explode(textbox.displaytext, "\n")
				local h = #lines
				if h <= 0 then 
					h = 1 
				end
				textbox.bg, textbox.width, textbox.height = init_textbox_art(textbox.width, h)
				talkingpaused = true
			else
				textbox.displaytext = textbox.text
				local lines = explode(textbox.displaytext, "\n")
				local h = #lines
				if h <= 0 then 
					h = 1 
				end
				textbox.bg, textbox.width, textbox.height = init_textbox_art(textbox.width, h)
			end
		end
	end
	if cancel_button.justpressed then
		talking = false
	end
end

function shift_forwards(sprite)
	shift(sprite, sprite.lastmovement)
end

function shift(sprite, direction)
	if direction == "up" then
		sprite.y = sprite.y - 4
	elseif direction == "upleft" then
		sprite.y = sprite.y - 4
		sprite.x = sprite.x - 4
	elseif direction == "upright" then
		sprite.y = sprite.y - 4
		sprite.x = sprite.x + 4
	elseif direction == "left" then
		sprite.x = sprite.x - 4
	elseif direction == "right" then
		sprite.x = sprite.x + 4
	elseif direction == "down" then
		sprite.y = sprite.y + 4
	elseif direction == "downleft" then
		sprite.y = sprite.y + 4
		sprite.x = sprite.x - 4
	elseif direction == "downright" then
		sprite.y = sprite.y + 4
		sprite.x = sprite.x + 4
	end
end

function dospecial(n)
	if n == 1 then
		makequestionbox("cheat?", {"yes", "no"})
		questionbox.answer[0] = function() 
			sp_player.canpush = true 
			maketextbox("hero", "there ya go!")
		end
		questionbox.answer[1] = function()
			maketextbox("hero", "too bad..")
		end
	elseif n == 2 then
		makequestionbox("cheat?", {"yes", "no"})
		questionbox.answer[0] = function() 
			sp_player.hooks = true
			maketextbox("hero", "there ya go!")
		end
		questionbox.answer[1] = function()
			maketextbox("hero", "too bad..")
		end
	elseif n == 3 then
		makequestionbox("cheat?", {"yes", "no"})
		questionbox.answer[0] = function() 
			sp_player.canswim = true
			maketextbox("hero", "there ya go!")
		end
		questionbox.answer[1] = function()
			maketextbox("hero", "too bad..")
		end
	elseif n == 4 then
		makequestionbox("cheat?", {"yes", "no"})
		questionbox.answer[0] = function() 
			sp_player.canjump = true
			maketextbox("hero", "there ya go!")
		end
		questionbox.answer[1] = function()
			maketextbox("hero", "too bad..")
		end
	elseif n == 5 then
		if sp_player.hooks then
			textbox.text = "You can use the climbing\nspikes to reach new areas!"
		else
			sp_player.hooks = true
		end
	elseif n == 10 then
		--question
		makequestionbox("cheat?", {"yes", "no"})
		questionbox.answer[0] = function() 
			sp_player.gold = 100000
			maketextbox("hero", "there ya go!\n")
		end
		questionbox.answer[1] = function()
			maketextbox("hero", "too bad..\n")
		end
	elseif n == 11 then
		--question
		makequestionbox("cheat?", {"yes", "no"})
		questionbox.answer[0] = function() 
			sp_player.exp = sp_player.exptable[sp_player.level]
			maketextbox("hero", "there ya go!\n")
		end
		questionbox.answer[1] = function()
			maketextbox("hero", "too bad..\n")
		end
	elseif n == 101 then
		--inn
		maketextbox("hero", "hello, welcome!\ncare to spend the night?\nits free!")
		makequestionbox("stay the night?", {"sure", "no way"})
		questionbox.answer[0] = function() 
			fadetimer = 40
			maketextbox("hero","z..z...z...")
			sp_player.hp = sp_player.maxhp
		end
		questionbox.answer[1] = function()
			maketextbox("hero", "come back again!")
		end
	elseif n == 20 then
		--QUEST 1
		if quest["lookforboy"] then
			if quest["boyfound"] then
				if sp_player.canpush then
					maketextbox("hero", "I'm sure you'll be\nable to do something more\ninteresting than talking\nto me now.")
				else
					maketextbox("hero", "oh, you found him!\nhere, take my husbands gloves.\n\nthey'll allow you to push\nrocks around.\n")
				end
				quest["toldmom"] = true
				sp_player.canpush = true
			else
				maketextbox("hero", "please help me find\nmy child. his brother\nsaid he found a 'hideout'\nin a cave somewhere..")
			end
		else
			maketextbox("hero", "i cant find my other child! \nplease help me.\n|if you help, i'll give\nyou something nice..")
			quest["lookforboy"] = true
		end
	elseif n == 21 then
		--quest 1 pt. 2

		if quest["lookforboy"] then
			if quest["toldmom"] then
				maketextbox("hero", "what a tattletale")
			else
				maketextbox("hero", "what? she's looking for me?\noh man, please dont tell her!")
				quest["boyfound"] = true
			end
		else
			maketextbox("hero", "this is my cave.\ni come here to get away from\npeople, like my mom.\nwell, shes the only person i  \nknow, but all she ever\ndoes is yell.\n|this cave is awesome.\nyou can be my friend and\ncome here anytime.")
		end
	elseif n == 22 then
		-- main quest
		if quest["lookforprincess"] then
			maketextbox("hero", "please help us find princess.\n|a young man in this\nvillage has gloves\nthat will be very helpful.")
		else
			maketextbox("hero", "say, will you be our hero?\nthe gem of our village, princess\nwas kidnapped and stolen from us.\n|from what i understand,\nthe men who took her ran\npast the mountains.\n|you might need some new equipment\nto get that far. a\nyoung man in town has\ngloves that would be very useful.\n|i pray that you'll find her soon..")
			quest["lookforprincess"] = true
		end
	end
end

function useability(sprite)
	if sprite.abilityready and sprite.currentability > 0 then
		sprite_setanimation(sp_player, "ability")
		sprite.cooldown = 100
		sprite.maxcooldown = 100
		sprite.abilityready = false
		sprite.state = 300
		sprite.animcooldown = 20
		sprite_useability(sprite)
	end
end

function cantakeaction(sprite)

	local tempx = sprite.x
	local tempy = sprite.y
	shift_forwards(sprite)
	grouphit = checkgroupoverlap(sprite, npcgroup)
	sprite.x = tempx
	sprite.y = tempy
	if grouphit ~= false then
		--colliding with enemy npcgroup[grouphit]
		--check that you can
		if npcgroup[grouphit].interactable then
			return npcgroup[grouphit]
		end
	else
		return false
	end
end

function takeaction(sprite)
	if cantakeaction(sprite) then
		asprite = cantakeaction(sprite)
		if asprite.type == "npc" then
			--talk to npcs
			maketextbox("hero", npcgroup[grouphit].text)
			if npcgroup[grouphit].special > 0 then
				dospecial(npcgroup[grouphit].special)
			end
			return
		elseif asprite.type == "shop" then
			make_shop(npcgroup[grouphit].shopnum)
			return
		elseif asprite.type == "pickupable" then
			--pick item up
			pickupable_ai(asprite)
			return
		end
		useability(sprite)
	else
		useability(sprite)
	end
end

function anim_cooldown(sprite)
	sprite.animcooldown = sprite.animcooldown - 1
	if sprite.animcooldown <= 0 then
		sprite.state = 0
	end
end

function player_controls(sprite)
	status_effects(sprite)
	if find_direction() then
		sprite.abilitydirection = find_direction()
	end
	if sprite.pushing then
		if find_direction() ~= sprite.pushdir then
			sprite.pushing = false
		end
	end
	sprite.halt = false
	sprite.currentmovespeed = sprite.movespeed
	local movespeed = sprite.currentmovespeed
	local direction = find_direction()
	if sprite.healthalpha > 0 then
		sprite.healthalpha = sprite.healthalpha - 1
	end
	smoothscale(sprite)
	if pause_button.justpressed then
		init_pausemenu()
	end
	if action_button.justpressed then
		--action button
		--search for npc infront of char
		--check collision
		takeaction(sprite)
	end
	if sprite.state == 200 then
		--dead
	elseif sprite.state == 100 then
		--getting knocked back
		knockback_mechanics(sprite)
	elseif sprite.state == 300 then
		--locked in animation
		anim_cooldown(sprite)
	else
		if sprite.climbing then
			if sprite.currentanimation ~= "climbing" then
				sprite_setanimation(sprite, "climbing")
			end
			if find_direction() ~= false then
				sprite_playanimation(sprite)
				movespeed = 1
			end
		elseif find_direction() ~= false then
			if left_button.pressed and sprite.currentanimation ~=  "walk left" then
				sprite_setanimation(sprite, "walk left")
			elseif right_button.pressed and sprite.currentanimation ~= "walk right" then
				sprite_setanimation(sprite, "walk right")
			elseif up_button.pressed and sprite.currentanimation ~= "walk up" and not (left_button.pressed or right_button.pressed) then
				sprite_setanimation(sprite, "walk up")
			elseif down_button.pressed and sprite.currentanimation ~= "walk down" and not (left_button.pressed or right_button.pressed) then
				sprite_setanimation(sprite, "walk down")
			end
		else
			if sprite.currentanimation ~= "idle" then
				sprite_setanimation(sprite, "idle")
			end
		end
		if not sprite.abilityready then
			sprite.cooldown = sprite.cooldown - 1
			if sprite.cooldown <= 0 then
				sprite.abilityready = true
			end
		end
	end

	if find_direction() and sprite.state < 100 then
		sprite_movement(sprite, direction, movespeed)
	end
end

function find_direction()
	if up_button.ispressed then
		if left_button.ispressed then
			return "upleft"
		elseif right_button.ispressed then
			return "upright"
		else
			return "up"
		end
	elseif down_button.ispressed then
		if left_button.ispressed then
			return "downleft"
		elseif right_button.ispressed then
			return "downright"
		else
			return "down"
		end
	elseif left_button.ispressed then
		return "left"
	elseif right_button.ispressed then
		return "right"
	end
	return false
end


--map changing
function sidewarpto(newmap, side)
	fadetimer = 40
	if side == "top" then
		sp_player.y = currentmap.height-64
	elseif side == "bottom" then
		sp_player.y = 32
	elseif side == "left" then
		sp_player.x = currentmap.width-32
	elseif side == "right" then
		sp_player.x = 32
	end
	changemap(newmap)
end

function sideexitto(obj)
	fadetimer = 40
	changemap(obj.target)
	sp_player.x = obj.targetx
	sp_player.y = obj.targety
end

function changemap(id)
	local newmap = map[id]
	--unload all enemy sprites
	while #npcgroup >= 1 do
		table.remove(npcgroup, 1)
	end
	currenttilemap = newmap.tilemap
	currentcollision = newmap.collision
	currenttileset = newmap.tileset
	currentmap.id = id
	currentmap.width = newmap.width
	currentmap.height = newmap.height
	sp_player.x = sp_player.x
	sp_player.y = sp_player.y
	--load sprites
	for i=1,#newmap.npctable do
		addnpc(newmap.npctable[i])
	end
	mapbatch = get_tilemapbatch(currenttilemap, currenttileset)
end

function addnpc(tablenpc)
	--enemeis
	if tablenpc[1] == "slime" then
		table.insert(npcgroup, slime_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "smallslime" then
		table.insert(npcgroup, smallslime_init(tablenpc[2], tablenpc[3]))
	--interactables
	elseif tablenpc[1] == "npc" then
		table.insert(npcgroup, npc_init(tablenpc[2], tablenpc[3], tablenpc[4], tablenpc[5], tablenpc[6], tablenpc[7], tablenpc[8]))
	elseif tablenpc[1] == "shop" then
		table.insert(npcgroup, shop_init(tablenpc[2], tablenpc[3], tablenpc[4]))
	elseif tablenpc[1] == "cbush" then
		table.insert(npcgroup, cutbush_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "bombwall" then
		table.insert(npcgroup, bombwall_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "sign" then
		table.insert(npcgroup, sign_init(tablenpc[2], tablenpc[3], tablenpc[4], tablenpc[5]))
	elseif tablenpc[1] == "rock1" then
		table.insert(npcgroup, rock1_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "pickupable" then
		table.insert(npcgroup, pickupable_init(tablenpc[2], tablenpc[3], tablenpc[4], tablenpc[5]))
	--warps
	elseif tablenpc[1] == "sidewarp" then
		table.insert(npcgroup, sidewarp_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "sideexit" then
		table.insert(npcgroup, sideexit_init(tablenpc[2], tablenpc[3], tablenpc[4], tablenpc[5]))
	elseif tablenpc[1] == "tilewarp" then
		table.insert(npcgroup, tilewarp_init(tablenpc[2], tablenpc[3], tablenpc[4], tablenpc[5], tablenpc[6]))
	--cosmetic
	elseif tablenpc[1] == "tuft1" then
		table.insert(npcgroup, tuft1_init(tablenpc[2], tablenpc[3]))	
	elseif tablenpc[1] == "tree1" then
		table.insert(npcgroup, tree1_init(tablenpc[2], tablenpc[3]))	
	end
end

-- collision reactions
function find_pushdir(sprite)
	if sprite.lastmovement == "left" or sprite.lastmovement == "right" then
		return find_cardinal(find_direction())
	else
		return find_cardinal2(find_direction())
	end
end

function player_enemy_behavior()
	grouphit = checkgroupoverlap(sp_player, npcgroup)
	if grouphit ~= false then
		--colliding with enemy npcgroup[grouphit]
		--check that you can
		hittype = npcgroup[grouphit].type
		if hittype == "sidewarp" then
			sidewarpto(npcgroup[grouphit].target, npcgroup[grouphit].side)
		elseif hittype == "sideexit" then
			sideexitto(npcgroup[grouphit])
		elseif hittype == "tilewarp" then
			sideexitto(npcgroup[grouphit])
		elseif hittype == "push1" then
		elseif hittype == "npc" then
		elseif npcgroup[grouphit].state < 100 and hittype == "enemy" then
			local playerdamage = npcgroup[grouphit].attack - get_playerstat(sp_player, "defence")
			if playerdamage < 0 then
				playerdamage = 0
			end
			local enemydamage = get_playerstat(sp_player, "attack") - npcgroup[grouphit].defence
			if enemydamage < 0 then
				enemydamage = 0
			end
			damage_sprite(sp_player, playerdamage, {255, 200, 200, 255})
			damage_sprite(npcgroup[grouphit], enemydamage)
			if npcgroup[grouphit].hp <= 0 then
				-- level up
			else
				play_sfx(sfx_hit)
				--knockback
				if find_direction() ~= false then
					--use opposite player direction
					knockback(sp_player, 8, opposite_direction(find_direction()))
				else
					--knockback from enemy direction
					knockback(sp_player, 8, npcgroup[grouphit].lastmovement)
				end
				statuseffect_stun(npcgroup[grouphit], 8)
				sp_player.scalex = 1.2
				sp_player.scaley = 0.8
				npcgroup[grouphit].scalex = 1.2
				npcgroup[grouphit].scaley = 0.8
			end
		end
	end
end

--ai
function enemy_ai()
	--for now just the one enemy
	--detect enemy type and then run the right routine for them

	for i=1,#npcgroup do
		if npcgroup[i].id == "slime" then
			slime_ai(npcgroup[i])
		elseif npcgroup[i].id == "smallslime" then
			smallslime_ai(npcgroup[i])
		elseif npcgroup[i].id == "npc" then
			npc_ai(npcgroup[i])
		elseif npcgroup[i].id == "fire" then
			fire_ai(npcgroup[i])
		elseif npcgroup[i].id == "cut" then
			cut_ai(npcgroup[i])
		elseif npcgroup[i].id == "bomb" then
			bomb_ai(npcgroup[i])
		end
	end
end

