-------------------------------------------------------------------------
-- [smain.lua]
-- smain
--  Main Menu screen
-------------------------------------------------------------------------
local Gamestate = require "lib.gamestate"
local soundmanager = require "lib.soundmanager"

local _M = Gamestate.new()
_M._NAME = "smenu"
-------------------------------------------------------------------------

Gamestate.main = _M

_M.options = {
	{'Play', function(s) s:startgame()  end };
	{'Credits', function() Gamestate.switch(Gamestate.credits) end};
	{'Exit', function(s) love.event.quit()  end};
}


local width, height = love.graphics.getMode( )

local COLOR_NORMAL   = {200, 200, 200}
local COLOR_SELECTED = {255, 255, 255}

_M.selected = 0

function _M:enter()
	self.time     = 0
--	self.selected = 0
	self.font     = love.graphics.newFont(height*0.06)
	self.font_sm  = love.graphics.newFont(height*0.03)
	self.logo = love.graphics.newImage('gfx/Logo.png')
	self.text_img = love.graphics.newImage('gfx/GameName.png')
end

function _M:draw()
	local lg = love.graphics
	local lt = love.timer

	lg.setFont(self.font)
	
	local scale, rot = (math.sin(self.time)*.05)+.95, (self.time / (math.pi*2))
	lg.draw(self.logo, width/2, height/2, rot, scale, scale, self.logo:getWidth()/2, self.logo:getHeight()/2)
	lg.draw(self.text_img, width / 2, height / 2 + 64, 0, 1, 1, self.text_img:getWidth()/2, self.text_img:getHeight()/2)
	
	if self.selected == 0 then
		if math.floor(self.time) % 2 == 0 then
			lg.setFont(self.font_sm)
			local msg = "Press any button to continue."
			local center = (width - lg.getFont():getWidth(msg)) / 2
			lg.print(msg, center, height*.75)
		end
	else
		local offset = height * .1
		local indent = offset
		local font, fh = lg.getFont()
		fh = font:getHeight()

		for i =#self.options, 1, -1 do
			lg.setColor(self.selected == i and COLOR_SELECTED or COLOR_NORMAL)
			-- we have to subtract an extra line height, because fonts are=
			--  rendered from the topline, not the baseline.
			lg.print(self.options[i][1], indent, (height-fh)-offset)
			offset = offset + fh
		end
	end
end

function _M:update(dt)
	self.time = self.time+dt
end

function _M:startgame()
	print("begin playing")
	Gamestate.switch(Gamestate.space)
end



function _M:keypressed(key, unicode)
	print(string.format("Keypressed: '%s'", key))
	local selected = self.selected
	if selected == 0 then
		selected = 1
	else
		if key == 'down' then
			selected = selected + 1
			if selected > #self.options then selected = 1 end
		elseif key == 'up' then
			selected = selected - 1
			if selected < 1 then selected = #self.options end
		elseif key == 'enter' or key == 'return' or key == ' ' then
			local option = self.options[self.selected]
			print(string.format("doing option '%s' [%d] ", tostring(option[1]),selected))
			option[2](self)
		end
	end
	self.selected = selected
end


-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

