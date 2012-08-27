Bullet = {
	speed = 200;
	radius = 1;
	damage = 10;
}
local MT = {__index = Bullet}

-- graphics
local GFX_Bullet = love.graphics.newImage("gfx/Bullet.png")

local function set_texture(self, texture)
	self.texture = texture
	self.width   = texture:getWidth()
	self.height  = texture:getHeight()
end

--- Create new bullet
--@param `t` should always be the ship firing the bullet
function Bullet.new(t)
	local e = {}
	t = t or {}

	e.type = "bullet"
	e.pos_x = t.pos_x
	e.pos_y = t.pos_y

	set_texture(e, GFX_Bullet)

	return setmetatable(e, MT)
end

-- returns the distance between this entity, and the given entity.
function Bullet:distance(e)
	local a = math.abs(self.pos_x - e.pos_x)^2
	local b = math.abs(self.pos_y - e.pos_y)^2
	return math.sqrt(a+b)
end

-- tests if this entity, and the given entity, have collided.
function Bullet:testcollision(e)
	return self:distance(e) <= self.radius+e.radius
end

return Bullet
