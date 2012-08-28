-------------------------------------------------------------------------
-- [smain.lua]
-- smain
--  Main Menu screen
-------------------------------------------------------------------------
local Gamestate    = require "lib.gamestate"
local soundmanager = require "lib.soundmanager"
local input        = require "input"

local music = love.audio.newSource("sfx/main_theme.ogg", 'stream') -- long audio files should be streamed
music:setLooping(true)

local _M   = {_NAME = 'smain', _TYPE='state'}
local _MT  = {__index = _M}
local _MMT = {__index = Gamestate.new()}
local proxy = {}
setmetatable(_M, _MMT)
setmetatable(proxy, _MT)
Gamestate.main = proxy
-------------------------------------------------------------------------

-- The list of options availible on the menu, as {title, action} pairs.
_M.options = {
	{'Play', function(s) s:startgame()  end };
	{'Story', function() Gamestate.switch(Gamestate.story) end};
	{'Credits', function() Gamestate.switch(Gamestate.credits) end};
	{'Exit', function(s) love.event.quit()  end};
}

local width, height = love.graphics.getMode( )

-- colors used to mark availible and selected options
local COLOR_NORMAL   = {200, 200, 200}
local COLOR_SELECTED = {255, 255, 255}

_M.selected = 0

-- called by lib.gamestate when switching to this menu.
function _M:enter()
	self.time     = 0
--	self.selected = 0
	self.font     = love.graphics.newFont(height*0.06)
	self.font_sm  = love.graphics.newFont(height*0.03)
	self.logo = love.graphics.newImage('gfx/Logo.png')
	self.text_img = love.graphics.newImage('gfx/GameName.png')
	
	music:rewind()
	music:play()
	
	self.bg = love.graphics.newImage('gfx/MainMenu_BG.png')
	
	self.input = input:new()
	self.input:install(self)
	self.update = _M.update -- restore our update
	self.input.aliasmap = {
		['enter'] = 'start';
		[' ']     = 'start';
		['right'] = 'start';
		['up']    = 'up';
		['down']  = 'down';
	}
	self.input.dopress = function(s, btn) self:dobuttonpress(btn) end
	assert(self.update == _M.update, "We failed to restore our update :/")
end

-- draws the menu
function _M:draw()
	local lg = love.graphics
	local lt = love.timer

	lg.setFont(self.font)
	
	lg.draw(self.bg,0,0)
	
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

-- updates the menu, and its timer.
function _M:update(dt)
	self.time = self.time+dt
	
	self.input:update(dt)
end

-- starts the game (for when that option is selected)
function _M:startgame()
	print("begin playing")
	Gamestate.switch(Gamestate.space)
end

-- takes events provided by the input handler; changes the current
-- selection and triggers actions as appropriate
function _M:dobuttonpress(btn)
	print("doing press:", btn)
	local selected = self.selected
	if selected == 0 then
		selected = 1
	else
		if btn == 'down' then
			selected = selected + 1
			if selected > #self.options then selected = 1 end
		elseif btn == 'up' then
			selected = selected - 1
			if selected < 1 then selected = #self.options end
		elseif btn == 'start' then
			local option = self.options[self.selected]
			print(string.format("doing option '%s' [%d] ", tostring(option[1]),selected))
			option[2](self)
			music:stop()
		end
	end
	self.selected = selected
end

-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

