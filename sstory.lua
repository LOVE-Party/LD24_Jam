-------------------------------------------------------------------------
-- [sstory.lua]
-- sstory
--  story Screen
--
-- scrolls though the story in _M.sstory, looping.
-- scrolling speed can be modified by changing _M.speedscale.
-------------------------------------------------------------------------
local Gamestate = require "lib.gamestate"
local soundmanager = require "lib.soundmanager"

local _M = Gamestate.new()
_M._NAME = "sstory"
Gamestate.story = _M -- so Gamestate.switch() can find us.
-------------------------------------------------------------------------

-- the actual story text, feel free to edit this.
_M.credits = [[
'Evolutius'

Background Story
=======================

Life, life is a continuing loop of events. 

Life evolves, based on these events. 

Do these evolutions make life easier? 

If you think of an evolution in the sense that it's an upgrade. 

It does. 

This game is all about evolving, upgrading. 

Making life easier. 

But beware, when prey evolve their defense, 

hunters evolve their offense. 

This also will repeat itself, 

the loop of events of life.









How long will you survive? 

How far will you evolve?
]]

--------------------------------------------------------------------------

_M.speedscale = 1.5 -- how fast to scroll the credits.
local width, height = love.graphics.getMode( )

-- the colors we use.
local COLOR_NORMAL   = {200, 200, 200}
local COLOR_TITLE    = { 50,  50,  50}
local COLOR_SKIP = { 50,  50,  50}
local COLOR_FRAME    = {  0,   0,   0}

--------------------------------------------------------------------------

function _M:enter()
	self.time = 0 -- timer
	self.font = love.graphics.newFont(height*0.03) -- main font
	self.wrap = select(2, self.font:getWrap(self.credits, width)) -- wrap length for the credits
	self.offset = 0 -- rendering offset for the credits

	self.bg = love.graphics.newImage('gfx/MainMenu_BG.png')

end

--------------------------------------------------------------------------

function _M:draw()
	local lg = love.graphics
	local lt = love.timer
	
	lg.setFont(self.font)
	
	lg.setColor(255, 255, 255)
	lg.draw(self.bg,0,0)

	-- The actual credits
	lg.setColor(COLOR_NORMAL)
	lg.printf(self.credits, 0, self.offset, width, 'center')

	-- Top and bottom letterboxing
	lg.setColor(COLOR_FRAME)
	lg.rectangle('fill', 0,         0, width, height*.1)
	lg.rectangle('fill', 0, height*.9, width, height*.1)

	-- Title
	local msg = love.graphics.getCaption()
	local center = (width - lg.getFont():getWidth(msg)) / 2
	lg.setColor(COLOR_TITLE)
	lg.print(msg, center, height*.025)

	-- Skip message
	local msg = "Press any button to skip."
	local center = (width - lg.getFont():getWidth(msg)) / 2
	lg.setColor(COLOR_SKIP)
	lg.print(msg, center, height*.925)
end

--------------------------------------------------------------------------

function _M:update(dt)
	self.time = self.time+(dt*self.speedscale)
	
	local fh = self.font:getHeight()
	self.offset = (height-((fh*self.time) % (fh*self.wrap+height)))
end

--------------------------------------------------------------------------

function _M:keypressed(key, unicode)
	if key == 'enter' or key == 'return' or key == ' ' then
		Gamestate.switch(Gamestate.main);
	end
end

-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

