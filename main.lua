--package.path = package.path .. ";./?/init.lua"

require "lib.gamestate"
require "lib.soundmanager"

--states requires
require "intro"

function love.load()
	love.graphics.setBackgroundColor(50, 50, 50)

	--Set Random Seed
	math.randomseed(os.time());
	for i=1,3 do math.random() end

	Gamestate.registerEvents()
	Gamestate.switch(Gamestate[(arg[2] and arg[2]:match("--state=(.+)") or "intro")])
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
