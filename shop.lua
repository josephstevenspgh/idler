function make_shop()
	--load inventory
	--set up shop
	menuposy = 0
	menuposx = 0

	shopopen = true
	shop = {}
	shop.item = {}
	for i=1,10 do
		shop.item[i] = {}
	end
	shop.item[1] = items[1]
	shop.item[2] = items[2]
	shop.item[3] = items[3]
	shop.item[4] = items[4]
	shop.item[5] = items[5]
	shop.item[6] = items[10]
	shop.item[7] = items[18]
	shop.item[8] = items[25]
	shop.item[9] = items[33]
	shop.item[10] = items[34]
	--textboxes
	shoptitlebg = init_textbox_art(30, 1)
	inventorybg = init_textbox_art(8, 15)
	shopbg = init_textbox_art(25, 15)
end

function shop_update()
	menu_controls(2, 5)
	if action_button.justpressed then
		if canbuy(shop.item[menuposx*5+menuposy+1]) then
			buy(shop.item[menuposx*5+menuposy+1])
		end
	end
	if cancel_button.justpressed then
		shopopen = false
	end
end

function draw_shop()
	--background
	local selitem = shop.item[menuposx*5+menuposy+1]
	love.graphics.draw(shoptitlebg, 32, 8)
	love.graphics.draw(inventorybg, 8, 40)
	love.graphics.draw(shopbg, 96, 40)
	lprint("welcome to shop shop!", 64, 16)
	lprint(selitem.description, 104, 48)
	lprint("item cost: "..selitem.price, 104, 58)
	--note inventory
	local sx, sy = 16, 48
	showicon(4, sx, sy)
	lprint(sp_player.gold, sx+20, sy+4)
	showicon(1, sx, sy+20)
	lprint(get_playerstat(sp_player, "attack"), sx+20, sy+24)
	showicon(2, sx, sy+40)
	lprint(get_playerstat(sp_player, "defence"), sx+20, sy+44)
	showicon(3, sx, sy+60)
	lprint(get_playerstat(sp_player, "agility"), sx+20, sy+64)
	lprint("current", sx, sy+80)
	amountprint(sx, sy+90)
	show_statdiff(selitem, sx, sy)
	--draw items
	sx, sy = 104, 52
	for i=1,5 do
		drawitem(shop.item[i], sx, sy+i*20)
		drawitem(shop.item[i+5], sx+100, sy+i*20)
	end
	--draw cursor
	lprint(">", sx-8+menuposx*100, sy+24+menuposy*20)
end

function drawitem(item, x, y)
	showicon(item.id, x, y, item.type)
	lprint(item.name, x+20, y+4)
end

function show_statdiff(item, sx, sy)
	local oldsword = sp_player.swordequipped
	local oldarmor = sp_player.armorequipped
	local oldshield = sp_player.shieldequipped
	local oldring = sp_player.ringequipped
	local oldattack = get_playerstat(sp_player, "attack")
	local olddefence = get_playerstat(sp_player, "defence")
	local oldagility = get_playerstat(sp_player, "agility")

	if selitem.type == "weapon" then
		sp_player.swordequipped = selitem.id
	elseif selitem.type == "armor" then
		sp_player.armorequipped = selitem.id
	elseif selitem.type == "shield" then
		sp_player.shieldequipped = selitem.id
	elseif selitem.type == "ring" then
		sp_player.ringequipped = selitem.id
	end	
	local newattack = get_playerstat(sp_player, "attack")
	local newdefence = get_playerstat(sp_player, "defence")
	local newagility = get_playerstat(sp_player, "agility")

	local diffattack = newattack - oldattack
	local diffdefence = newdefence - olddefence
	local diffagility = newagility - oldagility
	--print difference
	--attack
	printdiff(diffattack, sx+40, sy+24)
	printdiff(diffdefence, sx+40, sy+44)
	printdiff(diffagility, sx+40, sy+64)
	--defence
	--agility


	--restate equipment
	sp_player.swordequipped = oldsword
	sp_player.armorequipped = oldarmor
	sp_player.shieldequipped = oldshield
	sp_player.ringequipped = oldring
end

function printdiff(diff, x, y)
	if diff > 0 then
		love.graphics.setColor(0,255,0,255)
		lprint("+"..diff, x, y)
		love.graphics.setColor(255,255,255,255)
	elseif diff < 0 then
		love.graphics.setColor(255,0,0,255)
		lprint(diff, x, y)
		love.graphics.setColor(255,255,255,255)
	end
end

function amountprint(x, y)
	selitem = shop.item[menuposx*5+menuposy+1]
	local pval = ""
	if selitem.type == "weapon" then
		if sp_player.swordsowned[selitem.id] then
			pval = "owned"
		else
			pval = "none"
		end
	elseif selitem.type == "armor" then
		if sp_player.armorsowned[selitem.id] then
			pval = "owned"
		else
			pval = "none"
		end
	elseif selitem.type == "shield" then
		if sp_player.shieldsowned[selitem.id] then
			pval = "owned"
		else
			pval = "none"
		end
	elseif selitem.type == "ring" then
		if sp_player.ringsowned[selitem.id] then
			pval = "owned"
		else
			pval = "none"
		end
	elseif selitem.type == "item" then
		pval = sp_player.itemsowned[selitem.id].." owned"
	end
	lprint(pval, x, y)
end

function canbuy(item)
	if sp_player.gold < selitem.price then
		return false
	end

	if selitem.type == "weapon" then
		if sp_player.swordsowned[selitem.id] then
			return false
		end
	elseif selitem.type == "armor" then
		if sp_player.armorsowned[selitem.id] then
			return false
		end
	elseif selitem.type == "shield" then
		if sp_player.shieldsowned[selitem.id] then
			return false
		end
	elseif selitem.type == "ring" then
		if sp_player.ringsowned[selitem.id] then
			return false
		end
	elseif selitem.type == "item" then
		if sp_player.itemsowned[selitem.id] >= 9 then
			return false
		end
	end	
	return true
end

function buy(item)
	sp_player.gold = sp_player.gold - selitem.price
	if selitem.type == "weapon" then
		sp_player.swordsowned[selitem.id] = true
	elseif selitem.type == "armor" then
		sp_player.armorsowned[selitem.id] = true
	elseif selitem.type == "shield" then
		sp_player.shieldsowned[selitem.id] = true
	elseif selitem.type == "ring" then
		sp_player.ringsowned[selitem.id] = true
	elseif selitem.type == "item" then
		sp_player.itemsowned[selitem.id] = sp_player.itemsowned[selitem.id] + 1
	end	
end