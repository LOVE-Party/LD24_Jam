-- requires
local Gamestate = require "lib.gamestate"
local Ship      = require "ship"
local powerup   = require "powerup"

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
local GUI               = love.graphics.newImage("gfx/GUI.png")
local GUI_Top           = love.graphics.newImage("gfx/GUI_Top.png")
local GUI_BarBack       = love.graphics.newImage("gfx/GUI_EmbossedBar.png")
local GUI_GradientBar   = love.graphics.newImage("gfx/GUI_GradientBar.png")
local GUI_Hull_Critical = love.graphics.newImage("gfx/Hull_Critical.png")
local GUI_ScoreBar      = love.graphics.newImage("gfx/GUI_ScoreBar.png")

-- SFX
state.music = love.audio.newSource("sfx/BGM.ogg", 'stream') -- long audio files should be streamed
state.music:setLooping(true)
local SFX_Game_Over = love.audio.newSource("sfx/game_over.ogg", "static") --Gameover


state.player = Ship.new {name = 'player';
	texture = spaceship;
	npc = false;
}

state.gui_hull_critical_timer = 0

function state.player:die(...)
	Ship.die(self, ...)
	
	love.audio.play(SFX_Game_Over)

	state.endtimer = 10
	state.endtype = 'death'
	state.music:stop()
	state.level.scrolling = false
end

state.enemies = {}

-- level data
state.level = {name='default'; height = 15; scroll_speed = 50; scrolling = true;
	data = {
	0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,3,3,3,3,
	3,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,5,4,3,2,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,
	1,1,1,1,1,1,1,1,1,5,6,5,6,5,6,5,6,5,1,1,1,1,1,1,1,1,2,3,4,3,2,3,2,3,4,
	5,5,5,5,5,4,3,2,1,0};
	offset= {
	0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,3,3,3,3,
	3,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,5,4,3,2,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,
	1,1,1,1,1,1,1,1,1,5,6,5,6,5,6,5,6,5,1,1,1,1,1,1,1,1,2,3,4,3,2,3,2,3,4,
	5,5,5,5,5,4,3,2,1,0};
	x = -640;
	entities = {};
	loop_counter = 0;
}
-- allows easy addition of entities to a level
state.level.addentity = function(self, ent)
	assert(ent and ent._TYPE == 'entity', "Can only add entities")
	self.entities[#self.entities+1] = ent
end
state.level.width = #state.level.data;

local score_font = love.graphics.newFont(32)

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
	self.player.shieldmax  = 100 -- and this
	self.player.shield     = self.player.shieldmax
	self.player.state      = 'alive'
	self.player.score      = 0
	self.timer = 0
	self.endtimer = false
	self.level.scrolling = true

	-- reset the level
	self.level.x = -800
	-- bind enemies/entities to level
	-- (a preliminary to reorganising to have a separate level class)
	self.level.entities = self.enemies

	-- Populate the world with a few random enemies, for testing.
	local enemies = self.enemies
	for i = 1, 5 do
		enemies[i] = Ship.new {name = string.format("Enemy#%03d", i);
			pos_x = math.random(0, 800);
			pos_y = math.random(0, 600);
			texture = Enemy2;
		}
	end
	
	for x = 1, #self.level.data do
		self.level.data[x] = math.random(5)
		self.level.offset[x] = math.floor(math.sin(x / 8) * 3)
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
	assert(e and e._TYPE == 'entity', "Can only add entities")
	self.enemies[#self.enemies+1] = e
end

function state:update(dt)
	self.timer = self.timer + dt
	local level = state.level

	if self.endtimer and self.endtimer > 0 then
		print(string.format("End timer (%fs)", self.endtimer))
		self.endtimer = self.endtimer - dt
		if self.endtimer <= 0 then
			assert(self.endtype, "We don't have an endgame kind")
			self:endgame(self.endtype)
		end
	end

	if level.scrolling then
		level.x = level.x + level.scroll_speed * dt
	end

	-- spawn additional enemies, to keep the level populated.
	if self.timer >= 3 then
		self.timer = 0
		local e
		self:addentity(Ship.new{
			name = string.format("Enemy#%03d", #self.enemies);
			pos_x = math.random(SCREEN_WIDTH/2, SCREEN_WIDTH);
			pos_y = math.random(0, SCREEN_HEIGHT);
			texture = Enemy2;
		})
		self:addentity(powerup.getRandomPowerup{
			pos_x = math.random(SCREEN_WIDTH/2, SCREEN_WIDTH);
			pos_y = math.random(0, SCREEN_HEIGHT);

		})
	end
	
	-- Loop level
	if level.x > level.width * 32 then
		level.x = -800
		
		level.loop_counter = level.loop_counter + 1
		
		self:addentity(powerup.new{
			effect = 'heal60';
			pos_x = math.random(SCREEN_WIDTH/2, SCREEN_WIDTH);
			pos_y = math.random(0, SCREEN_HEIGHT);
		})
		
		self:addentity(powerup.getRandomPowerup())
	end
	
	--Randomize tile when you are past it
	if level.x / 32 > 15 and level.x / 32 < #self.level.data + 15 then
		self.level.data[math.floor((level.x / 32) - 15)] = math.random(5)
		self.level.offset[math.floor((level.x / 32) - 15)] = math.floor(math.sin(math.floor((level.x / 32) - 15) / (8 - (level.loop_counter % 4))) * 3)
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
				player:collidewith(ship, dt)
				ship:collidewith(player, dt)
			end
			-- with a mutual test, each entity only has to be tested against
			-- the entities that come after it.
			for j=i+1,#enemies do
				oship = enemies[j]
				if ship:testcollision(oship) then
					ship:collidewith(oship, dt)
					oship:collidewith(ship, dt)
				end
			end
			-- as a crude hack, we'll simply remove entities that are dead.
			if ship.state == 'dead' then
				table.remove(enemies, i)
			end
		end
	end

	-- Flash GUI stuff
	self.gui_hull_critical_timer = self.gui_hull_critical_timer + dt
	if self.gui_hull_critical_timer >= 1 then
		self.gui_hull_critical_timer = 0
	end

	-- Add to score
	if self.player.state ~= "dead" then
		self.player.score = self.player.score + 2*dt
	end
end

function state:keypressed(key)
	self.player:keypressed(key)
end

function state:keyreleased(key)
	self.player:keyreleased(key)
end

function state:draw()
	local lg = love.graphics
	local level = self.level

	lg.setColor(255, 255, 255)

	lg.draw(BKG, - level.x / 2 % 800, 0)
	lg.draw(BKG, - level.x / 2 % 800 - 800, 0)
	
	lg.draw(Planet, - level.x / 1.5 % 1600 - 128, 200)
	
	self:drawlevel()

	self.player:draw()

	-- Loop over all the Entities, and have them draw themselves.
	for _, ship in next, self.enemies do
		ship:draw()
	end
	
	-- draw the gui frame, and healthbar.
	lg.setColor(255,255,255)
	lg.draw(GUI,0,480)
	lg.draw(GUI_Top,0,0)
	lg.draw(GUI_BarBack,3,3)
	local HealthBarWidth = self.player.shield / self.player.shieldmax
	lg.drawq(GUI_GradientBar, HealthBarQuadCache[HealthBarWidth],3,3)

	if HealthBarWidth <= 0.2 then
		if self.gui_hull_critical_timer <= 0.5 then
			love.graphics.setColor(255, 255, 255, 64)
		end
		lg.draw(GUI_Hull_Critical, 32, 490, 0, 1.0, 0.73)
	end

	lg.setColor(255, 255, 255, 255)
	lg.draw(GUI_ScoreBar, 485, 500, 0, 1.5, 1.5)
	lg.setFont(score_font)
	lg.setColor(0, 255, 0)
	lg.print(("Score: %08d"):format(self.player.score), 500, 500)
end

function state:drawlevel()
	local level = self.level

	for x=1, level.width do
		for y=-6, level.data[x] do
			love.graphics.draw(dirt,(x*32) - level.x ,(y + level.offset[x])*32)
			love.graphics.draw(dirt,(x*32) - level.x ,(level.height - y + level.offset[x]) * 32)

			if y == level.data[x] then
				love.graphics.draw(dirtbottom,(x*32) - level.x ,(y + level.offset[x])*32)
				love.graphics.draw(grass,(x*32) - level.x ,(level.height - y + level.offset[x]) * 32)
			end
		end
	end
end


function state:endgame(kind)
	assert(kind, "Cant end the game with no end kind!")
	print("endgame kind", kind)
	if kind == 'death' or kind == 'fail' then
		Gamestate.missionover:settype('fail')
		Gamestate.switch(Gamestate.missionover)
	else
		Gamestate.missionover:settype('other')
		Gamestate.switch(Gamestate.missionover)
	end
end
