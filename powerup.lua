-------------------------------------------------------------------------
-- [powerup.lua]
-- powerup
-------------------------------------------------------------------------
local entity = require "entity"

local _M   = {_NAME = "powerup", _TYPE = 'module'}
local _MT  = {__index = _M}
local _MMT = {__index = entity}
setmetatable(_M, _MMT)
-------------------------------------------------------------------------
local Image = love.graphics.newImage
icons = {
	generic  = Image "gfx/RepairPack.png";
	heal10  = Image "gfx/RepairPack.png";
	heal30  = Image "gfx/RepairPack2.png";
	heal60  = Image "gfx/RepairPack3.png";
	heal100 = Image "gfx/RepairPack4.png";
}

-------------------------------------------------------------------------

function _M.getRandomPowerup(t)
	local p = _M.new(t)
	local set = {'heal10', 'heal30', 'heal60', 'heal100'}
	p.effect = set[math.random(#set)]
	return _M.new(p)
end

-------------------------------------------------------------------------

function _M.new(t)
	t = t or {}
	p = entity.new(t)

	p.kind = 'powerup'

	p.faction = t.faction or 'player'
	p.effect  = t.effect or 'heal10'
	p.dir_x   = -1
	p.dir_y   = 0
	p.speed   = 64


	_M.set_texture(p, icons[p.effect])

	return setmetatable(p, _MT)
end

function _M:think(dt)
	self.facing = self.facing +dt
end

function  _M:testcollision(e)
	if e.npc and not self.faction == 'npc' then
		return false
	else
		return entity.testcollision(self, e)
	end
end

function _M:doeffect(e)
	assert(e, "Can't effect nothing")
	local impact = self.shield / self.shieldmax
	if self.effect == 'heal10' then
		e:heal(e.shieldmax*.1*impact)
	elseif self.effect == 'heal30' then
		e:heal(e.shieldmax*.3*impact)
	elseif self.effect == 'heal60' then
		e:heal(e.shieldmax*.6*impact)
	elseif self.effect == 'heal100' then
		e:heal(e.shieldmax*impact)
	else
		print("Unknown powerup effect", self.effect)
	end

end

function _M:collidewith(e, dt)
	assert(e, "Can't collide with nothing")
	if e.kind == 'ship' then
		self:doeffect(e)
		self:die()
	else
		entity.collidewith(e, dt)
	end
end


-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

