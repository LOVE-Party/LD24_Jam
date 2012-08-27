-------------------------------------------------------------------------
-- [smissionover.lua]
-- smissionover
--  Mission over screen
--
-- scrolls though the credits in _M.credits, looping.
-- scrolling speed can be modified by changing _M.speedscale.
-------------------------------------------------------------------------
local Gamestate = require "lib.gamestate"
local soundmanager = require "lib.soundmanager"

local _M = Gamestate.new()
_M._NAME = "missionover"
Gamestate.missionover = _M -- so Gamestate.switch() can find us.
-------------------------------------------------------------------------

local width, height = love.graphics.getMode( )
_M.speedscale = 1
--------------------------------------------------------------------------

function _M:enter()
	self.time = 0 -- timer
	self.font = love.graphics.newFont(24)
end

--------------------------------------------------------------------------

function _M:draw()
	local lg = love.graphics

	lg.setFont(self.font)
	lg.printf(self.message, 0, (height+24) / 2, width, 'center')
end

--------------------------------------------------------------------------

function _M:update(dt)
	self.time = self.time+(dt*self.speedscale)
end

--------------------------------------------------------------------------

function _M:keypressed(key, unicode)
	Gamestate.switch(Gamestate.main);
end


--------------------------------------------------------------------------

function _M:settype(kind)
	print('setting mission over kind', kind)
	if kind == 'fail' then
		self.message = "You died horribly.\nWhy are you playing this?"
	elseif kind == 'win' then
		error "The only winning move is not to play."
	else -- unknown kind
		error(string.format("Asked to create an unknown kind of mission over screen. ['%s']", tostring(kind)))
	end

end
-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

