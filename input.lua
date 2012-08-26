-------------------------------------------------------------------------
-- [input.lua]
-- input
--
-- generalised input handling, filtering, and aliasing. notably
--  multiplexes keyboard and gamepad inputs.
--
-- Example:
-- local handler = input:new()
-- gamestate gs = Gamestate.new()
-- handler:install(gs)
-- handler.aliasmap = {escape='quit'}
-- function handler:dopress(btn)
-- 	if btn == 'quit' then love.event.quit() end
-- end
--
-------------------------------------------------------------------------
local _M = {_NAME = "input", _TYPE = 'module'}
-------------------------------------------------------------------------
-- instance metatable
local _MT = {__index = _M}

-- creates (or clones) an instance of an input handler
function _M:new()
	local i = {}
	setmetatable(i, _MT)
	
	-- These two are used to map any keys you care about to reasonable aliases
	-- (you should probably try to have these be standard throughout the game)
	i.joymap   = { -- mapping of gamepad buttons to standard aliases
		[1]        = 'y';
		[2]        = 'b';
		[3]        = 'a';
		[4]        = 'x';
		[5]        = 'l1';
		[6]        = 'r1';
		[7]        = 'l2';
		[8]        = 'r2';
		[9]        = 'start';
		[10]       = 'select';
		[11]       = 'hat1';
		[12]       = 'hat2';
		-- dpad
		['dup']    = 'up';
		['ddown']  = 'down';
		['dleft']  = 'left';
		['dright'] = 'right';
	}
	
	i.keymap   = { -- mapping of keys to standard aliases
		['kpenter'] = 'enter';
		['return']  = 'enter';
		['lshift']  = 'shift';
		['rshift']  = 'shift';
		['lctrl']   = 'ctrl';
		['rctrl']   = 'ctrl';
		['lalt']    = 'alt';
		['ralt']    = 'alt';
		['lmeta']   = 'meta'; -- aka 'menu'?
		['rmeta']   = 'meta';
		['lsuper']  = 'super'; -- aka 'win'
		['rsuper']  = 'super';
		['w']       = 'up';
		['a']       = 'left';
		['s']       = 'down';
		['d']       = 'right';
		['kp8']     = 'up';
		['kp4']     = 'left';
		['kp2']     = 'down';
		['kp6']     = 'right';
		['up']	    = 'up';
		['left']    = 'left';
		['down']    = 'down';
		['right']   = 'right';
	}
	i._TYPE = 'input'
	
	-- the aliases from above will be passed through this map before being
	-- passed on to dopress(). This should be altered to match the needs of
	-- the current mode.
	i.aliasmap = {}
	
	-- internal
	i.joystate = {
		dup    = false;
		ddown  = false;
		dleft  = false;
		dright = false;
	}
	
	do
		local lj = love.joystick
		for j=0,lj.getNumJoysticks() do if not lj.isOpen(j) then
			lj.open(j) end
		end
	end
	
	return i
end

-- installs the handler into a given gamestate (or compatible table)
function _M:install(t)
	assert(type(t) == 'table', "Can't install into a non-table")
	assert(self ~= t, "...why are you trying to install this into itself?")
	
	t.keypressed       = function(s, ...) self:keypress(...)       end
	t.keyreleased      = function(s, ...) self:keyrelease(...)      end

	t.mousepressed     = function(s, ...) self:mousepress(...)     end
	t.mousereleased    = function(s, ...) self:mouserelease(...)    end

	t.joystickpressed  = function(s, ...) self:joypress(...)  end
	t.joystickreleased = function(s, ...) self:joyrelease(...) end

	t.update           = function(s, ...) self:update(...) end
end

-- handles keyboard keypresses, and multiplexes them to :dopress()
function _M:keypress(btn)
	local r = btn and self.keymap[btn]
	      r = r and self.aliasmap[r]

	if r and r ~= '' then
		self:dopress(r) end
end

-- handles keyboard keyreleases, and multiplexes them to :dorelease()
function _M:keyrelease(btn)
	local r = btn and self.keymap[btn]
	      r = r and self.aliasmap[r]

	if r and r ~= '' then
		self:dorelease(r) end
end

-- handles joystick (gamepad) button presses, and multiplexes them to :dopress()
function _M:joypress(joy, btn)
	local r = btn and self.joymap[btn]
	      r = r and self.aliasmap[r]

	if r and r ~= '' then
		self:dopress(r) end
end

-- handles joystick (gamepad) button releases, and multiplexes them to :dorelease()
function _M:joyrelease(joy, btn)
	local r = btn and self.joymap[btn]
	      r = r and self.aliasmap[r]

	if r and r ~= '' then
		self:dorelease(r) end
end

-- handles polling and updating for a handler.
-- notably polls for D-pad events.
function _M:update(dt)
	assert(self._TYPE == 'input', "Oops")
	local lj = love.joystick
	local dpad = lj.getHat(1, 1)
	if dpad == 'c' then
		local state
		state = 'dup'
		if self.joystate[state] then
			self.joystate[state] = false
			self:joyrelease(1, state)
		end
		state = 'ddown'
		if self.joystate[state] then
			self.joystate[state] = false
			self:joyrelease(1, state)
		end
		state = 'dleft'
		if self.joystate[state] then
			self.joystate[state] = false
			self:joyrelease(1, state)
		end
		state = 'dright'
		if self.joystate[state] then
			self.joystate[state] = false
			self:joyrelease(1, state)
		end
	elseif dpad:match 'u' then
		state = 'dup'
		if not self.joystate[state] then
			self.joystate[state] = true
			self:joypress(1, state)
		end
		state = 'ddown'
		if self.joystate[state] then
			self.joystate[state] = false
			self:joyrelease(1, state)
		end
	elseif dpad:match 'd' then
		state = 'ddown'
		if not self.joystate[state] then
			self.joystate[state] = true
			self:joypress(1, state)
		end
		state = 'dup'
		if self.joystate[state] then
			self.joystate[state] = false
			self:joyrelease(1, state)
		end
	elseif dpad:match 'l' then
		state = 'dleft'
		if not self.joystate[state] then
			self.joystate[state] = true
			self:joypress(1, state)
		end
		state = 'dright'
		if self.joystate[state] then
			self.joystate[state] = false
			self:joyrelease(1, state)
		end
	elseif dpad:match 'r' then
		state = 'dright'
		if not self.joystate[state] then
			self.joystate[state] = true
			self:joypress(1, state)
		end
		state = 'dleft'
		if self.joystate[state] then
			self.joystate[state] = false
			self:joyrelease(1, state)
		end
	end

end

-- instended to be overridden by the handler's creator, handles final input button-press events
function _M:dopress()
	assert(self._TYPE == 'input', "Oops")

end

-- instended to be overridden by the handler's creator, handles final input button-release events
function _M:dorelease()
	assert(self._TYPE == 'input', "Oops")

end

-- unused
function _M:mousepress()

end

-- unused
function _M:mouserelease()

end

-------------------------------------------------------------------------
if _VERSION == "Lua 5.1" then _G[_M._NAME] = _M end

return _M

