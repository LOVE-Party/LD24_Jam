--package.path = package.path .. ";./?/init.lua"

require "lib.gamestate"
require "lib.soundmanager"

require "space"	-- current game stuff


local dbgfont
function love.load()
	--states requires
	-- (included here, to be sure that love.graphics and kin are initialised.)
	require "intro"
	require "smain"
	require "scredits"
	require "smissionover"

	io.stdout:setvbuf("line")

	dbgfont = love.graphics.newFont(10)
	love.graphics.setBackgroundColor(50, 50, 50)

	-- apprently we want these globally,
	-- in which case they belong here, rather than in smain.
	SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getMode()

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

function love.draw()
	do -- Horribly overwrought FPS counter.
		local lt = love.timer
		local lg = love.graphics
		local fps, fdt, avg = lt.getFPS(), lt.getDelta()
		avg = 1/fps
		lg.setFont(dbgfont)
		lg.setColor(255,255,255)
		lg.print(string.format("%03dfps (%4.3fms/frame, last: %4.3fms)", fps, avg, fdt), 5, 5);
	end
end
