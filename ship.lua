local Gamestate = require "lib.gamestate"
local Bullet = require "weapon"
local entity = require "entity"

local _M   = {} -- Module
local _MT  = {__index = _M } -- Metatable
local _MMT = {__index = entity} -- Module Metatable
local ship = setmetatable(_M, _MMT)

-- sound effects, all one of them
local SFX_Explosion = love.audio.newSource("sfx/Explosion.wav", "static")

-- creates a new entity
function ship.new(t)
	t = t or {}
	local e = entity.new(t)
	
	e.kind      = 'ship'

	e.name      = t.name or string.format('ship#%d', e.id)
	e.shieldmax = t.shieldmax or 100
	e.shield    = t.shield    or e.shieldmax
	e.speed     = t.speed     or 100
	e.damage    = t.damage    or e.shieldmax *.3
	e.state     = t.state     or 'alive'

	e.radius  = t.radius or e.height

	e.npc       = t.npc == nil and true or t.npc
	e.dir_timer = t.dir_timer or 0

	e.entities   = t.entities or {}
	e.shooting   = false
	e.shot_rate  = t.shot_rate or 0.2 -- time between shots in seconds.
	e.shot_timer = 0

	return setmetatable(e, _MT)
end

-- draws the entity
function ship:draw()
	for i, entity in next, self.entities do
		love.graphics.draw(entity.texture, entity.pos_x, entity.pos_y)
	end

	entity.draw(self)
end

function ship:think(dt)
	if self.npc then
		self.dir_timer = self.dir_timer + dt
		-- turn change directions
		if self.dir_timer > 1 then
			self.dir_timer = 0
			self.dir_x = math.random(-1, 1)
			self.dir_y = math.random(-1, 1)
		end
	end
end

-- updates the entity according the to time passed (in seconds)
function ship:update(dt, level)
	local dv = self.speed * dt
	self.pos_x = self.pos_x + (self.dir_x * dv)
	self.pos_y = self.pos_y + (self.dir_y * dv)

	self:docollision(level, dt)

	self:think(dt)

	-- Shoot lazers
	self.shot_timer = self.shot_timer + dt
	if self.shooting and self.shot_timer >= self.shot_rate then
		self.shot_timer = 0
		self:shoot()
	end
	-- Update entities
	for i, entity in next, self.entities do
		if entity.type == "bullet" then
			-- Move bullet bullet
			entity.pos_x = entity.pos_x + entity.speed * dt
			-- Remove off-screen bullets
			if entity.pos_x <= 0 or
			   entity.pos_x + entity.width >= SCREEN_WIDTH then
				self.entities[i] = nil
			end
			-- Hit things
			for _, ship in next, Gamestate.space.enemies do
				if entity:testcollision(ship) then
					ship:dohit(entity.damage)
					self.entities[i] = nil
				end
			end
		end
	end
end

-- handles keyboard button-down events
function ship:keypressed(key)
	if self.state == 'alive' then
		self.dir_x = self.dir_x + (key == "right" and 1 or 0) - (key == "left" and 1 or 0)
		self.dir_y = self.dir_y + (key ==  "down" and 1 or 0) - (key ==   "up" and 1 or 0)
		self.shooting = key == " " or self.shooting
	end
end

-- handles keyboard button-up events
function ship:keyreleased(key)
	if self.state == 'alive' then
		self.dir_x = self.dir_x + (key == "right" and -1 or 0) - (key == "left" and -1 or 0)
		self.dir_y = self.dir_y + (key ==  "down" and -1 or 0) - (key ==   "up" and -1 or 0)
		self.shooting = key ~= " " and self.shooting
	end
end

-- rounds a number to the nearest whole number, or to decimal
local function round(val, decimal)
	if (decimal) then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end

-- handles various collision related events.
-- mostly simply handles self Vs. Level terrain collision atm.
function ship:docollision(level, dt) -- this is new
	-- Keep ship inside play area
	local posy = self.pos_y
	posy = posy <= 32 and 32 or posy
	posy = posy + self.height >= level.height*32 and
	       level.height*32 - self.height or posy
	self.pos_y = posy

	local posx = self.pos_x
	posx = posx <= 0 and 0 or posx
	posx = posx + self.width >= 800 and 800 - self.width or posx
	self.pos_x = posx

	local CurrentTileX = round(posx / 32 + level.x / 32, 0)
	if CurrentTileX > 0 and CurrentTileX < level.width then
		local testtile = math.max(level.data[CurrentTileX], level.data[CurrentTileX+1])
		if posy - self.height < testtile * 32 then
			self:dohit(dt*10)
			self.pos_y = (testtile * 32) + self.height
		elseif posy + self.height > (level.height - testtile) * 32 then
			self:dohit(dt*10)
			self.pos_y = ((level.height - testtile) * 32) - self.height
		end

	end
end

-- handles the death of the entity.
function ship:die()
	entity.die(self)
end

function ship:shoot()
	self.entities[#self.entities+1] = Bullet.new(self)
end

function ship:collidewith(e, dt)
	if e.kind == 'ship' then
		self:dohit(e.damage*dt)
	end
end

-------------------------------------------------------------------------
return ship
