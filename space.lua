-- requires
local Gamestate = require "lib.gamestate"
local Ship      = require "ship"

-- create and register this gamestate
local state     = Gamestate.new()
Gamestate.space = state


local spaceship  = love.graphics.newImage("gfx/SpaceShip.png")
local Enemy2     = love.graphics.newImage("gfx/Enemy2.png")

-- Terrain and Background
local dirt       = love.graphics.newImage("gfx/Dirt.png")
local grass      = love.graphics.newImage("gfx/Grass.png")
local dirtbottom = love.graphics.newImage("gfx/DirtBottom.png")
local BKG        = love.graphics.newImage("gfx/BKG.png")
local Planet        = love.graphics.newImage("gfx/Planet.png")

--GUI
local GUI             = love.graphics.newImage("gfx/GUI.png")
local GUI_Top         = love.graphics.newImage("gfx/GUI_Top.png")
local GUI_BarBack     = love.graphics.newImage("gfx/GUI_EmbossedBar.png")
local GUI_GradientBar = love.graphics.newImage("gfx/GUI_GradientBar.png")

-- SFX
state.music = love.audio.newSource("sfx/BGM.ogg")
state.music:setLooping(true)

state.player = Ship.new {name = 'player';
	texture = spaceship;
	npc = false;
}

state.enemies = {}

-- level data
state.level = {name='default'; height = 15; scroll_speed = 50;
	data = { 
	0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,3,3,3,3,
	3,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,5,4,3,2,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,
	1,1,1,1,1,1,1,1,1,5,6,5,6,5,6,5,6,5,1,1,1,1,1,1,1,1,2,3,4,3,2,3,2,3,4,
	5,5,5,5,5,4,3,2,1,0};
	x = -640;
}
state.level.width = #state.level.data;


-- Automatically creates and caches requested widths of the Health/shield
-- bar, given as a fraction (or whole) of 1
local HealthBarQuadCache = setmetatable({}, {
	__index = function(self, n)
		if n < 0 then return self[0] end -- can't have less than none of a bar
		if n > 1 then return self[1] end -- ...or more than all.
		local quad = love.graphics.newQuad(0, 0, n*197, 25, 197, 25)
		self[n] = quad
		return quad
	end;
})


-- Note: state:enter() is called each time we switch to this state (only from
-- the main menu at the moment) so it is not neccessary to load image files here
-- We should only change instance specific things, such as replacing the
-- ships in the default positions
function state:enter()
	-- Reset some player ship defaults
	self.player.pos_x      = 64
	self.player.pos_y      = 320
	self.player.shieldmax = 100 -- and this
	self.player.shield    = self.player.shieldmax
	self.timer = 0

	-- reset the level
	self.level.x = -640
	-- bind enemies/entities to level
	-- (a preliminary to reorganising to have a separate level class)
	self.level.entities = self.enemies
	-- allows easy addition of entities to a level
	self.level.addentity = function(self, ent)
		assert(ent and ent._TYPE == 'ship', "Can only add entities")
		self.entities[#self.entities+1] = ent
	end

	-- Populate the world with a few random enemies, for testing.
	local enemies = self.enemies
	for i = 1, 5 do
		enemies[i] = Ship.new {name = string.format("Enemy#%03d", i);
			pos_x = math.random(0, 800);
			pos_y = math.random(0, 600);
			texture = Enemy2;
		}
	end

	--  Audio
	-- Play some music
	self.music:rewind()
	self.music:play()
end

-- Called when switching away from this Gamestate
function state:leave()
	self.music:stop()
end

-- Allows easy addition of Entities to the Level
function state:addentity(e)
	assert(e and e._TYPE == 'ship', "Can only add entities")
	self.enemies[#self.enemies+1] = e
end

function state:update(dt)
	self.timer = self.timer + dt
	local level = state.level

	level.x = level.x + level.scroll_speed * dt

	-- spawn additional enemies, to keep the level populated.
	if self.timer >= 3 then
		self.timer = 0
		self:addentity(Ship.new{
			name = string.format("Enemy#%03d", #self.enemies);
			pos_x = math.random(0, 800/2);
			pos_y = math.random(0, 600/2);
			texture = Enemy2;
		})
	end
	
	-- Loop level
	if level.x > level.width * 32 then
		level.x = -640
	end

	-- update the Player entity
	self.player:update(dt, level)

	-- Loop through all entities, test and act upon any collisions
	local player, ship, oship = self.player
	local enemies = self.enemies
	for i=1,#enemies do
		ship = enemies[i]
		if ship then
			ship:update(dt, level)
			-- Ideally, the player would be a normal entity, for now we
			--special-case them
			if player:testcollision(ship) then
				player:dohit(ship.damage*dt)
				ship:dohit(player.damage*dt)
			end
			-- with a mutual test, each entity only has to be tested against
			-- the entities that come after it.
			for j=i+1,#enemies do
				oship = enemies[j]
				if ship:testcollision(oship) then
					ship:dohit(oship.damage*dt)
					oship:dohit(ship.damage*dt)
				end
			end
			-- as a crude hack, we'll simply remove entities that are dead.
			if ship.state == 'dead' then
				table.remove(enemies, i)
			end
		end
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

	love.graphics.draw(BKG, - level.x / 2 % 800, 0)
	love.graphics.draw(BKG, - level.x / 2 % 800 - 800, 0)
	
	love.graphics.draw(Planet, - level.x / 1.5 % 1600 - 128, 200)
	
	self:drawlevel()

	self.player:draw()

	-- Loop over all the Entities, and have them draw themselves.
	for _, ship in next, self.enemies do
		ship:draw()
	end
	
	-- draw the gui frame, and healthbar.
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

