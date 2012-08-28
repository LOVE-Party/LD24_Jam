local entity = require "entity"

local _M   = {}
local _MT  = {__index = _M}
local _MMT = {__index = entity}
setmetatable(_M, _MMT)
Bullet = _M

-- graphics
local GFX_Bullet = love.graphics.newImage("gfx/Bullet.png")

local function set_texture(self, texture)
	self.texture = texture
	self.width   = texture:getWidth()
	self.height  = texture:getHeight()
end

--- Create new bullet
--@param `t` should always be the ship firing the bullet
function Bullet.new(owner, t)
	t = t or {}
	local e = entity.new()

	e.type = 'projectile'
	e.kind = 'bullet'

	e.pos_x  = t.pos_x or owner.pos_x or 0
	e.pos_y  = t.pos_y or owner.pos_y or 0
	e.dir_x  = t.dir_x or 1
	e.dir_y  = t.dir_y or 0
	e.speed  = t.speed or 200;
	e.radius = t.radius or 1;

	set_texture(e, GFX_Bullet)

	e.damage = t.damage or 10;

	return setmetatable(e, _MT)
end

function _M:update(dt)
	entity.update(self, dt)

	self.state = self.pos_x <= 0           and 'remove' or self.state
	self.state = self.pos_x > SCREEN_WIDTH and 'remove' or self.state
end

function _M:collidewith(e, dt)
	assert(e, "Can't collide with nothing!")
	e:dohit(self.damage)
end

return _M
