
--cut
function cut_init(x, y, direction)
	local sprite = sprite_init("cut", gfx_cut, 16, 16, {4, 4, 16, 16})
	sprite.x = abilitystartx(x, direction)
	sprite.y = abilitystarty(y, direction)
	sprite.direction = direction
	sprite.life = 15
	sprite_addanimation(sprite, "cut", {1, 2}, {5, 5})
	sprite_setanimation(sprite, "cut")
	sprite.scalex = 1.2
	sprite.scaley = 1.2
	sprite.cuts = true
	sprite.rotation = get_rotation(direction)
	return sprite
end

function cut_ai(sprite)
	sprite.scalex = sprite.scalex - 0.01
	sprite.scaley = sprite.scaley - 0.01
	sprite.life = sprite.life - 1
	if sprite.life <= 0 then
		sprite.state = state_removeme
	end
	--cut enemies
	grouphit = checkgroupoverlap(sprite, npcgroup)
	if grouphit ~= false then
		if npcgroup[grouphit].type == "enemy" then
			damage_sprite(npcgroup[grouphit], 1)
		end
		if npcgroup[grouphit].cuttable then
			sprite_setanimation(npcgroup[grouphit], "cut")
			npcgroup[grouphit].solid = false
		end
	end
end


--fire
function fire_init(x, y, direction)
	local sprite = sprite_init("fire", gfx_fire, 24, 24, {4, 4, 16, 16})
	sprite.x = abilitystartx(x, direction)
	sprite.y = abilitystarty(y, direction)
	sprite.direction = direction
	sprite.life = 60
	sprite_addanimation(sprite, "burn", {1, 2}, {5, 5})
	sprite_setanimation(sprite, "burn")
	sprite.scalex = 0.5
	sprite.scaley = 0.5
	sprite.burns = true
	return sprite
end

function fire_ai(sprite)
	if sprite.life%2 == 0 then
		sprite_movement(sprite, sprite.direction, 1)
	end
	sprite.life = sprite.life - 1
	sprite.scalex = sprite.scalex + 0.005
	sprite.scaley = sprite.scaley + 0.005
	if sprite.life <= 0 then
		sprite.state = state_removeme
	end
	--burn enemies
	grouphit = checkgroupoverlap(sprite, npcgroup)
	if grouphit ~= false then
		if npcgroup[grouphit].type == "enemy" then
			statuseffect_burn(npcgroup[grouphit])
		end
	end
end

--bomb

function bomb_init(x, y, direction)
	local sprite = sprite_init("bomb", gfx_bomb, 16, 16, {4, 4, 16, 16})
	sprite.x = abilitystartx(x, direction)
	sprite.y = abilitystarty(y, direction)
	sprite.direction = direction
	sprite.life = 120
	sprite.solid = true
	sprite.growing = true
	return sprite
end

function bomb_ai(sprite)
	if sprite.growing then
		sprite.scalex = sprite.scalex + 0.05
		sprite.scaley = sprite.scaley + 0.05
	else
		sprite.scalex = sprite.scalex - 0.05
		sprite.scaley = sprite.scaley - 0.05
	end
	sprite.life = sprite.life - 1
	if sprite.life % 5 == 0 then
		if sprite.growing then
			sprite.growing = false
		else
			sprite.growing = true
		end
	end
	if sprite.life <= 0 then
		--blow up
		sprite.x = sprite.x - 16
		sprite.y = sprite.y - 16
		sprite.boundswidth = sprite.boundswidth + 32
		sprite.boundsheight = sprite.boundsheight + 32
		for i=1,#npcgroup do
			--check overlap
			if checkoverlap(sprite, npcgroup[i]) then
				if npcgroup[i].type == "enemy" then
					damage_sprite(npcgroup[i], 50)
				elseif npcgroup[i].type == "bombable" then
					log(i.." "..npcgroup[i].id)
					npcgroup[i].solid = false
					sprite_setanimation(npcgroup[i], "explode")
				end
			end
		end
		sprite.state = state_removeme
		explosion_init(sprite.x, sprite.y)
	end
end

