--dirtybumper lib -- sprites

--[[
	global sprite states
	0 	decide what to do
	1 	idle
	2 	move left
	3 	move right
	4 	move up
	5 	move down
	100 knockback
	101 stun
	102 burn
	200 dead
]]
--constants
state_ready = 0
state_idle = 1
state_moveleft = 2
state_moveright = 3
state_moveup = 4
state_movedown = 5
state_moveupleft = 6
state_moveupright = 7
state_movedownleft = 8
state_movedownright = 9
state_shootup = 10
state_shootdown = 11
state_shootleft = 12
state_shootright = 13
state_shootupleft = 14
state_shootupright = 15
state_shootdownleft = 16
state_shootdownright = 17
state_chase = 50
state_knockback = 100
state_stun = 101
state_burn = 102
state_dead = 190
state_removeme = 200



-- hero player
function player_init(x, y, class)
	if class == "warrior" then
		thisgfx = gfx_warrior
	elseif class == "thief" then
		thisgfx = gfx_thief
	end
	sprite = sprite_init("player", thisgfx, 24, 24, {8, 13, 8, 8})
	sprite.solid = false
   	sprite.x = x
   	sprite.y = y
   	--default stats
   	--different classes would have different stats
   	sprite.class = class
   	sprite.maxhp = 500
   	sprite.hp = 500
   	sprite.attack = 20
   	sprite.climbing = false
   	sprite.pushing = false
   	--other shit
   	sprite.movespeed = 2
   	sprite.currentmovespeed = 2
   	sprite.defence = 10
   	sprite.agility = 10
   	sprite.level = 1
   	sprite.exp = 0
   	sprite.gold = 0
   	sprite.exptable = { 100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200, 102400 }
   	sprite.cooldown = 0
   	sprite.maxcooldown = 0
   	sprite.abilityready = false
   	--add animations
   	sprite_addanimation(sprite, "walk down", {1, 2, 3, 4}, {13, 7, 13, 7})
   	sprite_addanimation(sprite, "walk left", {5, 6, 7, 8, 9, 10}, {15, 5, 5, 15, 5, 5})
   	sprite_addanimation(sprite, "walk right", {11, 12, 13, 14, 15, 16}, {15, 5, 5, 15, 5, 5})
   	sprite_addanimation(sprite, "walk up", {17,18,19,20}, {13, 7, 13, 7})
   	sprite_addanimation(sprite, "idle", {22, 2, 3, 4, 1, 2, 3, 4}, {120, 5, 5, 5, 5, 5, 5, 5})
   	sprite_addanimation(sprite, "climbing", {17, 18, 19, 20}, {5, 5, 5, 5})
   	sprite_addanimation(sprite, "ability", {21}, {30})
   	--equipment
   	sprite.itemsowned = {}
   	sprite.swordsowned = {}
   	sprite.shieldsowned = {}
   	sprite.armorsowned = {}
   	sprite.ringsowned = {}
   	sprite.abilitieslearned = {}
   	for i=1,8 do
   		sprite.itemsowned[i] = 0
   		sprite.swordsowned[i] = false
   		sprite.shieldsowned[i] = false
   		sprite.armorsowned[i] = false
   		sprite.ringsowned[i] = false
   		sprite.abilitieslearned[i] = false
   	end
   	--ring effects do their own thing
   	--temp shit for testing, initial loadout will go here
   	sprite.swordsowned[1] = true
   	sprite.shieldsowned[1] = true
   	sprite.swordequipped = 1
   	sprite.shieldequipped = 1
   	sprite.armorequipped = 0
   	sprite.ringequipped = 0
   	--abilities
   	sprite.abilitynames = {"cut", "burn", "ability3", "ability4", "ability5", "ability6", "ability7", "ability8"}
   	--sprite.abilitieslearned[1] = true
   	--sprite.abilitieslearned[2] = true
   	sprite.currentability = 0
   	--key items
   	sprite.canpush = false
   	sprite.hooks = false
   	sprite.canswim = false
   	sprite.canjump = false
   	return sprite
end

function get_playerstat(sprite, stat)
	local val = 0
	if stat == "attack" then
		val = sprite.attack
		if sprite.swordequipped > 0 then
			val = val + items[8+sprite.swordequipped].power
		end
		--ring mods
		if sprite.ringequipped == 1 then
			val = val * 1.2
		elseif sprite.ringequipped == 2 then
			val = val * 0.8
		end
	elseif stat == "defence" then
		val = sprite.defence 
		if sprite.shieldequipped > 0 then
			val = val + items[16+sprite.shieldequipped].power 
		end
		if sprite.armorequipped > 0 then
			val = val + items[24+sprite.armorequipped].power
		end
		--ring mods
		if sprite.ringequipped == 1 then
			val = val * 0.8
		elseif sprite.ringequipped == 2 then
			val = val * 1.2
		end
	elseif stat == "agility" then
		val = sprite.agility
		--ring mods
		if sprite.ringequipped == 3 then
			val = val * 2
		end
	end
	
	return math.floor(val)
end

function draw_cursor(x, y)
	love.graphics.draw(gfx_cursor, x-4, y)
end

--bar types
function healthbar_init(bar1, bar2)
	local thishealthbar = {}
	thishealthbar.fgbar = bar1
	thishealthbar.bgbar = bar2
	thishealthbar.maxwidth = thishealthbar.fgbar.maxwidth
	thishealthbar.currentwidth = thishealthbar.fgbar.currentwidth
	return thishealthbar
end

function healthbar_draw(healthbar, x, y)
	bar_draw(healthbar.bgbar, x, y)
	bar_draw(healthbar.fgbar, x+1, y+1)
end

function healthbar_changewidth(healthbar, width)
	healthbar.currentwidth = width
	bar_changewidth(healthbar.fgbar, width)
end

function healthbar_changewidthp(healthbar, perc)
	healthbar.currentwidth = healthbar.maxwidth * perc
	bar_changewidth(healthbar.fgbar, healthbar.maxwidth*perc)
end

--abilities
function abilitystartx(sx, direction)
	if direction == "up" then
		return sx
	elseif direction == "upleft" then
		return sx-8
	elseif direction == "upright" then
		return sx+8
	elseif direction == "left" then
		return sx-8
	elseif direction == "right" then
		return sx+8
	elseif direction == "down" then
		return sx
	elseif direction == "downleft" then
		return sx-8
	elseif direction == "downright" then
		return sx+8
	end
end

function abilitystarty(sy, direction)
	if direction == "up" then
		return sy-8
	elseif direction == "upleft" then
		return sy-4
	elseif direction == "upright" then
		return sy-4
	elseif direction == "left" then
		return sy+6
	elseif direction == "right" then
		return sy+6
	elseif direction == "down" then
		return sy+12
	elseif direction == "downleft" then
		return sy+12
	elseif direction == "downright" then
		return sy+12
	end
end

function get_rotation(direction)
	if direction == "up" then
		return 0
	elseif direction == "upleft" then
		return -0.5
	elseif direction == "upright" then
		return 0.5
	elseif direction == "left" then
		return -1.55
	elseif direction == "right" then
		return 1.55
	elseif direction == "down" then
		return 3.1
	elseif direction == "downleft" then
		return -2
	elseif direction == "downright" then
		return 2
	end
end

function explosion_init(x, y)
	local sprite = sprite_init("fire", gfx_fire, 24, 24, {0, 0, 0, 0})
	sprite.x = x
	sprite.y = y
	sprite.life = 15
	sprite_addanimation(sprite, "burn", {1,2}, {5,5})
	sprite_setanimation(sprite, "burn")
	return sprite
end

function explosion_ai(sprite)
	sprite.life = sprite.life - 1
	if sprite.live <= 0 then
		sprite.state = state_removeme
	end
end

function statuseffect_poison(sprite)
	if sprite.status ~= "poison" then
		sprite.status = "poison"
		sprite.statustimer = 600
	end
end

function statuseffect_burn(sprite)
	if sprite.status ~= "burn" then
		sprite.status = "burn"
		sprite.statustimer = 100
	end
end

function init_textbox()
	talking = true
	talkingpaused = false
	currentletter = 0
	textbox = {}
	textbox.displaytext = ""
	textbox.delay = 0
	--question box
	textbox_question = false
	questionbox = {}
	questionbox.answer = {}
	questionbox.displaytext = ""
	questionbox.text = ""
end

function init_textbox_art(w, h)
	local tilesize = 8
	local sprite = sprite_init("textbox", gfx_textbox, tilesize, tilesize, {0, 0, 0, 0})
	local sbatch = love.graphics.newSpriteBatch(gfx_textbox, 5000)
	--corners
	local thistile = love.graphics.newQuad(tilesize, 0, tilesize, tilesize, gfx_textbox:getWidth(), gfx_textbox:getHeight())
	sbatch:add(thistile, 0, 0)
	local thistile = love.graphics.newQuad(tilesize*3, 0, tilesize, tilesize, gfx_textbox:getWidth(), gfx_textbox:getHeight())
	sbatch:add(thistile, w*tilesize+tilesize, 0)
	local thistile = love.graphics.newQuad(tilesize*7, 0, tilesize, tilesize, gfx_textbox:getWidth(), gfx_textbox:getHeight())
	sbatch:add(thistile, 0, h*tilesize+tilesize)
	local thistile = love.graphics.newQuad(tilesize*9, 0, tilesize, tilesize, gfx_textbox:getWidth(), gfx_textbox:getHeight())
	sbatch:add(thistile, w*tilesize+tilesize, h*tilesize+tilesize)
	for row=1, w do
		local thistile = love.graphics.newQuad(2*tilesize, 0, tilesize, tilesize, gfx_textbox:getWidth(), gfx_textbox:getHeight())
		local id = sbatch:add(thistile, row*tilesize, 0)
		local thistile = love.graphics.newQuad(8*tilesize, 0, tilesize, tilesize, gfx_textbox:getWidth(), gfx_textbox:getHeight())
		local id = sbatch:add(thistile, row*tilesize, h*tilesize+tilesize)
		for col=1, h do
			local thistile = love.graphics.newQuad(5*tilesize, 0, tilesize, tilesize, gfx_textbox:getWidth(), gfx_textbox:getHeight())
			local id = sbatch:add(thistile, row*tilesize, col*tilesize)
		end
	end
	for col=1,h do
		local thistile = love.graphics.newQuad(4*tilesize, 0, tilesize, tilesize, gfx_textbox:getWidth(), gfx_textbox:getHeight())
		local id = sbatch:add(thistile, 0, col*tilesize)
		local thistile = love.graphics.newQuad(6*tilesize, 0, tilesize, tilesize, gfx_textbox:getWidth(), gfx_textbox:getHeight())
		local id = sbatch:add(thistile, w*tilesize+tilesize, col*tilesize)		
	end
	return sbatch, w, h
end


function levelup_gainstats(sprite, stat)
	--restore hp, increase stats and level
	if stat == 0 then
		--strength
		atkgain = 5
		defgain = 2
		agigain = 2
	elseif stat == 1 then
		--agility
		atkgain = 2
		defgain = 2
		agigain = 5
	elseif stat == 2 then
		--defence
		atkgain = 2
		defgain = 5
		agigain = 2
	end
	sprite.maxhp = sprite.maxhp * 1.5
	sprite.hp = sprite.maxhp
	sprite.attack = sprite.attack + atkgain
	sprite.defence = sprite.defence + defgain
	sprite.agility = sprite.agility + agigain
	sprite.level = sprite.level + 1
	--gain abilities
	if sprite.level == 2 then
		--gain cut
		sprite.abilitieslearned[1] = true
	elseif sprite.level == 3 then
		--gain burn
		sprite.abilitieslearned[2] = true
	elseif sprite.level == 4 then
		--gain bomb
		sprite.abilitieslearned[3] = true
	end
	dolevelup = false
end

--controls
--healthbars
function sprite_drawhealthbar(sprite)
	local hpleft = (sprite.hp/sprite.maxhp) * sprite.boundswidth
	love.graphics.setColor(255, 0, 0, sprite.healthalpha)
	love.graphics.rectangle("fill", sprite.x+sprite.boundsx, sprite.y, sprite.boundswidth, 3)
	love.graphics.setColor(255, 255, 0, sprite.healthalpha)
	love.graphics.rectangle("fill", sprite.x+sprite.boundsx, sprite.y, hpleft, 3)
	love.graphics.setColor(255, 255, 255, 255)
end

--knockback stuff
function knockback(sprite, amount, direction)
	sprite.state = state_knockback
	sprite.knockbackamount = amount
	sprite.knockbacktimer = amount * 2
	sprite.knockbackdirection = direction
end

function knockback_mechanics(sprite)
	--getting knocked back
	if sprite.knockbackamount > 0 then
		sprite_movement(sprite, sprite.knockbackdirection, 1)
		sprite.knockbackamount = sprite.knockbackamount - 1
	end
	--recovery
	sprite.knockbacktimer = sprite.knockbacktimer - 1
	if sprite.knockbacktimer <= 0 then
		sprite.state = state_ready
	end
end

--stun
function statuseffect_stun(sprite, amount)
	sprite.state = state_stun
	sprite.knockbacktimer = 8
end

function stun_mechanics(sprite)
	sprite.knockbacktimer = sprite.knockbacktimer - 1
	if sprite.knockbacktimer <= 0 then
		sprite.state = state_ready
	end
end

--misc sprite init
function pickupable_init(x, y, id, item, type)
	--local gfx_this = gfx_pickup_generic
	local gfx_this = gfx_chest
	if type == "chest" then
		gfx_this = gfx_chest
	else
		gfx_this = gfx_nullchest
	end
	local sprite = sprite_init("pickupable", gfx_this, 16, 24, {0, 8, 16, 16})
	sprite.x = x
	sprite.y = y
	sprite.solid = true
	sprite.pickupid = id
	sprite.item = item
	sprite.type = "pickupable"
	sprite.interactable = true
	sprite_addanimation(sprite, "idle", {1}, {100})
	sprite_addanimation(sprite, "open", {2}, {100})
	sprite_setanimation(sprite, "idle")
	sprite.open = false
	--if already grabbed
	if pickupable_pickedup[id] then
		sprite.open = true
		sprite.interactable = false
		sprite_setanimation(sprite, "open")
	end
	return sprite
end

function pickupable_ai(sprite)
	if not sprite.open then
		local textstring = "you found an item!\n|"
		if sp_player.itemsowned[sprite.item] >= 9 then
			textstring = textstring.."can't hold more "..items[sprite.item].name
		else
			textstring = textstring..items[sprite.item].name.." get!"
			sp_player.itemsowned[sprite.item] = sp_player.itemsowned[sprite.item] + 1
			sprite.interactable = false
			sprite_setanimation(sprite, "open")
			pickupable_pickedup[sprite.pickupid] = true
		end
		maketextbox("hero", textstring)
	end
end


--warps
function tilewarp_init(x, y, target, targetx, targety)
	local sprite = sprite_init("tilewarp", gfx_null, 1, 1, {x, y, 16, 16})
	sprite.target = target
	sprite.targetx = targetx
	sprite.type = "tilewarp"
	sprite.targety = targety
	return sprite
end

function sidewarp_init(side, location)
	if side == "top" then
		swstartx = 0
		swstarty = 0
		swwidth = currentmap.width
		swheight = 24
	elseif side == "left" then
		swstartx = 0
		swstarty = 0
		swwidth = 24
		swheight = currentmap.height
	elseif side == "right" then
		swstarty = 0
		swstartx = currentmap.width-4
		swwidth = 24
		swheight = currentmap.height
	elseif side == "bottom" then
		swstarty = currentmap.height
		swstartx = 0
		swwidth = currentmap.width
		swheight = 24
	else
		log("this shouldn't happen!")
		return
	end
	sprite = sprite_init("sidewarp", gfx_null, 1, 1, {swstartx, swstarty, swwidth, swheight})
	sprite.x = 0
	sprite.y = 0
	sprite.target = location
	sprite.side = side
	sprite.type = "sidewarp"
	return sprite
end

function sideexit_init(side, location, x, y)
	if side == "top" then
		swstartx = 0
		swstarty = 0
		swwidth = currentmap.width
		swheight = 8
	elseif side == "left" then
		swstartx = 0
		swstarty = 0
		swwidth = 8
		swheight = currentmap.height
	elseif side == "right" then
		swstarty = 0
		swstartx = currentmap.width-3
		swwidth = 8
		swheight = currentmap.height
	elseif side == "bottom" then
		swstarty = currentmap.height
		swstartx = 0
		swwidth = currentmap.width
		swheight = 8
	else
		log("this shouldn't happen!")
		return
	end
	local sprite = sprite_init("sideexit", gfx_null, 1, 1, {swstartx, swstarty, swwidth, swheight})
	sprite.x = 0
	sprite.y = 0
	sprite.target = location
	sprite.side = side
	sprite.targetx = x
	sprite.targety = y
	sprite.type = "sideexit"
	return sprite
end

--shops
function shop_init(x, y, shopnum)
	local sprite = sprite_init("shop", gfx_null, 1, 1, {0, 0, 16, 16})
	sprite.x = x
	sprite.y = y
	sprite.type = "shop"
	sprite.shopnum = shopnum
	sprite.interactable = true
	return sprite
end

--npcs
function npc_init(x, y, text, special, art, aitype, points)
	local sprite = sprite_init("npc", art, 24, 24, {7, 13, 10, 8})
	sprite.x = x
	sprite.y = y
	sprite.type = "npc"
	sprite.text = text
	sprite.walkspeed = .25
	sprite.normalwalkspeed = .25
	sprite.special = special
	sprite.aitype = aitype
	sprite.points = points
	sprite.currentpoint = 1
	sprite.solid = true
	sprite.interactable = true
   	--animations
	sprite_addanimation(sprite, "idle", {1}, {100})
   	sprite_addanimation(sprite, "up", {18,19,20,21}, {13, 7, 13, 7})
   	sprite_addanimation(sprite, "down", {2,3,4,5}, {13, 7, 13, 7})
   	sprite_addanimation(sprite, "left", {6,7,8,9,10,11}, {15, 5, 5, 15, 5, 5})
   	sprite_addanimation(sprite, "right", {12,13,14,15,16,17}, {15, 5, 5, 15, 5, 5})
   	sprite_addanimation(sprite, "idleup", {22}, {60})
   	sprite_addanimation(sprite, "idledown", {25}, {60})
   	sprite_addanimation(sprite, "idleleft", {23}, {60})
   	sprite_addanimation(sprite, "idleright", {24}, {60})
   	return sprite
end

function npc_ai(sprite)
	do_aitimer(sprite)
	if sprite.aitype ~= nil then
		--point format
		--{x,y}, {"wait", "wait"} {x,y}, {x,y}, ...
		if sprite.aitype == "walk_points" then
			if sprite.state == state_ready then
				local nextx = sprite.points[sprite.currentpoint][1]
				local nexty = sprite.points[sprite.currentpoint][2]

				if nextx == "wait" then
					--idle
					sprite.aitimer = 120
					set_idle(sprite)
					sprite.state = state_idle
					sprite.currentpoint = sprite.currentpoint + 1
				else
					local movedir = ""
					if sprite.y > nexty then
						movedir = "up"
						sprite_setanimation(sprite, "up")
					elseif sprite.y < nexty then
						movedir = "down"
						sprite_setanimation(sprite, "down")
					elseif sprite.x > nextx then
						movedir = "left"
						sprite_setanimation(sprite, "left")
					elseif sprite.x < nextx then
						movedir = "right"
						sprite_setanimation(sprite, "right")
					end
					sprite.state = get_movedir_state(movedir)
					--walk this way
					sprite.aitimer = 5
					if sprite.x == nextx and sprite.y == nexty then
						--met point
						sprite.currentpoint = sprite.currentpoint + 1
					end
				end
				if sprite.currentpoint > #sprite.points then
					sprite.currentpoint = 1
				end
			else
				ai_walk_core(sprite)
			end
		elseif sprite.aitype == "walk_wherever" then
			basic_enemy_ai(sprite)
		end
	else
		--just sit there
	end
end

function bombwall_init(x, y)
	local sprite = sprite_init("bombwall", gfx_bombwall, 16, 32, {0, 0, 16, 31})
	sprite.x = x
	sprite.y = y
	sprite.type = "bombable"
	sprite_addanimation(sprite, "explode", {2}, {50})
	sprite.solid = true
   	--animations
   	return sprite
end

function sign_init(x, y, text, special)
	local sprite = sprite_init("npc", gfx_sign, 24, 24, {7, 5, 10, 14})
	sprite.x = x
	sprite.y = y
	sprite.type = "npc"
	sprite.text = text
	sprite.interactable = true
	sprite.special = special
	sprite.solid = true
	return sprite
end

--interactable terrain
function cutbush_init(x,y)
	local sprite = sprite_init("cbush", gfx_bush1, 16, 16, {2, 1, 12, 12})
	sprite.x = x
	sprite.y = y
	sprite.type = "cuttable"
	sprite.cuttable = true
	sprite.solid = true
   	--animations
   	sprite_addanimation(sprite, "cut", {2}, {10})
   	return sprite
end

function cutbush_ai(sprite)

end

function rock1_init(x, y)
	local sprite = sprite_init("rock1", gfx_rock1, 24, 24, {1, 1, 14, 14})
	sprite.x = x
	sprite.y = y
	sprite.type = "push1"
	sprite.solid = true
	return sprite
end


--enemy inits

--scaling back to normal
function smoothscale(sprite)
	sprite.scalex = smoothnum(sprite.scalex)
	sprite.scaley = smoothnum(sprite.scaley)
end

--rotate back to normal

function status_effects(sprite)
	if sprite.status == "burn" then
		--damage 5% of health
		if sprite.statustimer % 8 == 0 then
			local damage = math.floor(sprite.maxhp * 0.025)
			damage_sprite(sprite, damage, {255, 0, 0, 255})
		end
	elseif sprite.status == "poison" then
		if sprite.statustimer % 100 == 0 then
			local damage = math.floor(sprite.maxhp * .025)
			damage_sprite(sprite, damage, {0, 255, 0, 255})
		end
	end
	if sprite.statustimer > 0 then
		sprite.statustimer = sprite.statustimer - 1
		if sprite.statustimer <= 0 then
			sprite.status = "normal"
		end
	end
end

function damage_sprite(sprite, damage, color)
	sprite.hp = sprite.hp - damage
	sprite.healthalpha = 255
	if not color then
		color = {255, 255, 255, 255}
	end
	make_damage_num(sprite, damage, color)
	if sprite.hp <= 0 then
		sprite.state = state_dead

		sp_player.exp = sp_player.exp + sprite.exp
		sp_player.gold = sp_player.gold + sprite.gold		

		if sp_player.exp > sp_player.exptable[sp_player.level] then
			dolevelup = true
			sp_player.exp = 0
			play_sfx(sfx_levelup)
		else
			play_sfx(sfx_win)
		end
	end
end

--enemy inits
function slime_init(x, y)
	local sprite = sprite_init("slime", gfx_slime, 24, 24, {7, 5, 10, 14})
	sprite.x = x
	sprite.walkspeed = .5
	sprite.y = y
	sprite.maxhp = 100
	sprite.hp = 100
	sprite.attack = 20
	sprite.defence = 10
	sprite.agility = 10
	sprite.exp = 35
	sprite.gold = 35
	sprite.level = 1
	sprite.type = "enemy"
   	--animations
   	sprite_addanimation(sprite, "up", {1, 2}, {10, 10})
   	sprite_addanimation(sprite, "down", {3, 4}, {10, 10})
   	sprite_addanimation(sprite, "left", {5, 6}, {10, 10})
   	sprite_addanimation(sprite, "right", {7, 8}, {10, 10})
   	return sprite
end

function smallslime_init(x, y)
	local sprite = sprite_init("smallslime", gfx_smallslime, 16, 16, {5, 5, 7, 7})
	sprite.x = x
	sprite.y = y
	sprite.walkspeed = .75
	sprite.maxhp = 50
	sprite.hp = sprite.maxhp
	sprite.attack = 10
	sprite.defence = 5
	sprite.agility = 5
	sprite.exp = 15
	sprite.gold = 15
	sprite.level = 1
	sprite.type = "enemy"
   	--animations
   	sprite_addanimation(sprite, "up", {1, 2}, {10, 10})
   	sprite_addanimation(sprite, "down", {1, 2}, {10, 10})
   	sprite_addanimation(sprite, "left", {1, 2}, {10, 10})
   	sprite_addanimation(sprite, "right", {1, 2}, {10, 10})
   	return sprite
end

function bat_init(x, y)
	local sprite = sprite_init("bat", gfx_bat, 32, 24, {12, 7, 8, 8})
	sprite.x = x
	sprite.y = y
	sprite.walkspeed = 1.25
	sprite.maxhp = 150
	sprite.hp = sprite.maxhp
	sprite.attack = 55
	sprite.defence = 35
	sprite.agility = 25
	sprite.fireballspeed = 1
	sprite.fireballdamage = 100
	sprite.fireballtype = "angled"
	sprite.exp = 100
	sprite.gold = 50
	sprite.level = 1
	sprite.type = "enemy"
	--animations
	sprite_addanimation(sprite, "up", {10, 11, 12}, {12, 8, 4})
	sprite_addanimation(sprite, "down", {1, 2, 3}, {12, 8, 4})
	sprite_addanimation(sprite, "left", {4, 5, 6}, {12, 8, 4})
	sprite_addanimation(sprite, "right", {7, 8, 9}, {12, 8, 4})
	sprite_addanimation(sprite, "shootup", {10, 11, 12}, {32, 16, 8})
	sprite_addanimation(sprite, "shootdown", {1, 2, 3}, {32, 16, 8})
	sprite_addanimation(sprite, "shootleft", {4, 5, 6}, {32, 16, 8})
	sprite_addanimation(sprite, "shootright", {7, 8, 9}, {32, 16, 8})
	sprite_setanimation(sprite, "down")
	return sprite
end

function beastman_scout_init(x, y)
	local sprite = sprite_init("beastman_scout", gfx_beastman_scout, 24, 24, {12, 7, 8, 8})
	sprite.x = x
	sprite.y = y
	sprite.walkspeed = .5
	sprite.normalwalkspeed = .5
	sprite.chasewalkspeed = 1.5
	sprite.maxhp = 500
	sprite.hp = sprite.maxhp
	sprite.attack = 100
	sprite.defence = 70
	sprite.agility = 30
	sprite.exp = 175
	sprite.gold = 250
	sprite.level = 1
	sprite.type = "enemy"
	sprite.vision = 64
	--animations

   	sprite_addanimation(sprite, "idledown", {1}, {5})
   	sprite_addanimation(sprite, "down", {2, 3, 4, 5}, {13, 7, 13, 7})
   	sprite_addanimation(sprite, "idleleft", {6}, {5})
   	sprite_addanimation(sprite, "left", {7, 8, 9, 10, 11, 12}, {15, 5, 5, 15, 5, 5})
   	sprite_addanimation(sprite, "idleright", {13}, {5})
   	sprite_addanimation(sprite, "right", {14, 15, 16, 17, 18, 19}, {15, 5, 5, 15, 5, 5})
   	sprite_addanimation(sprite, "idleup", {20}, {5})
   	sprite_addanimation(sprite, "up", {21,22,23,24}, {13, 7, 13, 7})
	sprite_setanimation(sprite, "down")
	return sprite
end

function beastman_fighter_init(x, y)
	local sprite = sprite_init("beastman_fighter", gfx_beastman_fighter, 24, 24, {12, 7, 8, 8})
	sprite.x = x
	sprite.y = y
	sprite.walkspeed = .5
	sprite.normalwalkspeed = .5
	sprite.vision = 24
	sprite.silent = true
	sprite.chasewalkspeed = 1
	sprite.maxhp = 500
	sprite.hp = sprite.maxhp
	sprite.attack = 150
	sprite.defence = 100
	sprite.agility = 50
	sprite.exp = 200
	sprite.gold = 250
	sprite.level = 1
	sprite.type = "enemy"
	--animations

   	sprite_addanimation(sprite, "idledown", {1}, {5})
   	sprite_addanimation(sprite, "down", {2, 3, 4, 5}, {13, 7, 13, 7})
   	sprite_addanimation(sprite, "idleleft", {6}, {5})
   	sprite_addanimation(sprite, "left", {7, 8, 9, 10, 11, 12}, {15, 5, 5, 15, 5, 5})
   	sprite_addanimation(sprite, "idleright", {13}, {5})
   	sprite_addanimation(sprite, "right", {14, 15, 16, 17, 18, 19}, {15, 5, 5, 15, 5, 5})
   	sprite_addanimation(sprite, "idleup", {20}, {5})
   	sprite_addanimation(sprite, "up", {21,22,23,24}, {13, 7, 13, 7})
	sprite_setanimation(sprite, "down")
	return sprite
end

---

function fireball_init(x, y, direction, speed, damage)
	local sprite = sprite_init("fireball", gfx_fireball, 8, 8, {2, 2, 4, 4})

	sprite.x = x
	sprite.y = y
	sprite.damage = damage
	sprite.walkspeed = speed
	sprite.direction = direction
	sprite.type = "fireball"

	sprite_addanimation(sprite, "idle", {1, 2, 3, 4}, {4, 4, 4, 4})
	sprite_setanimation(sprite, "idle")

	return sprite
end

--enemy ais
function slime_ai(sprite)
	enemy_core(sprite)
	basic_enemy_ai(sprite)
	if sprite.state == state_dead then
		--spawn 2 slimes
		sprite.state = state_removeme
		addnpc({"smallslime", sprite.x-4, sprite.y})
		addnpc({"smallslime", sprite.x+4, sprite.y})
	end
end

function smallslime_ai(sprite)
	enemy_core(sprite)
	basic_enemy_ai(sprite)
	if sprite.state == state_dead then
		sprite.state = state_removeme
	end
end

function bat_ai(sprite)
	enemy_core(sprite)
	fireball_enemy_ai(sprite)
	if sprite.state == state_dead then
		sprite.state = state_removeme
	end
end

function beastman_fighter_ai(sprite)
	enemy_core(sprite)
	tracker_ai(sprite)
	if sprite.state == state_dead then
		sprite.state = sprite_removeme
	end
end

function beastman_scout_ai(sprite)
	enemy_core(sprite)
	tracker_ai(sprite)
	if sprite.state == state_dead then
		sprite.state = sprite_removeme
	end
end

function fireball_ai(sprite)
	do_aitimer(sprite)
	if sprite.homing then
		if sprite.aitimer % 120 == 0 then
			sprite.direction = find_dir_2points(sprite, sp_player)
		end
	end

	--see if its a directional or angled fireball
	local sd = sprite.direction
	if string.find(sd, "up") or string.find(sd, "down") or string.find(sd, "left") or string.find(sd, "right") then
		local ox, oy = sprite.x, sprite.y
		shift_forwards(sprite)
		--check for player collision
		if checkoverlap(sprite, sp_player) then
			damage_sprite(sp_player, sprite.damage)
			sprite.state = state_removeme
		end
		--check for walls
		if checkmapoverlap_pure(sprite, currentcollision) then
			sprite.state = state_removeme
		end
		sprite.x, sprite.y = ox, oy
		sprite_movement(sprite, sprite.direction, sprite.walkspeed)
	else
		--angled
		sprite_angled_movement(sprite, sprite.direction, sprite.walkspeed)
		--check for player collision
		if checkoverlap(sprite, sp_player) then
			damage_sprite(sp_player, sprite.damage)
			sprite.state = state_removeme
		end
		--check for walls
		if checkmapoverlap_pure(sprite, currentcollision) then
			sprite.state = state_removeme
		end
		
	end
end
--

function enemy_core(sprite)
	sprite.emotion = ""
	do_aitimer(sprite)
	status_effects(sprite)
	smoothscale(sprite)
	healthbar_ai(sprite)
end

function healthbar_ai(sprite)
	if sprite.healthalpha > 0 then
		sprite.healthalpha = sprite.healthalpha - 1
	end	
end

function ai_chase_core(sprite)
	--follow angle
	if sprite.state == state_chase then
		if sprite.aitimer >= 50 then
			if not sprite.silent then
				sprite.emotion = "!"
			end
		elseif sprite.aitimer == 46 then
			dir = find_dir_2points(sprite, sp_player)
			dir = find_4way_dir(dir)
			sprite_setanimation(sprite, dir)
		elseif sprite.aitimer < 45 then
			sprite_angled_movement(sprite, sprite.angle, sprite.walkspeed, true)
		end
	end
end

function ai_walk_core(sprite)
	if sprite.state == state_idle then
		--idle
		if sprite.aitimer >= 0 then
		else
			sprite_resetai(sprite)
		end
	elseif sprite.state == state_moveleft then
		--move left
		if sprite.aitimer >= 0 then
			sprite_movement(sprite, "left", sprite.walkspeed)
		else
			sprite_resetai(sprite)
		end
	elseif sprite.state == state_moveright then
		--move right
		if sprite.aitimer >= 0 then
			sprite_movement(sprite, "right", sprite.walkspeed)
		else
			sprite_resetai(sprite)
		end
	elseif sprite.state == state_moveup then
		--move up
		if sprite.aitimer >= 0 then
			sprite_movement(sprite, "up", sprite.walkspeed)
		else
			sprite_resetai(sprite)
		end
	elseif sprite.state == state_movedown then
		--move down
		if sprite.aitimer >= 0 then
			sprite_movement(sprite, "down", sprite.walkspeed)
		else
			sprite_resetai(sprite)
		end
	elseif sprite.state == state_moveupleft then
		if sprite.aitimer >= 0 then
			sprite_movement(sprite, "upleft", sprite.walkspeed)
		else
			sprite_resetai(sprite)
		end
	elseif sprite.state == state_moveupright then
		if sprite.aitimer >= 0 then
			sprite_movement(sprite, "upright", sprite.walkspeed)
		else
			sprite_resetai(sprite)
		end
	elseif sprite.state == state_movedownleft then
		if sprite.aitimer >= 0 then
			sprite_movement(sprite, "downleft", sprite.walkspeed)
		else
			sprite_resetai(sprite)
		end
	elseif sprite.state == state_movedownright then
		if sprite.aitimer >= 0 then
			sprite_movement(sprite, "downright", sprite.walkspeed)
		else
			sprite_resetai(sprite)
		end
	end
end

function ai_fireball_core(sprite)
	local direction = ""
	if sprite.state == state_shootup then
		direction = "up"
	elseif sprite.state == state_shootdown then
		direction = "down"
	elseif sprite.state == state_shootleft then
		direction = "left"
	elseif sprite.state == state_shootright then
		direction = "right"
	elseif sprite.state == state_shootupleft then
		direction = "upleft"
	elseif sprite.state == state_shootupright then
		direction = "upright"
	elseif sprite.state == state_shootdownleft then
		direction = "downleft"
	elseif sprite.state == state_shootdownright then
		direction = "downright"
	else
		return
	end
	if sprite.aitimer > 50 and sprite.aitimer < 40 then
		--move towards playerif sprite.state == state_shootup then
		sprite_movement(sprite, direction, sprite.walkspeed)
	elseif sprite.aitimer == 20 then
		if sprite.fireballtype == homing then
			table.insert(npcgroup, fireball_init(sprite.x+sprite.width/2, sprite.y+sprite.height/2, direction, sprite.fireballspeed, sprite.fireballdamage))
		else
			table.insert(npcgroup, fireball_init(sprite.x+sprite.width/2, sprite.y+sprite.height/2, findangle(sprite, sp_player), sprite.fireballspeed, sprite.fireballdamage))
		end
	elseif sprite.aitimer < 20 then
		sprite.state = state_idle
	end
end

function set_idle(sprite)
	local idleanim = "idle"..sprite.lastmovement
	if sprite_hasanimation(sprite, idleanim) then
		sprite_setanimation(sprite, idleanim)
	else
		if sprite_hasanimation(sprite, "idle") then
			sprite_setanimation(sprite, "idle")
		end
	end
end

function tracker_ai(sprite)
	if sprite.state == state_knockback then
		knockback_mechanics(sprite)
	elseif sprite.state == state_stun then
		stun_mechanics(sprite)
	elseif sprite.state == state_ready then
		--not doing anything, do something
		--check for player in surrounding area
		--expand hitbox
		obx = sprite.boundsx
		oby = sprite.boundsy
		obw = sprite.boundswidth
		obh = sprite.boundsheight
		sprite.boundsx = sprite.boundsx - sprite.vision/2
		sprite.boundsy = sprite.boundsy - sprite.vision/2
		sprite.boundswidth = sprite.boundswidth + sprite.vision
		sprite.boundsheight = sprite.boundsheight + sprite.vision
		local chase = false
		--check collision
		if checkoverlap(sprite, sp_player) then
			--chase player
			chase = true
		end
		--restore bounds
		sprite.boundsx = obx
		sprite.boundsy = oby
		sprite.boundswidth = obw
		sprite.boundsheight = obh
		if chase then
			--find angle
			sprite.angle = findangle(sprite, sp_player)
			sprite.state = state_chase
			sprite.walkspeed = sprite.chasewalkspeed
			sprite.aitimer = 64
			--change animation
			set_idle(sprite)
			--alert sound
			if not sprite.silent then
				play_sfx(sfx_alert)
			end
		else
			sprite.walkspeed = sprite.normalwalkspeed
			sprite.aitimer = 90
			rval = math.floor(math.random(10))
			if rval > 6 then
				sprite.state = state_idle
				set_idle(sprite)
			else
				randomval = math.floor(math.random(4))
				if randomval == 4 then
					--walk left
					sprite.state = state_moveleft
					sprite_setanimation(sprite, "left")
				elseif randomval == 3 then
					--walk right
					sprite.state = state_moveright
					sprite_setanimation(sprite, "right")
				elseif randomval == 2 then
					--walk up
					sprite.state = state_moveup
					sprite_setanimation(sprite, "up")
				elseif randomval == 1 then
					--walk down
					sprite.state = state_movedown
					sprite_setanimation(sprite, "down")
				end
			end
		end
	else
		ai_walk_core(sprite)
		ai_chase_core(sprite)
	end
end

function basic_enemy_ai(sprite)
	if sprite.state == state_knockback then
		knockback_mechanics(sprite)
	elseif sprite.state == state_stun then
		stun_mechanics(sprite)
	elseif sprite.state == state_ready then
		--not doing anything, do something
		sprite.aitimer = 90
		rval = math.floor(math.random(10))
		if rval > 6 then
			sprite.state = state_idle
			set_idle(sprite)
		else
			randomval = math.floor(math.random(4))
			if randomval == 4 then
				--walk left
				sprite.state = state_moveleft
				sprite_setanimation(sprite, "left")
			elseif randomval == 3 then
				--walk right
				sprite.state = state_moveright
				sprite_setanimation(sprite, "right")
			elseif randomval == 2 then
				--walk up
				sprite.state = state_moveup
				sprite_setanimation(sprite, "up")
			elseif randomval == 1 then
				--walk down
				sprite.state = state_movedown
				sprite_setanimation(sprite, "down")
			end
		end
	else
		ai_walk_core(sprite)
	end
end

function fireball_enemy_ai(sprite)
	if sprite.state == state_knockback then
		knockback_mechanics(sprite)
	elseif sprite.state == state_stun then
		stun_mechanics(sprite)
	elseif sprite.state == state_ready then
		--not doing anything, do something
		sprite.aitimer = 64
		rval = math.floor(math.random(10))
		if rval > 6 then
			sprite.state = state_idle
			set_idle(sprite)
		else
			randomval = math.floor(math.random(5))
			if randomval == 5 then
				--shoot fireball in direction facing
				--always shoot torwards player
				--find angle
				local shootdir = find_dir_2points(sprite, sp_player)
				if shootdir == "up" then
					sprite_setanimation("shootup")
					sprite.state = state_shootup
				elseif shootdir == "down" then
					sprite_setanimation("shootdown")
					sprite.state = state_shootdown
				elseif shootdir == "left" then
					sprite_setanimation("shootleft")
					sprite.state = state_shootleft
				elseif shootdir == "right" then
					sprite_setanimation("shootright")
					sprite.state = state_shootright
				elseif shootdir == "upleft" then
					sprite_setanimation("shootleft")
					sprite.state = state_shootupleft
				elseif shootdir == "upright" then
					sprite_setanimation("shootright")
					sprite.state = state_shootupright
				elseif shootdir == "downleft" then
					sprite_setanimation("shootleft")
					sprite.state = state_shootdownleft
				elseif shootdir == "downright" then
					sprite_setanimation("shootright")
					sprite.state = state_shootdownright
				end
			elseif randomval == 4 then
				--walk left
				sprite.state = state_moveleft
				sprite_setanimation(sprite, "left")
			elseif randomval == 3 then
				--walk right
				sprite.state = state_moveright
				sprite_setanimation(sprite, "right")
			elseif randomval == 2 then
				--walk up
				sprite.state = state_moveup
				sprite_setanimation(sprite, "up")
			elseif randomval == 1 then
				--walk down
				sprite.state = state_movedown
				sprite_setanimation(sprite, "down")
			end
		end
	else
		ai_fireball_core(sprite)
		ai_walk_core(sprite)
	end
end


--cosmetic sprites
function tuft1_init(x, y)
	local sprite = sprite_init("deco", gfx_tuft1, 16, 16, {0, 0, 0, 6})
	sprite.x = x
	sprite.y = y
	sprite_addanimation(sprite, "idle", {1,2,3,4,5,6,7,8}, {20,10,20,10,20,10,20,10})
	sprite_setanimation(sprite, "idle")
   	return sprite
end

function tree1_init(x, y)
	local sprite = sprite_init("deco", gfx_tree, 64, 64, {25, 25, 16, 36})
	sprite.x = x
	sprite.y = y
	sprite.solid = true
   	return sprite
end


function flower1_init(x, y)
	local sprite = sprite_init("deco", gfx_flowers, 24, 24, {0, 0, 16, 8})
	sprite.x = x
	sprite.y = y
	sprite_addanimation(sprite, "idle", {1, 2, 3, 4}, {10, 10, 10, 10})
	sprite_setanimation(sprite, "idle")
   	return sprite
end
function flower2_init(x, y)
	local sprite = sprite_init("deco", gfx_flowerl, 6, 8, {0, 0, 16, 4})
	sprite.x = x
	sprite.y = y
	sprite_addanimation(sprite, "idle", {1, 2, 3, 4}, {10, 10, 10, 10})
	sprite_setanimation(sprite, "idle")
   	return sprite
end
function flower3_init(x, y)
	local sprite = sprite_init("deco", gfx_flowerr, 6, 8, {0, 0, 16, 4})
	sprite.x = x
	sprite.y = y
	sprite_addanimation(sprite, "idle", {1, 2, 3, 4}, {10, 10, 10, 10})
	sprite_setanimation(sprite, "idle")
   	return sprite
end
function light1_init(x,y)
	local sprite = sprite_init("light1", gfx_lighteffect, 100, 100, {0, 0, 0, 4})
	sprite.x = x
	sprite.y = y
	sprite.drawmode = "add"
   	return sprite
end
function waterrock1_init(x, y)
	local sprite = sprite_init("deco", gfx_waterrock1, 24, 24, {0, 0, 0, 4})
	sprite.x = x
	sprite.y = y
	sprite_addanimation(sprite, "idle", {1, 2, 3, 4}, {10, 10, 10, 10})
	sprite_setanimation(sprite, "idle")
   	return sprite
end
function waterrock2_init(x, y)
	local sprite = sprite_init("deco", gfx_waterrock2, 24, 24, {0, 0, 0, 4})
	sprite.x = x
	sprite.y = y
	sprite_addanimation(sprite, "idle", {1, 2, 3, 4}, {10, 10, 10, 10})
	sprite_setanimation(sprite, "idle")
   	return sprite
end