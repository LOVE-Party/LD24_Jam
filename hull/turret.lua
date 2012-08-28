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
		self.facing = e.owner.facing
		self.shooting = e.owner.shooting

		self.pos_x = e.owner.pos_x - 10
		self.pos_y = e.owner.pos_y - 10
	else
		self.facing = math.random
		self.shooting = true
	end
end


function _M:docollision()

end
-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

