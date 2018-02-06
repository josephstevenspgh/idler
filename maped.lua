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
   	currentobj = 1
   	objects = {"npc", "sign", "rock1", "chest", "cbush", "slime", "smallslime", "bat", "beastman_scout", "beastman_fighter", "tuft1", "tree1", "flower1", "flower2", "flower3", "waterrock1", "waterrock2", "light1", }
   	maps = {1, 2, 3, 4, 5, 100, 101, 102, 103, 104, 105, 106, 107, 108, 200, 201, 202, 203, 204}
   	editmap = 1
   	--sp_player = 
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
			sprite_playanimation(npcgroup[i])
			sprite_draw(npcgroup[i])
			sprite_drawhealthbar(npcgroup[i])
			sprite_drawhitbox(npcgroup[i])
		end
	end
	if not playerdrawn then
		draw_player()
	end

	love.graphics.origin()

	--fadeout

	--debug
	love.graphics.print("x: "..sp_player.x.." y: "..sp_player.y)
end

function update_ingame()
	gameactive = false
	if up_button.pressed then
		sp_player.y = sp_player.y - 1
	elseif down_button.pressed then
		sp_player.y = sp_player.y + 1
	elseif right_button.pressed then
		sp_player.x = sp_player.x + 1
	elseif left_button.pressed then
		sp_player.x = sp_player.x - 1
	end
	if pause_button.justpressed then
		editmap = editmap + 1
		if editmap > #maps then
			editmap = 1
		end
		changemap(maps[editmap])
		log("-------------------------\nnew map: map :"..maps[editmap].."\n----------------------")
		sp_player.x = 50
		sp_player.y = 50
	end
	if action_button.justpressed then
		log("{\""..objects[currentobj].."\", "..sp_player.x..", "..sp_player.y.."},")
		tempaddnpc(objects[currentobj])
	end
	if cancel_button.justpressed then
		--next object
		currentobj = currentobj + 1
		local sx = sp_player.x
		local sy = sp_player.y
		if currentobj > #objects then currentobj = 1 end
		local co = objects[currentobj]
		if co == "npc" then
			sp_player = npc_init(sx, sy, "", 0, gfx_oldman)
			--, text, special, art, aitype, points)
		elseif co == "sign" then
			sp_player = sign_init(sx, sy)
		elseif co == "rock1" then
			sp_player = rock1_init(sx, sy)
		elseif co == "chest" then
			sp_player = pickupable_init(sx, sy)
		elseif co == "cbush" then
			sp_player = cutbush_init(sx, sy)
		elseif co == "slime" then
			sp_player = slime_init(sx, sy)
		elseif co == "smallslime" then
			sp_player = smallslime_init(sx, sy)
		elseif co == "bat" then
			sp_player = bat_init(sx, sy)
		elseif co == "tuft1" then
			sp_player = tuft1_init(sx, sy)
		elseif co == "tree1" then
			sp_player = tree1_init(sx, sy)
		elseif co == "flower1" then
			sp_player = flower1_init(sx, sy)
		elseif co == "flower2" then
			sp_player = flower2_init(sx, sy)
		elseif co == "flower3" then
			sp_player = flower3_init(sx, sy)
		elseif co == "waterrock1" then
			sp_player = waterrock1_init(sx, sy)
		elseif co == "waterrock2" then
			sp_player = waterrock2_init(sx, sy)
		elseif co == "beastman_fighter" then
			sp_player = beastman_fighter_init(sx, sy)
		elseif co == "beastman_scout" then
			sp_player = beastman_scout_init(sx, sy)
		elseif co == "light1" then
			sp_player = light1_init(sx, sy)
		end
	end
end

function draw_player()
	if gameactive and not sp_player.climbing then
		sprite_playanimation(sp_player)
	end
	playerdrawn = true
	sprite_draw(sp_player)
	sprite_drawhitbox(sp_player)
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
	elseif tablenpc[1] == "bat" then
		table.insert(npcgroup, bat_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "beastman_scout" then
		table.insert(npcgroup, beastman_scout_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "beastman_fighter" then
		table.insert(npcgroup, beastman_fighter_init(tablenpc[2], tablenpc[3]))
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
	elseif tablenpc[1] == "flower1" then
		table.insert(npcgroup, flower1_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "flower2" then
		table.insert(npcgroup, flower2_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "flower3" then
		table.insert(npcgroup, flower3_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "waterrock1" then
		table.insert(npcgroup, waterrock1_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "waterrock2" then
		table.insert(npcgroup, waterrock2_init(tablenpc[2], tablenpc[3]))
	elseif tablenpc[1] == "light1" then
		table.insert(npcgroup, light1_init(tablenpc[2], tablenpc[3]))		
	end
end


function tempaddnpc(npc)
	--enemeis
	local sx = sp_player.x
	local sy = sp_player.y
	if npc == "slime" then
		table.insert(npcgroup, slime_init(sx, sy))
	elseif npc == "smallslime" then
		table.insert(npcgroup, smallslime_init(sx, sy))
	elseif npc == "bat" then
		table.insert(npcgroup, bat_init(sx, sy))
	elseif npc == "beastman_scout" then
		table.insert(npcgroup, beastman_scout_init(sx, sy))
	elseif npc == "beastman_fighter" then
		table.insert(npcgroup, beastman_fighter_init(sx, sy))
	--interactables
	elseif npc == "npc" then
		table.insert(npcgroup, npc_init(sx, sy, "", 0, gfx_oldman))
	elseif npc == "cbush" then
		table.insert(npcgroup, cutbush_init(sx, sy))
	elseif npc == "sign" then
		table.insert(npcgroup, sign_init(sx, sy))
	elseif npc == "rock1" then
		table.insert(npcgroup, rock1_init(sx, sy))
	elseif npc == "pickupable" then
		table.insert(npcgroup, pickupable_init(sx, sy, 1, 1, "chest"))
	--cosmetic
	elseif npc == "light1" then
		table.insert(npcgroup, light1_init(sx, sy))	
	elseif npc == "tuft1" then
		table.insert(npcgroup, tuft1_init(sx, sy))	
	elseif npc == "tree1" then
		table.insert(npcgroup, tree1_init(sx, sy))	
	elseif npc == "flower1" then
		table.insert(npcgroup, flower1_init(sx, sy))	
	elseif npc == "flower2" then
		table.insert(npcgroup, flower2_init(sx, sy))	
	elseif npc == "flower3" then
		table.insert(npcgroup, flower3_init(sx, sy))			
	elseif npc == "waterrock1" then
		table.insert(npcgroup, waterrock1_init(sx, sy))			
	elseif npc == "waterrock2" then
		table.insert(npcgroup, waterrock2_init(sx, sy))			
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