local Enemy = {	-- this is the library table we will return, not an actual enemy!
	speed = 100;	-- this will give a default speed of 100
}
--[[
Enemy.__index = Enemy
Texture = nil
x = 0
y = 0
speed = 100
]]

function Enemy.Create(EnemyTexture,init_x,init_y)
 local En = setmetatable({}, {__index = Enemy})
 En.Texture = EnemyTexture
 En.x = init_x
 En.y = init_y
 return En
end

function Enemy:Update(dt)
	self.x = self.x - self.speed * dt
end

function Enemy:Draw()	-- Note: when using ":" instead of "." to call a function in a table, it `basicly` means "Use OOP stuff like the 'self' variable which is a reference to the actual object. 
	love.graphics.draw(self.Texture, self.x , self.y)
end

return Enemy