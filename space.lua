local Gamestate = require "lib.gamestate"
local Ship      = require "ship"

local state     = Gamestate.new()
Gamestate.space = state


local spaceship  = love.graphics.newImage("gfx/SpaceShip.png")
local Enemy2     = love.graphics.newImage("gfx/Enemy2.png")
local dirt       = love.graphics.newImage("gfx/Dirt.png")
local grass      = love.graphics.newImage("gfx/Grass.png")
local dirtbottom = love.graphics.newImage("gfx/DirtBottom.png")
local BKG        = love.graphics.newImage("gfx/BKG.png")

--GUI
local GUI             = love.graphics.newImage("gfx/GUI.png")
local GUI_Top         = love.graphics.newImage("gfx/GUI_Top.png")
local GUI_BarBack     = love.graphics.newImage("gfx/GUI_EmbossedBar.png")
local GUI_GradientBar = love.graphics.newImage("gfx/GUI_GradientBar.png")

state.player = Ship.new {
	texture = spaceship;
	height = 19;
	npc = false;
}

state.enemies = {}

state.level = {name='default'; height = 15; scroll_speed = 50;
	data = { 
	0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,3,3,3,3,
	3,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,5,4,3,2,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,
	1,1,1,1,1,1,1,1,1,5,6,5,6,5,6,5,6,5,1,1,1,1,1,1,1,1,2,3,4,3,2,3,2,3,4,
	5,5,5,5,5,4,3,2,1,0};
	x = -640;
}
state.level.width = #state.level.data;

local HealthBarQuadCache = setmetatable({}, {
	__index = function(self, n)
		if n < 0 then return self[0] end
		if n > 1 then return self[1] end
		local quad = love.graphics.newQuad(0, 0, n*197, 25, 197, 25)
		rawset(self, n, quad)
		return quad
	end;
})


-- Note: state:enter() is called each time we switch to this state (only from
-- the main menu at the moment) so it is not neccessary to load image files here
-- We should only change instance specific things, such as replacing the
-- ships in the default positions
function state:enter()
	-- Reset some player ship defaults
	self.player.posx      = 64
	self.player.posy      = 320
	self.player.shieldmax = 100 -- and this
	self.player.shield    = self.player.shieldmax

	self.level.x = -640

	local enemies = self.enemies

	for i = 1, 3 do
		enemies[i] = Ship.new {
			pos_x = math.random(0, 800);
			pos_y = math.random(0, 600);
			texture = Enemy2;
			height = 32;
		}
	end
end

function state:update(dt)
	local level = state.level

	level.x = level.x + level.scroll_speed * dt

	-- Loop level
	if level.x > level.width * 32 then
		level.x = -640
	end

	self.player:update(dt, level)

	for _, ship in next, self.enemies do
		ship:update(dt, level)
	end
end

function state:keypressed(key)
	self.player:keypressed(key)
end

function state:keyreleased(key)
	self.player:keyreleased(key)
end

function state:draw()
	local level = self.level

	love.graphics.draw(BKG, - level.x % 800, 0)
	love.graphics.draw(BKG, - level.x % 800 - 800, 0)

	self:drawlevel()

	self.player:draw()

	for _, ship in next, self.enemies do
		ship:draw()
	end
	
	love.graphics.draw(GUI,0,480)
	love.graphics.draw(GUI_Top,0,0)
	love.graphics.draw(GUI_BarBack,3,3)
	local HealthBarWidth = self.player.shield / self.player.shieldmax
	love.graphics.drawq(GUI_GradientBar, HealthBarQuadCache[HealthBarWidth],3,3)
end

function state:drawlevel()
	local level = self.level

	for x=1, level.width do
		for y=1, level.data[x] do
			love.graphics.draw(dirt,(x*32) - level.x ,y*32)
			love.graphics.draw(dirt,(x*32) - level.x ,(level.height - y) * 32)

			if y == level.data[x] then
				love.graphics.draw(dirtbottom,(x*32) - level.x ,y*32)
				love.graphics.draw(grass,(x*32) - level.x ,(level.height - y) * 32)
			end
		end
	end
end
