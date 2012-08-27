-------------------------------------------------------------------------
-- [entity.lua]
-- entity
-------------------------------------------------------------------------
local _M  = {_NAME = "entity", _TYPE = 'module'}
local _MT = {__index = _M}
-------------------------------------------------------------------------

local count = 0


-- Handles some texture properties
local function set_texture(self, texture)
	self.texture = texture
	self.width   = texture:getWidth()
	self.height  = texture:getHeight()
end

-------------------------------------------------------------------------

function _M.new(t)
	t = t or {}
	local e = {}

	e._TYPE  = 'entity'	
	e.kind   = t.kind   or 'thing'
	e.name   = t.name   or string.format('entity#%d', count)
	e.id     = count

	e.pos_x  = t.pos_x or 0
	e.pos_y  = t.pos_y or 0
	e.dir_x  = t.dir_x or 0
	e.dir_y  = t.dir_y or 0

	e.speed  = t.speed  or 0
	e.damage = t.damage or 0
	e.radius = t.radius or 0
	

	-- Handles the texture, width, and height fields
	assert(t.texture, "No texture defined")  -- needed for rendering
	set_texture(e, t.texture)

	count = count + 1

	return setmetatable(e, _MT)
end

-------------------------------------------------------------------------

function _M:think(dt)

end

-------------------------------------------------------------------------

function _M:update(dt)
	local dv = self.speed * dt
	self.x = self.x + (self.dir_x * dv)
	self.y = self.y + (self.dir_y * dv)
	
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
	love.graphics.draw(self.texture, self.pos_x, self.pos_y)
end

-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

