local Gamestate = require "lib.gamestate"
local state = Gamestate.new()
Gamestate.space = state

local Enemy = require("enemy")

function state:enter()
	spaceship = love.graphics.newImage("gfx/SpaceShip.png")
	dirt = love.graphics.newImage("gfx/Dirt.png")
	grass = love.graphics.newImage("gfx/Grass.png")
	dirtbottom = love.graphics.newImage("gfx/DirtBottom.png")
	BKG = love.graphics.newImage("gfx/BKG.png")
	
	
	ship_x = 64
	ship_y = 320
	speed = 100
	
	level = {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,3,3,3,3,3,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,5,4,3,2,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,1,1,1,1,1,1,1,1,1,5,6,5,6,5,6,5,6,5,1,1,1,1,1,1,1,1,2,3,4,3,2,3,2,3,4,5,5,5,5,5,4,3,2,1,0}
	
	
	Enemies = Enemy.Create(love.graphics.newImage("gfx/Enemy2.png"),300,200)
	
	level_width = #level
	level_x = -640
	scroll_speed = 50
end

function state:update(dt)

	level_x = level_x + scroll_speed * dt
	
	if level_x > level_width * 32 then
	
		level_x = -640
	
	end
	

	if love.keyboard.isDown("right") then
		ship_x = ship_x + speed * dt
	elseif love.keyboard.isDown("left") then
		ship_x = ship_x - speed * dt
	end
	
	if love.keyboard.isDown("down") then
		ship_y = ship_y + speed * dt
	elseif love.keyboard.isDown("up") then
		ship_y = ship_y - speed * dt
	end
end

function drawlevel()


	for x=1, level_width do		
			for y=1, level[x] do
			
				love.graphics.draw(dirt,(x*32) - level_x ,y*32)
				love.graphics.draw(dirt,(x*32) - level_x ,(15 - y) * 32)
				
				
				
				if y == level[x] then
				love.graphics.draw(dirtbottom,(x*32) - level_x ,y*32)
				love.graphics.draw(grass,(x*32) - level_x ,(15 - y) * 32)
				end
				
			end
	end
end

function state:draw()
	love.graphics.draw(BKG,0,0)
	love.graphics.draw(spaceship,ship_x,ship_y)
	Enemies:Draw()
	drawlevel()
end