--hero class

--init
hero = sprite_init(gfx_pc, 24, 24, {8, 5, 8, 16})
hero.x = 100
hero.y = 100

--add animations
sprite_addanimation(sp_pc, "walk down", {1, 2, 3, 4}, {15, 10, 15, 10})
sprite_addanimation(sp_pc, "walk left", {5}, {15, 10, 15, 10})
sprite_addanimation(sp_pc, "walk right", {6}, {15, 10, 15, 10})
sprite_addanimation(sp_pc, "walk up", {7}, {15, 10, 15, 10})
sprite_addanimation(sp_pc, "idle", {1, 2, 3, 4, 1, 2, 3, 4}, {120, 5, 5, 5, 5, 5, 5, 5})