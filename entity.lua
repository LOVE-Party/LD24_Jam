-------------------------------------------------------------------------
-- [entity.lua]
-- entity
-------------------------------------------------------------------------
local _M  = {_NAME = "entity", _TYPE = 'module'}
local _MT = {__index = _M}
-------------------------------------------------------------------------
local count = 0
local SFX_Explosion = love.audio.newSource("sfx/Explosion.wav", "static")

-------------------------------------------------------------------------

-- Handles some texture properties
function _M.set_texture(self, texture)
	self.texture = texture
	self.width   = texture:getWidth()
	self.height  = texture:getHeight()
end

local generic_icon = love.graphics.newImage("gfx/AutoTurret.png")
-------------------------------------------------------------------------

function _M.new(t)
	t = t or {}
	local e = {}

	e._TYPE  = 'entity'	
	e.kind   = t.kind   or 'thing'
	e.name   = t.name   or string.format('entity#%d', count)
	e.id     = count


	e.pos_x  = t.pos_x  or 0
	e.pos_y  = t.pos_y  or 0
	e.dir_x  = t.dir_x  or 0
	e.dir_y  = t.dir_y  or 0
	e.speed  = t.speed  or 0
	e.facing = t.facing or 0
	e.scale  = t.scale  or 1

	-- Handles the texture, width, and height fields
	_M.set_texture(e, t.texture or generic_icon)

	e.state     = t.state     or 'alive'
	e.shieldmax = t.shieldmax or 100
	e.shield    = t.shield    or e.shieldmax
	e.damage    = t.damage    or e.shieldmax *.3
	e.radius    = t.radius    or (e.height + e.width)/2
	

	count = count + 1

	return setmetatable(e, _MT)
end

-------------------------------------------------------------------------

function _M:think(dt)

end

-------------------------------------------------------------------------

function _M:update(dt)
	local dv = self.speed * dt
	self.pos_x = self.pos_x + (self.dir_x * dv)
	self.pos_y = self.pos_y + (self.dir_y * dv)
	
	self:think(dt)
end

-- returns the distance between this entity, and the given entity.
function _M:distance(e)
	local a = math.abs(self.pos_x - e.pos_x)^2
	local b = math.abs(self.pos_y - e.pos_y)^2
	return math.sqrt(a+b)
end

-- tests if this entity, and the given entity, have collided.
function _M:testcollision(e)
	return self:distance(e) <= self.radius+e.radius
end

function _M:draw()
	assert(self, "We have no self, so I really don't know how you expect this to work.")

	local tau = math.pi*2
	local hpratio = self.shield / self.shieldmax
	local lg = love.graphics
	lg.push()
	
	-- draw health-indicators
	lg.setColor(0,0, 127)
	lg.circle('line', self.pos_x, self.pos_y, self.radius)
	lg.setColor(255-(255*hpratio), 255*hpratio, 0)
	lg.arc('line', self.pos_x, self.pos_y, self.radius, 0, hpratio*tau)

	-- draw the actual sprite
	lg.setColor(255, 255, 255)
	lg.draw(self.texture, self.pos_x, self.pos_y, self.facing, self.scale, self.scale, self.width/2, self.height/2)
	lg.pop()
end

-- damages the entity according to the given number, 
-- and tests / triggers death if appropriate
function _M:dohit(n)
	n = n or 1
	assert(n > 0, "Cannot hurt for negative damage")

	local shield = self.shield - n
	shield = shield >= 0 and shield or 0
	shield = shield <= self.shieldmax and shield or self.shieldmax
	self.shield = shield
	love.audio.play(SFX_Explosion) -- shouldn't this be using the soundmanager?

	if shield == 0 and self.state ~= 'dead'then
		self:die()
	end

	return shield
end

-- handles the death of the entity.
function _M:die()
	self.state = 'dead'
	self.shooting = false
	self.dir_x = 0
	self.dir_y = 0
end

function _M:heal(n)
	n = n or 1
	assert(n > 0, "Cannot heal for negative health")

	local shield = self.shield
	shield = shield + n
	shield = shield >= 0 and shield or 0
	shield = shield <= self.shieldmax and shield or self.shieldmax
	self.shield = shield
end

function _M:collidewith(e, dt)
	assert(e, "Can't collide with nothing!")
	e:dohit(self.damage*dt)
end

-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

