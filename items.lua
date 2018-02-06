--[[i
	item inits

	item type
		item
		weapon
		armor
		shield
		ring

	item name
	item price
	item id			- one per type
	item description
	item power

	format
	{id, type, name, description, price, power}

]]
items = {}
function createitem(itemtable)
	itemtable.id = itemtable[1]
	itemtable.type = itemtable[2]
	itemtable.name = itemtable[3]
	itemtable.description = itemtable[4]
	itemtable.price = itemtable[5]
	itemtable.power = itemtable[6]
	table.insert(items, itemtable)
end

--[[
1-8 	items
9-16	weapons
17-24	shields
25-32	armor
33-40	ring
]]

--usable items
createitem({1, "item", "herb", 		"heals wounds", 300, 100})
createitem({2, "item", "herbmix", 	"heals more wounds", 1000, 300})
createitem({3, "item", "wings", 	"return to town", 1111, 0})
createitem({4, "item", "curall", 	"heals status", 500, 0})
createitem({5, "item", "red pill", 	"atk+ for 1 minute", 1, 1})
createitem({6, "item", "blue pill", "def+ for 1 minute", 2, 1})
createitem({7, "item", "pepper", 	"agi+ for 1 minute", 3, 1})
createitem({8, "item", "elixir", 	"full heal", 4, 1})

--weapons
createitem({1, "weapon", "stick", 		"not a dildo", 1, 10})
createitem({2, "weapon", "training", 	"thick, not sharp", 1, 25})
createitem({3, "weapon", "sharp", 		"sharp, not thick", 1, 50})
createitem({4, "weapon", "poison", 		"stab em quick", 1, 60})
createitem({5, "weapon", "fire", 		"not very solid", 1, 65})
createitem({6, "weapon", "shock", 		"electrifying", 1, 70})
createitem({7, "weapon", "ice", 		"really strong ice", 1, 75})
createitem({8, "weapon", "light", 		"light come forth", 1, 120})

--shields
createitem({1, "shield", "log", 		"its just a log", 1, 10})
createitem({2, "shield", "sturdy", 		"a refined log", 1, 15})
createitem({3, "shield", "metal", 		"this ones good", 1, 20})
createitem({4, "shield", "soldier", 	"mass produced", 1, 25})
createitem({5, "shield", "kite", 		"dont fly it", 1, 30})
createitem({6, "shield", "tower", "		real big", 1, 35})
createitem({7, "shield", "magic", 		"does things", 1, 50})
createitem({8, "shield", "light", 		"kinda sci fi huh", 1, 70})

--armor
createitem({1, "armor", "shirt", 		"made from paper", 1, 5})
createitem({2, "armor", "padded", 		"reinforced paper", 1, 10})
createitem({3, "armor", "leather", 		"kinky", 1, 15})
createitem({4, "armor", "scale", 		"dont ask what kind", 1, 20})
createitem({5, "armor", "chainmail", 	"very effective", 1, 30})
createitem({6, "armor", "plate", 		"somewhat restricting", 1, 40})
createitem({7, "armor", "demon", 		"you look scary", 1, 60})
createitem({8, "armor", "magic", 		"fancy stuff!", 1, 90})

--rings
createitem({1, "ring", "attack", 	"atk+ def-", 1, 1})
createitem({2, "ring", "defence", 	"def+ atk-", 1, 1})
createitem({3, "ring", "agility", 	"agix2", 1, 1})
createitem({4, "ring", "shield", 	"hp+", 1, 1})
createitem({5, "ring", "regen", 	"hp regenerates", 1, 1})
createitem({6, "ring", "magic", 	"ability regenerates fast", 1, 1})
createitem({7, "ring", "gold", 		"goldgain+", 1, 1})
createitem({8, "ring", "veteran", 	"expgain+", 1, 1})