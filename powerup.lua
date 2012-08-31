-------------------------------------------------------------------------
-- [powerup.lua]
-- powerup
-------------------------------------------------------------------------
local entity = require "entity"
local turret = require "hull.turret"

local _M   = {_NAME = "powerup", _TYPE = 'module'}
local _MT  = {__index = _M}
local _MMT = {__index = entity}
setmetatable(_M, _MMT)
-------------------------------------------------------------------------
local Image = love.graphics.newImage
icons = {
	generic     = Image "gfx/pu_crate01.png";
	heal10      = Image "gfx/RepairPack.png";
	heal30      = Image "gfx/RepairPack2.png";
	heal60      = Image "gfx/RepairPack3.png";
	heal100     = Image "gfx/RepairPack4.png";
	turret      = Image "gfx/pu_turret.png";
	crate_low   = Image "gfx/pu_crate01.png";
	crate_mid   = Image "gfx/pu_crate02.png";
	crate_high  = Image "gfx/pu_crate03.png";
}

-------------------------------------------------------------------------

function _M.getRandomPowerup(t)
	local p = _M.new(t)
	local set = {'heal10', 'heal30', 'heal60', 'heal100', 'turret',
		'crate_high', 'crate_mid', 'crate_low'}
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
	assert(e and e._TYPE == 'entity', string.format("Expected 'entity', got '%s' instead.", e and e.type or type(e)))
	local impact = self.shield / self.shieldmax
	if self.effect == 'heal10' then
		e:heal(e.shieldmax*.1*impact)
	elseif self.effect == 'heal30' then
		e:heal(e.shieldmax*.3*impact)
	elseif self.effect == 'heal60' then
		e:heal(e.shieldmax*.6*impact)
	elseif self.effect == 'heal100' then
		e:heal(e.shieldmax*impact)
	elseif self.effect == 'turret' then
		local t = turret.new{owner = e}
		t.shield = t.shieldmax * impact
		e:addentity(t)
		local tau = math.pi*2
		t.hardpoint = math.random() * tau
	elseif self.effect == 'crate_low' then
		if e.score then
			e.score = e.score + (25 * impact)
		end
	elseif self.effect == 'crate_mid' then
		if e.score then
			e.score = e.score + (50 * impact)
		end
	elseif self.effect == 'crate_high' then
		if e.score then
			e.score = e.score + (100 * impact)
		end
	else
		print("Unknown powerup effect", self.effect)
	end

end

function _M:collidewith(e, dt)
	assert(e and e._TYPE == 'entity', string.format("Expected 'entity', got '%s' instead.", e and e.type or type(e)))
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

