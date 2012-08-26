-------------------------------------------------------------------------
-- [scredits.lua]
-- scredits
--  Credits Screen
--
-- scrolls though the credits in _M.credits, looping.
-- scrolling speed can be modified by changing _M.speedscale.
-------------------------------------------------------------------------
local Gamestate = require "lib.gamestate"
local soundmanager = require "lib.soundmanager"

local _M = Gamestate.new()
_M._NAME = "scredits"
Gamestate.credits = _M -- so Gamestate.switch() can find us.
-------------------------------------------------------------------------

-- the actual credits text, feel free to edit this.
_M.credits = [[
'Evolution!'

LOVE-Party 24 Jam team!
=======================

-= Francisco =-
(Coding and Music)

-= Lafolie =-
(Ideas & Graphics)

-= Textmode =-
(Coder and Huggler)

-= JustAPerson =-
(General Coder, part-time huggler)

-= Roybie =-
(Hugglee)

-= VividReality =-
(Graphics, Audio and some Coding)



With special thanks to
=======================

-= Bartbes =-
(Sex Machine)


...And everyone that joined the Ludum Dare:
Keep being Awesome.





























^_^
*Huggles*

]]

--------------------------------------------------------------------------

_M.speedscale = 2 -- how fast to scroll the credits.
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

