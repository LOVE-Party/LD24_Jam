local ship = {}

local mt = {__index = ship }

local SFX_Explosion = love.audio.newSource("sfx/Explosion.wav", "static")

function ship.new(unit)
	unit.pos_x = unit.pos_x or 0
	unit.pos_y = unit.pos_y or 0

	unit.shield = unit.shield or 100
	unit.speed = unit.speed or 100

	unit.npc = unit.npc == nil and true or unit.npc
	unit.dir_x = 0
	unit.dir_y = 0

	if unit.npc then
		unit.dir_timer = 0
	end

	assert(unit.texture, "No texture defined")  -- needed for rendering
	assert(unit.height, "No height defined")    -- needed for collisions
	return setmetatable(unit, mt)
end

function ship:draw()
	love.graphics.draw(self.texture, self.pos_x, self.pos_y)
end

function ship:update(dt, level)
	self:collision(level)

	self.pos_x = self.pos_x + self.dir_x * self.speed * dt
	self.pos_y = self.pos_y + self.dir_y * self.speed * dt

	if self.npc then
		-- turn change directions
		if self.dir_timer > 1 then
			self.dir_timer = 0
			self.dir_x = math.random(-1, 1)
			self.dir_y = math.random(-1, 1)
		else
			self.dir_timer = self.dir_timer + dt
		end
	end
end

function ship:keypressed(key)
	self.dir_x = key == "right" and 1 or key == "left" and -1 or self.dir_x
	self.dir_y = key ==  "down" and 1 or key ==   "up" and -1 or self.dir_y
end

function ship:keyreleased(key)
	self.dir_x = (key == "right" or key == "left") and 0 or self.dir_x
	self.dir_y = (key ==  "down" or key ==   "up") and 0 or self.dir_y
end

local function round(val, decimal)
	if (decimal) then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end

function ship:collision(level) -- this is new
	local CurrentTileX = round(self.pos_x / 32 + level.x / 32, 0)

	if CurrentTileX > 0 and CurrentTileX < level.width then
		-- Someone refactor these expressions pls
		if self.pos_y < (level.data[CurrentTileX] + 1) * 32 or self.pos_y < (level.data[CurrentTileX + 1] + 1) * 32 then
			self.shield = self.shield - 1
			self.pos_y = self.pos_y + 5

			love.audio.play(SFX_Explosion)
		elseif self.pos_y + self.height > (15 - level.data[CurrentTileX]) * 32 or self.pos_y + self.height > (15 - level.data[CurrentTileX + 1]) * 32 then
			self.shield = self.shield + 1
			self.pos_y = self.pos_y - 5

			love.audio.play(SFX_Explosion)
		end

		if self.pos_y + self.height >= SCREEN_HEIGHT then
			self.pos_y = self.pos_y - 5
		elseif self.pos_y <= 0 then
			self.pos_y = self.pos_y + 5
		end
		if self.pos_x >= SCREEN_WIDTH then
			self.pos_x = self.pos_x - 5
		elseif self.pos_x <= 0 then
			self.pos_x = self.pos_x + 5
		end
	end
end

return ship
