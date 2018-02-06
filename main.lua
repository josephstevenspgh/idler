-- i d l e r
-- made by setz @splixel on twitter

--maped = true
testbed = true

--[[
	notes/media/storage/Programs/programming/love/test game
]]

function love.load()
	love.math.setRandomSeed(50000)

	love.filesystem.setIdentity("i d l e r")
	--setzlib
	require("setzlib")

	--load art/map/sound assets
	require("loader")

	--sprites
	require("dirtybumper")

	--game states
	if maped then
		require("maped")
	else
		require("ingame")
	end
	--substates
	require("shop")
	require("pausemenu")

	require("titlescreen")
	gamestate_ingame = 0
	gamestate_title = 1

	--screen size and scaling
	screen = {}
	screen.width = 320
	screen.height = 180
	scaleamount = 3
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	-- scale with a canvas, not with scale()
	canvas = love.graphics.newCanvas(320, 180)
	
	--ingame init




	--initial game state
	if testbed then 
		gamestate = gamestate_testbed
	else
		gamestate = gamestate_title
	end

	previousstate = 0
	nextstate = 0

   	love.graphics.setFont(font_classic)
	nextspriteid = 0
	init_titlescreen()

	--menus
	menuposx = 0
	menuposy = 0

	--options
	textspeed = 3
	musiclevel = 4
	sfxlevel = 5

	--buttonconfig
	buttonnames = {"action", "cancel", "pause"}

	joysticks = get_joysticks()

	--control vars
	pause_button = init_button("return")
	action_button = init_button("z")
	cancel_button = init_button("x")
	up_button = init_button("up")
	down_button = init_button("down")
	left_button = init_button("left")
	right_button = init_button("right")
	--default joypad controls
	button_add_joypad_button(pause_button, joysticks[1], 8)
	button_add_joypad_button(action_button, joysticks[1], 3)
	button_add_joypad_button(cancel_button, joysticks[1], 1)
	button_add_joypad_hat(up_button, joysticks[1], 1, "u")
	button_add_joypad_hat(down_button, joysticks[1], 1, "d")
	button_add_joypad_hat(left_button, joysticks[1], 1, "l")
	button_add_joypad_hat(right_button, joysticks[1], 1, "r")

	buttons = {}
	table.insert(buttons, pause_button)
	table.insert(buttons, action_button)
	table.insert(buttons, cancel_button)
	table.insert(buttons, down_button)
	table.insert(buttons, up_button)
	table.insert(buttons, left_button)
	table.insert(buttons, right_button)

	if testbed then
		init_testbed()
	end
end

function love.update(dt)
	control_mechanics()
	if gamestate == gamestate_ingame then
		update_ingame()
	elseif gamestate == gamestate_title then
		update_titlescreen()
	elseif gamestate == gamestate_testbed then
		update_testbed()
	end
end

function love.draw()
	love.graphics.setCanvas(canvas)
	if gamestate == gamestate_ingame then
		draw_ingame()
	elseif gamestate == gamestate_title then
		draw_titlescreen()
	elseif gamestaet == gamestate_testbed then
		draw_testbed()
	end
	love.graphics.setCanvas()
	love.graphics.draw(canvas, 0, 0, 0, scaleamount)
end

function love.quit()
	print("i d l e r")
end

--controls
function control_mechanics()
	for i=1,#buttons do
		button_mechanics(buttons[i])
	end
end

--menus
function menu_controls(xamount, yamount)
	if left_button.justpressed then
		menuposx = menuposx - 1
	elseif right_button.justpressed then
		menuposx = menuposx + 1
	end
	if up_button.justpressed then
		menuposy = menuposy - 1
	elseif down_button.justpressed then
		menuposy = menuposy + 1
	end

	--wrap
	if menuposx < 0 then
		menuposx = xamount - 1
	elseif menuposx > xamount - 1 then
		menuposx = 0
	end

	if menuposy < 0 then
		menuposy = yamount - 1
	elseif menuposy > yamount - 1 then
		menuposy = 0
	end
end

--test shit

function init_testbed()
	money = 50
	bars = {}

	for i=1,20 do
   		local barwidth = 100
		local fgbar = bar_init(gfx_bar_pink, barwidth, 0, 1, 1, 1)
		local bgbar = bar_init(gfx_bar_purple, barwidth, barwidth, 1, 1, 2)
		bars[i] = healthbar_init(fgbar, bgbar)
		bars[i].active = false
		bars[i].name = ""
		bars[i].progress = 0
		bars[i].strength = 1
		bars[i].flavor = ""
	end

	bars[1].name = "take a penny"
	bars[1].flavor = "only a man with no\nmorals would even\nconsider this."
	bars[1].active = false
	bars[1].strength = 1
	bars[1].reward = 10
	bars[1].unlockcost = 10
	bars[1].rewardcost = 20
	bars[1].speedcost = 20

	bars[2].name = "steal candy"
	bars[2].flavor ="i'm not saying a baby\nhad this, but.."
	bars[2].active = false
	bars[2].strength = 1
	bars[2].reward = 100
	bars[2].unlockcost = 50
	bars[2].rewardcost = 100
	bars[2].speedcost = 100

	bars[3].name = "pickpocket"
	bars[3].active = false
	bars[3].strength = 1
	bars[3].reward = 1000
	bars[3].unlockcost = 500
	bars[3].rewardcost = 1000
	bars[3].speedcost = 1000

	bars[4].name = "sell body"
	bars[4].active = false
	bars[4].strength = 1
	bars[4].reward = 5000
	bars[4].unlockcost = 3000
	bars[4].rewardcost = 6000
	bars[4].speedcost = 6000

	bars[5].name = "id theft"
	bars[5].active = false
	bars[5].strength = 1
	bars[5].reward = 10000
	bars[5].unlockcost = 10000
	bars[5].rewardcost = 20000
	bars[5].speedcost = 20000

	bars[6].name = "steal car"
	bars[6].active = false
	bars[6].strength = 1
	bars[6].reward = 25000
	bars[6].unlockcost = 50000
	bars[6].rewardcost = 100000
	bars[6].speedcost = 100000

	bars[7].name = "talk in theater"
	bars[7].active = false
	bars[7].strength = 1
	bars[7].reward = 50000
	bars[7].unlockcost = 150000
	bars[7].rewardcost = 300000
	bars[7].speedcost = 300000

	bars[8].name = "take 2 pennies"
	bars[8].active = false
	bars[8].strength = 1
	bars[8].reward = 100000
	bars[8].unlockcost = 1000000
	bars[8].rewardcost = 2000000
	bars[8].speedcost = 2000000
end

function update_testbed()

	local unlocked = 0
	for i=1,#bars do
		if bars[i].active then
			unlocked = unlocked + 1
		end
	end
	if unlocked*2+1 > 16 then
		menu_controls(0, 16)
	else
		menu_controls(0, unlocked*2+1)
	end
	for i=1,#bars do
		if bars[i].active then
			bars[i].progress = bars[i].progress + (bars[i].strength * .001)
			if bars[i].progress >= 1 then
				bars[i].progress = 0
				money = money + bars[i].reward
			end
			--move bars
			healthbar_changewidthp(bars[i], bars[i].progress)
		end
	end
end

function draw_testbed()
	--fill black
	love.graphics.setColor(30, 0, 50)
	love.graphics.rectangle("fill", 0, 0, 320, 180)
	love.graphics.setColor(255, 255, 255)

	lprint("exciting crime idle", 2, 2)


	--unlocked
	local unlocked = 0
	for i=1,#bars do
		if bars[i].active then
			unlocked = unlocked + 1
		end
	end
	for i=1,unlocked do
		if bars[i].active then
			lprint(bars[i].name, 12, i*20)
			healthbar_draw(bars[i], 12, i*20+8)
		end
	end
	lprint(bars[unlocked+1].name, 12, unlocked*20+20)
	lprint(">", 4, menuposy*10+20)
	lprint("money: "..money, 180, 2)

	--flavor
	activebar = math.floor(menuposy/2)+1
	lprint(bars[activebar].name, 140, 20)
	lprint(bars[activebar].flavor, 150, 30)

	--check for unlocks
	if menuposy+1 == unlocked*2+1 then
		lprint("unlock this scam\n"..bars[unlocked+1].unlockcost.." moneys", 150, 60)
	end

	--display upgrade info

	if menuposy % 2 == 0 then
		if bars[activebar].active then
			--upgrade reward
			lprint("increase reward", 150, 60)
			lprint("cost: "..bars[activebar].rewardcost, 150, 70)
			lprint("currently: "..bars[activebar].reward, 150, 80)
		end
	else
		--upgrade speed
		lprint("increase speed", 150, 60)
		lprint("cost: "..bars[activebar].speedcost, 150, 70)
		lprint("currently: "..bars[activebar].strength, 150, 80)
	end

	if action_button.justpressed or cancel_button.pressed then
		--do something
		if menuposy % 2 == 0 then
			if bars[activebar].active then
				--upgrade reward
				if money >= bars[activebar].rewardcost then
					money = money - bars[activebar].rewardcost
					bars[activebar].reward = bars[activebar].reward + math.floor(bars[activebar].reward * .1) + 1
					bars[activebar].rewardcost = math.floor(bars[activebar].rewardcost * 1.25) + 1
				end
			else
				--unlock
				if money >= bars[activebar].unlockcost then
					money = money - bars[activebar].unlockcost
					bars[activebar].active = true
				end
			end
		else
			--upgrade speed
			if money >= bars[activebar].speedcost then
				money = money - bars[activebar].speedcost
				bars[activebar].strength = bars[activebar].strength + 1
				bars[activebar].speedcost = math.floor(bars[activebar].speedcost * 1.25) + 1
			end
		end
	end

	local cps = ((bars[activebar].strength / 60) * bars[activebar].reward)
	local tcps = 0
	for i=1,#bars do
		if bars[i].active then
			tcps = tcps + ((bars[i].strength / 60) * bars[i].reward)
		end
	end

	lprint("crime mps: "..cps, 140, 160)
	lprint("total mps: "..tcps, 140, 170)
end