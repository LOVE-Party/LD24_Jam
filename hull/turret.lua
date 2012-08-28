-------------------------------------------------------------------------
-- [turret.lua]
-- hull.turret
-------------------------------------------------------------------------
local ship = require "ship"

local _M   = {_NAME = "turret", _TYPE = 'module'}
local _MT  = {__index = _M}
local _MMT = {__index = ship}
setmetatable(_M, _MMT)
-------------------------------------------------------------------------

function _M.new(t)
	t = t or {}
	e = ship.new(t)

	e.shooting = true
	e.owner = t.owner or nil
	e.facing = (e.owner and e.owner.facing) or math.random()*math.pi*2
	e.shooting = false

	return setmetatable(e, _MT)
end

function _M:think(dt)
	if e.owner then
		local own     = e.owner
		self.facing   = own.facing
		self.shooting = own.shooting
		self.shot_rate  = own.shot_rate*2 -- thats half the firing rate

		local theta, d = self.hardpoint, 16
		self.pos_x = own.pos_x + math.cos(theta) * d
		self.pos_y = own.pos_y + math.sin(theta) * d
	else
		self.facing = math.random
		self.shooting = true
	end
end


function _M:draw(...)
	local own = self.owner
	if own then
		love.graphics.setColor(0,0,127)
		love.graphics.line(self.pos_x, self.pos_y, own.pos_x, own.pos_y)
		ship.draw(self, ...)
	end
end

function _M:docollision()

end
-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

