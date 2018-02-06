--load assets

--load art

--classes
gfx_warrior = love.graphics.newImage("runred.png")
gfx_thief = love.graphics.newImage("runblue.png")
gfx_portraits = love.graphics.newImage("sprites/portraits.png")
--stuff
gfx_bar_background_small = love.graphics.newImage("sprites/bars/small_background.png")
gfx_bar_purple = love.graphics.newImage("sprites/bars/purple.png")
gfx_bar_pink = love.graphics.newImage("sprites/bars/pink.png")
gfx_bar_blue_small = love.graphics.newImage("sprites/bars/small_blue.png")
gfx_bar_background = love.graphics.newImage("sprites/bars/background.png")
gfx_bar_red = love.graphics.newImage("sprites/bars/red.png")
gfx_bar_orange_tiny = love.graphics.newImage("sprites/bars/tiny_orange.png")
gfx_cursor = love.graphics.newImage("sprites/cursor.png")
gfx_lighteffect = love.graphics.newImage("sprites/testlight.png")
--interactables
gfx_exclamation = love.graphics.newImage("sprites/exclamation.png")
gfx_rock1 = love.graphics.newImage("sprites/rock.png")
gfx_bombwall = love.graphics.newImage("sprites/bombwall.png")
gfx_bush1 = love.graphics.newImage("sprites/bush.png")
gfx_sign = love.graphics.newImage("sprites/sign.png")
gfx_chest = love.graphics.newImage("sprites/chest.png")
gfx_nullchest = love.graphics.newImage("sprites/nullchest.png")
--cosmetics
gfx_tuft1 = love.graphics.newImage("sprites/deco/grass.png")
gfx_flowers = love.graphics.newImage("sprites/deco/flowers.png")
gfx_flowerl = love.graphics.newImage("sprites/deco/flowerleft.png")
gfx_flowerr = love.graphics.newImage("sprites/deco/flowerright.png")
gfx_tree = love.graphics.newImage("sprites/deco/tree.png")
gfx_waterrock1 = love.graphics.newImage("sprites/deco/waterrock1.png")
gfx_waterrock2 = love.graphics.newImage("sprites/deco/waterrock2.png")
--abilities
gfx_fire = love.graphics.newImage("sprites/fire.png")
gfx_bomb = love.graphics.newImage("sprites/bomb.png")
gfx_cut = love.graphics.newImage("cut.png")
--ui
gfx_hud = love.graphics.newImage("ui.png")
--gfx_textbox = love.graphics.newImage("textbox#tiles.png")
gfx_textbox = love.graphics.newImage("sprites/textbox8#tiles.png")
gfx_itemicons = love.graphics.newImage("itemicons.png")
gfx_weaponicons = love.graphics.newImage("weaponicons.png")
gfx_armoricons = love.graphics.newImage("armoricons.png")
gfx_shieldicons = love.graphics.newImage("shieldicons.png")
gfx_ringicons = love.graphics.newImage("ringicons.png")
gfx_menuicons = love.graphics.newImage("menuicons.png")
gfx_abilityicons = love.graphics.newImage("abilityicons.png")
--enemies
gfx_slime = love.graphics.newImage("slime.png")
gfx_smallslime = love.graphics.newImage("smallslime.png")
gfx_bat = love.graphics.newImage("sprites/bat.png")
gfx_beastman_fighter = love.graphics.newImage("sprites/beastman_fighter.png")
gfx_beastman_scout = love.graphics.newImage("sprites/enemies/beastman_scout.png")
gfx_fireball = love.graphics.newImage("sprites/fireball.png")
--npc
gfx_npc = love.graphics.newImage("sprites/npcs/bad_npc.png")
gfx_oldman = love.graphics.newImage("sprites/npcs/old man.png")
gfx_youngman = love.graphics.newImage("sprites/npcs/young man.png")
gfx_youngwoman = love.graphics.newImage("sprites/npcs/young woman.png")
gfx_girl = love.graphics.newImage("sprites/npcs/girl.png")
gfx_boy = love.graphics.newImage("sprites/npcs/boy.png")
gfx_shopkeep = love.graphics.newImage("sprites/npcs/shopkeep.png")
gfx_beastman_man = love.graphics.newImage("sprites/npcs/beastman villager.png")
gfx_beastman_woman = love.graphics.newImage("sprites/npcs/beastman villager female.png")
--misc
gfx_null = love.graphics.newImage("sprites/null.png")
 
--load fonts
font_classic = love.graphics.newImageFont("ClassicFont.png", "abcdefghijklmnopqrstuvwxyz:.!-,()|?<>\"+0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ/'")
font_damage = love.graphics.newImageFont("damagefont.png", "-1234567890", 1)
font_hud = love.graphics.newImageFont("hudFont.png", "hp0123456789:ex%", 1)

--load sounds
sfx_hit = love.sound.newSoundData("hit.wav")
sfx_win = love.sound.newSoundData("win.wav")
sfx_levelup = love.sound.newSoundData("levelup.wav")
sfx_textblip = love.sound.newSoundData("sfx/textblip.wav")
sfx_alert = love.sound.newSoundData("sfx/alert.wav")