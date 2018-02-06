--game framework functions for love2d by setz @splixel on twitter
require("dirtybumper")
--utility functions
function lprint(s, x, y)
	love.graphics.print(s, x, y)
end

function explode(instring, delimiter)
	retval = {}
	for word in string.gmatch(instring, '([^'..delimiter..'"]+)') do
    	table.insert(retval, word)
	end
	return retval
	--[[
	--old code
	retval = {}
	lastpos = 1
	for i=1,#instring do
		if string.sub(instring,i,i) == delimiter then
			table.insert(retval, string.sub(instring, lastpos, i-1))
			i = i + 1
			lastpos = i
		end
	end
	return retval]]  
end

function inc(var)
	return var + 1
end

function find_cardinal(direction)
	if string.find(direction, "left") then
		return "left"
	elseif string.find(direction, "right") then
		return "right"
	elseif string.find(direction, "up") then
		return "up"
	elseif string.find(direction, "down") then
		return "down"
	else
		log("what"..direction)
	end
end

function find_cardinal2(direction)
	if string.find(direction, "up") then
		return "up"
	elseif string.find(direction, "down") then
		return "down"
	elseif string.find(direction, "left") then
		return "left"
	elseif string.find(direction, "right") then
		return "right"
	else
		log("what"..direction)
	end
end

function opposite_direction(direction)
	if direction == "up" then
		return "down"
	elseif direction == "down" then
		return "up"
	elseif direction == "left" then
		return "right"
	elseif direction == "right" then
		return "left"
	elseif direction == "upleft" then
		return "downright"
	elseif direction == "upright" then
		return "downleft"
	elseif direction == "downleft" then
		return "upright"
	elseif direction == "downright" then
		return "downleft"
	end
	return false
end

function smoothnum(num)
	if num < 1 then
		return num + .01
	elseif num > 1 then
		return num - .01
	end	
	return num
end

--debug functions
function log(s)
	if type(s) == "table" then
		print('table')
		for k,v in pairs(s) do
			print(k.." | "..v)
		end
	else
		print(s)
	end
end	

--audio
function play_sfx(sfx)
	love.audio.newSource(sfx):play()
end

--controls
function init_button(kc)
	local retval = {}
	retval.keycode = kc
	retval.ispressed = false
	retval.justpressed = false
	retval.pressedlastframe = false
	retval.keyrepeat = 0
	retval.type = "none"
	return retval
end

function button_add_joypad_button(button, joypad, num)
	button.joypad = joypad
	button.type = "button"
	button.num = num
end

function button_add_joypad_hat(button, joypad, num, dir)
	button.joypad = joypad
	button.type = "hat"
	button.num = num
	button.dir = dir
end

function button_mechanics(button)
	button.pressedlastframe = button.ispressed
	keydown = love.keyboard.isDown(button.keycode)
	if button.type == "button" then
		joydown = button.joypad:isDown(button.num)
	elseif button.type == "hat" then
		if string.find(button.joypad:getHat(button.num), button.dir) then
			joydown = true
		else
			joydown = false
		end
	end
	if keydown or joydown then
		button.ispressed = true
		button.pressed = true
		if button.pressedlastframe then
			button.justpressed = false
		else
			button.justpressed = true
		end
	else
		button.ispressed = false
		button.pressed = false
		button.justpressed = false
		button.pressedlastframe = false
	end
end

function get_joysticks()
	local retval = {}
	for i,joystick in ipairs(love.joystick.getJoysticks()) do
		table.insert(retval, joystick)
	end
	return retval
end

--sprites

--bars

function bar_draw(bar, x, y)
	love.graphics.draw(bar.currentart, x, y)
end

function bar_changewidth(thisbar, newwidth)
	thisbar.currentwidth = newwidth

	local barart = thisbar.currentart
	love.graphics.setCanvas(barart)
	love.graphics.clear()
	--get quads
	--quad = love.graphics.newQuad( x, y, width, height, sw, sh )

	thisbar.leftquad = love.graphics.newQuad(0, 0, thisbar.leftwidth, thisbar.height, thisbar.art:getWidth(), thisbar.art:getHeight())
	thisbar.centerquad = love.graphics.newQuad(thisbar.leftwidth, 0, thisbar.centerwidth, thisbar.height, thisbar.art:getWidth(), thisbar.art:getHeight())
	thisbar.rightquad = love.graphics.newQuad(thisbar.leftwidth+thisbar.centerwidth, 0, thisbar.rightwidth, thisbar.height, thisbar.art:getWidth(), thisbar.art:getHeight())

	local drawwidth = thisbar.currentwidth
	if drawwidth >= thisbar.maxwidth-thisbar.rightwidth-thisbar.centerwidth then
		drawwidth = thisbar.maxwidth-thisbar.rightwidth-thisbar.centerwidth
	end

	if drawwidth >= 0 then
		love.graphics.draw(thisbar.art, thisbar.leftquad, 0, 0)
		love.graphics.draw(thisbar.art, thisbar.centerquad, thisbar.leftwidth, 0, 0, drawwidth, 1)
		love.graphics.draw(thisbar.art, thisbar.rightquad, thisbar.leftwidth+drawwidth, 0)
	end

--	local dsprite = sprite_init("damage number", tempart, 40, 8, {0, 0, 0, 0})
	love.graphics.setCanvas(canvas)
	thisbar.currentart = barart
end

function bar_init(art, mw, iw, lw, cw, rw)
	local thisbar = {}
	thisbar.maxwidth = mw+lw+rw
	thisbar.currentwidth = iw
	thisbar.leftwidth = lw
	thisbar.centerwidth = cw
	thisbar.rightwidth = rw
	thisbar.art = art
	thisbar.height = art:getHeight()
	thisbar.art:setFilter("nearest","nearest")

	local barart = love.graphics.newCanvas(thisbar.maxwidth, thisbar.height)
	love.graphics.setCanvas(barart)
	--get quads
	--quad = love.graphics.newQuad( x, y, width, height, sw, sh )

	thisbar.leftquad = love.graphics.newQuad(0, 0, thisbar.leftwidth, thisbar.height, art:getWidth(), thisbar.height)
	thisbar.centerquad = love.graphics.newQuad(thisbar.leftwidth, 0, thisbar.centerwidth, thisbar.height, art:getWidth(), thisbar.height)
	thisbar.rightquad = love.graphics.newQuad(thisbar.leftwidth+thisbar.centerwidth, 0, thisbar.rightwidth, thisbar.height, art:getWidth(), thisbar.height)

	love.graphics.draw(thisbar.art, thisbar.leftquad, 0, 0)
	love.graphics.draw(thisbar.art, thisbar.centerquad, thisbar.leftwidth, 0, 0, thisbar.currentwidth, 1)
	love.graphics.draw(thisbar.art, thisbar.rightquad, thisbar.leftwidth+thisbar.currentwidth, 0)

--	local dsprite = sprite_init("damage number", tempart, 40, 8, {0, 0, 0, 0})
	love.graphics.setCanvas(canvas)
	thisbar.currentart = barart
	return thisbar
end

function sprite_getbottom(sprite)
	local bottom = sprite.y + sprite.bounds[2] + sprite.bounds[4]
	return bottom
end

function sprite_useability(sprite)
	if sprite.currentability == 1 then
		table.insert(npcgroup, cut_init(sprite.x, sprite.y, sprite.abilitydirection))
		--table.insert(npcgroup, cut_init(sprite.x, sprite.y, sprite.abilitydirection))
	elseif sprite.currentability == 2 then
		table.insert(npcgroup, fire_init(sprite.x, sprite.y, sprite.abilitydirection))
	elseif sprite.currentability == 3 then
		table.insert(npcgroup, bomb_init(sprite.x, sprite.y, sprite.abilitydirection))
	end
end

function sprite_init(id, art, spritewidth, spriteheight, bounds)
	local sprite = {}
	sprite.emotion = ""
	art:setFilter("nearest","nearest")
	--interactable objects
	sprite.interactable = false
	sprite.canpush = false
	sprite.pushing = false
	sprite.pushdir = ""
	sprite.cuts = false
	sprite.cuttable = false
	sprite.burns = false
	sprite.burnable = false
	--id
	sprite.id = id
	sprite.uid = nextspriteid
	nextspriteid = nextspriteid + 1
	--theres so much stuff
	sprite.currentmovespeed = 1
	sprite.movespeed = 1
	sprite.healthalpha = 0
	sprite.status = "normal"
	sprite.statustimer = 0
	sprite.artsheet = art
	sprite.width = spritewidth
	sprite.height = spriteheight
	sprite.bounds = bounds
	sprite.rotation = 0
	sprite.scalex = 1
	sprite.scaley = 1
	--stats
	sprite.maxhp = 0
	sprite.hp = 0
	sprite.attack = 0
	sprite.defense = 0
	sprite.agility = 0
	sprite.exp = 0
	sprite.gold = 0
	sprite.level = 0
	--init dimensions
	sprite.x = 0
	sprite.y = 0
	sprite.facing = 0
	sprite.lastmovement = "down"
	sprite.abilitydirection = "up"
	sprite.state = 0
	sprite.aitimer = 0
	sprite.movetimer = 0
	sprite.knockbackamount = 0
	sprite.knockbacktimer = 0
	sprite.knockbackdirection = 0
	sprite.boundsx = bounds[1]
	sprite.boundsy = bounds[2]
	sprite.boundswidth = bounds[3]
	sprite.boundsheight = bounds[4]
	--get amount of frames in sheet
	sprite.sheetwidth = art:getWidth()
	sprite.sheetheight = art:getHeight()
	sprite.currentframe = 1
	sprite.animationframe = 1
	sprite.currentanimation = ""
	sprite.animcooldown = 0
	sprite.animationscount = 0
	sprite.timer = 0
	sprite.framecount = sprite.sheetwidth/sprite.width
	if sprite.sheetwidth%sprite.width ~= 0 then
		log("error: spritesheet width isnt multiple of sprite size")
		return
	end
	if sprite.sheetheight%sprite.height ~= 0 then
		log("error: spritesheet height isnt multiple of sprite size")
		return
	end
	--set frames
	sprite.frame = {}
	for i=1, sprite.framecount do
		table.insert(sprite.frame, love.graphics.newQuad((i-1)*sprite.width, 0, sprite.width, sprite.height, sprite.sheetwidth, sprite.sheetheight))
	end
	--init animations
	sprite.animations = {}

	return sprite
end

function sprite_resetai(sprite)
	sprite.aitimer = 0
	sprite.state = 0
	sprite.movetimer = 0
end

function get_movedir_state(movedir)
	if movedir == "up" then
		return state_moveup
	elseif movedir == "down" then
		return state_movedown
	elseif movedir == "left" then
		return state_moveleft
	elseif movedir == "right" then
		return state_moveright
	elseif movedir == "upleft" then
		return state_moveupleft
	elseif movedir == "upright" then
		return state_moveupright
	elseif movedir == "downleft" then
		return state_movedownleft
	elseif movedir == "downright" then
		return state_movedownright
	else
		return state_idle
	end
end

function do_aitimer(sprite)
	sprite.aitimer = sprite.aitimer - 1
	if sprite.aitimer <= 0 then
		sprite_resetai(sprite)
	end
end

function sprite_angled_movement(sprite, direction, amount, walls)
	local oldx, oldy = sprite.x, sprite.y
	local canmove = true
	--direction is an angle
	local dx, dy = math.cos(direction) * sprite.walkspeed, math.sin(direction) * sprite.walkspeed
	local ox, oy = sprite.x, sprite.y
	sprite.x = sprite.x + -dx
	sprite.y = sprite.y + -dy
	if walls then
		if checkmapoverlap(sprite, currentcollision) then
			sprite.x = ox
			sprite.y = oy
		end
	end
end

function sprite_movement(sprite, direction, amount)
	sprite.lastmovement = direction
	local oldx, oldy = sprite.x, sprite.y
	local canmove = true
	if string.find(direction, "up") then
		sprite.y = sprite.y - amount
	elseif string.find(direction, "down") then
		sprite.y = sprite.y + amount
	end
	if checkmapoverlap(sprite, currentcollision) then
		if sprite.pushing then
			sprite.x = oldx
			sprite.y = oldy
			canmove = false
		else
			sprite.x = sprite.x + amount
			if checkmapoverlap(sprite, currentcollision) then
				sprite.x = sprite.x - amount*2
				if checkmapoverlap(sprite, currentcollision) then
					sprite.x = oldx
					sprite.y = oldy
					canmove = false
				end
			end
		end
	end
	oldy = sprite.y
	if string.find(direction, "left") then
		sprite.x = sprite.x - amount
	elseif string.find(direction, "right") then
		sprite.x = sprite.x + amount
	end
	if checkmapoverlap(sprite, currentcollision) then
		if sprite.pushing then
			sprite.x = oldx
			sprite.y = oldy
			canmove = false
		else
			sprite.y = sprite.y + amount
			if checkmapoverlap(sprite, currentcollision) then
				sprite.y = sprite.y - amount*2
				if checkmapoverlap(sprite, currentcollision) then
					sprite.x = oldx
					sprite.y = oldy
					canmove = false
				end
			end
		end
	end
	return canmove
end

function sprite_hasanimation(sprite, animation)
	for key,value in pairs(sprite.animations) do 
		if animation == sprite.animations[key].name then
			return true
		end
	end
	return false
end

function sprite_setanimation(sprite, animation)
	if sprite.currentanimation ~= animation then
		sprite.currentanimation = animation
		sprite.animationframe = 1
		sprite.timer = 0
	end
end

function sprite_playanimation(sprite)
	if sprite.currentanimation == "" then
		sprite.currentframe = 1
	else
		sprite.timer = sprite.timer + 1
		if sprite.timer >= sprite.animations[sprite.currentanimation].speed[sprite.animationframe] then
			sprite.timer = 0
			sprite.animationframe = sprite.animationframe + 1
			if sprite.animationframe > sprite.animations[sprite.currentanimation].framecount then
				sprite.animationframe = 1
			end
		end
		sprite.currentframe = sprite.animations[sprite.currentanimation].frames[sprite.animationframe]
	end
end

function sprite_addanimation(sprite, animname, frames, speed)
	sprite.animationscount = sprite.animationscount + 1
	sprite.animations[animname] = {}
	sprite.animations[animname].name = animname
	sprite.animations[animname].speed = speed
	sprite.animations[animname].frames = frames
	sprite.animations[animname].framecount = #frames
end

function sprite_draw(sprite)
	if sprite.drawmode == "add" then
		love.graphics.setBlendMode("add")
	end
	if sprite.emotion == "!" then
		sp_exclamation.x = sprite.x-2
		sp_exclamation.y = sprite.y-4
		sprite_draw(sp_exclamation)
	end
	if sprite.status == "burn" then
		love.graphics.setColor(255, 50, 50, 255)
	elseif sprite.status == "poison" then
		love.graphics.setColor(100, 255, 100, 255)
	end

	if foglayer then
		local ox, oy, ow, oh = sprite.frame[sprite.currentframe]:getViewport()
		local topquad = love.graphics.newQuad(ox, oy, ow, oh-fogheight, sprite.artsheet:getWidth(), sprite.artsheet:getHeight())
		local botquad = love.graphics.newQuad(ox, oy+sprite.height-fogheight, ow, fogheight, sprite.artsheet:getWidth(), sprite.artsheet:getHeight())
		--local topquad = love.graphics.newQuad(0, 0, sprite.width, sprite.height-fogheight, tmpcanvas:getWidth(), tmpcanvas:getHeight())
		--local botquad = love.graphics.newQuad(0, sprite.height-fogheight, sprite.width, fogheight, tmpcanvas:getWidth(), tmpcanvas:getHeight())
		
		--love.graphics.setCanvas(tmpcanvas)
		--love.graphics.clear()
		--love.graphics.draw(sprite.artsheet, sprite.frame[sprite.currentframe])
		
		--draw above fog
		love.graphics.setCanvas(toplayer)
		love.graphics.draw(sprite.artsheet, topquad, math.floor(sprite.x+sprite.width/2), math.floor(sprite.y+sprite.height/2), sprite.rotation, sprite.scalex, sprite.scaley, sprite.width/2, sprite.height/2)		
		--draw below fog
		love.graphics.setCanvas(bottomlayer)
		love.graphics.draw(sprite.artsheet, botquad, math.floor(sprite.x+sprite.width/2), math.floor(sprite.y+sprite.height/2)+sprite.height-fogheight, sprite.rotation, sprite.scalex, sprite.scaley, sprite.width/2, sprite.height/2)
		--
		love.graphics.setCanvas(canvas)
	else
		love.graphics.draw(sprite.artsheet, sprite.frame[sprite.currentframe], math.floor(sprite.x+sprite.width/2), math.floor(sprite.y+sprite.height/2), sprite.rotation, sprite.scalex, sprite.scaley, sprite.width/2, sprite.height/2)
	end
	love.graphics.setColor(255, 255, 255, 255)
	if sprite.drawmode == "add" then
		love.graphics.setBlendMode("alpha")
	end
end

function sprite_drawhitbox(sprite)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", sprite.x + sprite.boundsx, sprite.y+sprite.boundsy, sprite.boundswidth, sprite.boundsheight)
end

--collision
function checkgroupoverlap(sprite, group)
	for i=1,#group do
		if checkoverlap(sprite, group[i]) then
			--dont check for itself
			if sprite.uid ~= group[i].uid then
				return i
			end
		end
	end
	return false
end

function checkoverlap(sprite1, sprite2)
	local s1x = sprite1.x + sprite1.boundsx
	local s1y = sprite1.y + sprite1.boundsy
	local s2x = sprite2.x + sprite2.boundsx
	local s2y = sprite2.y + sprite2.boundsy
	if 	s1x < s2x+sprite2.boundswidth and 
		s1x+sprite1.boundswidth > s2x and 
		s1y < s2y + sprite2.boundsheight and 
		s1y + sprite1.boundsheight > s2y then
		return true
	else
		return false
	end
end

function checkmapoverlap_pure(sprite, map)
	local sx = sprite.x + sprite.boundsx
	local sy = sprite.y + sprite.boundsy 
	if sx <= 0 then
		return true
	elseif sy <= 0 then
		return true
	elseif sx + sprite.boundswidth > #map then
		return true
	elseif sy + sprite.height-24 > #map[1] then
		return true
	end
	for x=0,sprite.boundswidth do
		for y=0,sprite.boundsheight do
			local curval = map[math.floor(sx+x)][math.floor(sy+y)]
			if curval == "solid" then
				return true
			elseif curval == "climb" then
				return true
			elseif curval == "hooks" then
				return true
			end
		end
	end
	--also check for unwalkable sprites in npcgroup
	local grouphit = checkgroupoverlap(sprite, npcgroup)
	if grouphit ~= false then
		--solid object check
		if npcgroup[grouphit].solid then
			return true
		end
	end
	return false	
end

function checkmapoverlap(sprite, map)
	local sx = sprite.x + sprite.boundsx
	local sy = sprite.y + sprite.boundsy 
	if sx <= 0 then
		return true
	elseif sy <= 0 then
		return true
	elseif sx + sprite.boundswidth > #map then
		return true
	elseif sy + sprite.height-24 > #map[1] then
		return true
	end
	for x=0,sprite.boundswidth do
		for y=0,sprite.boundsheight do
			local curval = map[math.floor(sx+x)][math.floor(sy+y)]
			if curval == "solid" then
				return true
			elseif curval == "climb" then
				sprite.currentmovespeed = 1
				sprite.climbing = true
			elseif curval == "hooks" and sprite.hooks == true then
				sprite.climbing = true
			elseif curval == "hooks" and sprite.hooks == false then
				return true
			else
				sprite.climbing = false
			end
		end
	end
	--also check for unwalkable sprites in npcgroup
	local grouphit = checkgroupoverlap(sprite, npcgroup)
	if grouphit ~= false then
		--enemies dont walk into other enemies
		if npcgroup[grouphit].type == "enemy" and sprite.type == "enemy" then
			return true
		end
		if npcgroup[grouphit].solid then
			if npcgroup[grouphit].type == "push1" and sprite.canpush and find_direction() then
				sprite.pushing = true
				sprite.pushdir = find_pushdir(npcgroup[grouphit])
				sprite.currentmovespeed = .25
				sprite_movement(npcgroup[grouphit], find_pushdir(npcgroup[grouphit]), sprite.currentmovespeed)
			end
			return true
		end
	end
	return false
end

function findangle(sprite1, sprite2)
	local s1x = sprite1.x + sprite1.width/2
	local s1y = sprite1.y + sprite1.height/2
	local s2x = sprite2.x + sprite2.width/2
	local s2y = sprite2.y + sprite2.height/2

	local dy = s1y-s2y 
	local dx = s1x-s2x
	return math.atan2(dy,dx)
end

function find_dir_2points(sprite1, sprite2)
	--return an 8-way direction

	--use centered values
	local s1x = sprite1.x + sprite1.width/2
	local s1y = sprite1.y + sprite1.height/2
	local s2x = sprite2.x + sprite2.width/2
	local s2y = sprite2.y + sprite2.height/2

	local dy = s1y-s2y 
	local dx = s1x-s2x
	local angle = math.atan2(dy,dx) * 180 / math.pi
	angle = angle + 180 - 22

	if angle <= 45 then
		return "downright"
	elseif angle <= 90 then
		return "down"
	elseif angle <= 135 then
		return "downleft"
	elseif angle <= 180 then
		return "left"
	elseif angle <= 225 then
		return "upleft"
	elseif angle <= 270 then
		return "up"
	elseif angle <= 315 then
		return "upright"
	else
		return "right"
	end
end

function find_4way_dir(dir)
	if string.find(dir, "left") then
		return "left"
	elseif string.find(dir, "right") then
		return "right"
	elseif string.find(dir, "up") then
		return "up"
	elseif string.find(dir, "down") then
		return "down"
	end
end

--camera
function get_cameracoords(obj)
	local cx = obj.x - screen.width/2
	local cy = obj.y - screen.height/2
	--bounds
	if cx < 0 then cx = 0 end
	if cy < 0 then cy = 0 end
	if cx > currentmap.width - screen.width then cx = currentmap.width - screen.width end
	if cy > currentmap.height - screen.height then cy = currentmap.height - screen.height end
	return cx, cy
end

function camera_center(obj)
	local cx = obj.x - screen.width/2
	local cy = obj.y - screen.height/2
	--bounds
	if cx < 0 then cx = 0 end
	if cy < 0 then cy = 0 end
	if cx > currentmap.width - screen.width then cx = currentmap.width - screen.width end
	if cy > currentmap.height - screen.height then cy = currentmap.height - screen.height end		
	love.graphics.translate(-cx, -cy)
end

--tileset management
function load_tileset(mapfile)
	local retval = {}
	local height = 0
	for line in love.filesystem.lines(mapfile) do
		table.insert(retval, explode(line, ","))
		height = height + 16
	end
	local width = #retval[1]*16
	return retval, width, height
end

function get_tilemapbatch(map, art)
	--spritebatch it all first
	local tsbatch = love.graphics.newSpriteBatch(art, 50000, "static")
	for row=1, #map do
		for col=1, #map[row] do
			local thistile = love.graphics.newQuad(map[row][col]*16, 0, 16, 16, art:getWidth(), art:getHeight())
			local id = tsbatch:add(thistile, col*16-16, row*16-16)
		end
	end
	return tsbatch
end

function generatecollision(infile)
	local cmap = love.image.newImageData(infile)
	local retval = {}
	for x=0,cmap:getWidth()-1 do
		retval[x] = {}
		for y=0,cmap:getHeight()-1 do
			r,g,b,a = cmap:getPixel(x, y)
			if r == 255 and b == 255 and g == 255 then
				--unpassable
				retval[x][y] = "solid"
			elseif r == 255 and b == 0 and g == 0 then
				--climbing, needs hooks
				retval[x][y] = "hooks"
			elseif r == 255 and b == 0 and g == 255 then
				--climbing
				retval[x][y] = "climb"
			else
				retval[x][y] = false
			end
		end
	end
	return retval
end

function internal_savegame(savetable, savefile)
	love.filesystem.createDirectory(love.filesystem.getSaveDirectory())
	file = love.filesystem.getSaveDirectory().."/"..savefile
	writestring = ""
	for i=1,#savetable do
		writestring = writestring..savetable[i].."\n"
	end
	
	if love.filesystem.write(file, writestring) then
		return true
	else
		return false
	end
end

function internal_loadgame(loadfile)
	local retval = {}
	for line in love.filesystem.lines(love.filesystem.getSaveDirectory().."/"..loadfile) do
		table.insert(retval, line)
	end
	return retval
end

function stringtobool(arg)
	if arg == "true" then
		return true
	else
		return false
	end
end