-- Extracted/converted from 'Fistful of Beef'

local Gamestate = require "lib.gamestate"
local soundmanager = require "lib.soundmanager"

Gamestate.intro = Gamestate.new()
local state = Gamestate.intro

local images = {
	bg      = love.graphics.newImage "intro/bg.png"; 
	bomb    = love.graphics.newImage "intro/bomb.png"; 
	city    = love.graphics.newImage "intro/city.png"; 
	gaycity = love.graphics.newImage "intro/gaycity.png"; 
}

local sounds = {
	chirp    = love.sound.newSoundData "intro/chirp.ogg";
	bombfall = love.sound.newSoundData "intro/bombfall.ogg";
	impact   = love.sound.newSoundData "intro/impact.ogg";
	yay      = love.sound.newSoundData "intro/yay.ogg";
}

local width, height = love.graphics.getMode( )

state.name = "Intro"
state.dt = 0
state.played = {}

state.bombCue = 3
state.explodeCue = 5
state.yayCue = 6.6
state.menuCue = 10
state.scale = math.min(width / 800, height / 600)

function state:update(dt)
  soundmanager:update(dt)
  state.dt = state.dt + dt
  if state.dt >= 1 and not state.played.chirp then
    soundmanager:play(sounds.chirp)
    state.played.chirp = true;
  elseif state.dt >= state.bombCue and not state.played.bombfall then
    soundmanager:play(sounds.bombfall)
    state.played.bombfall = true
  elseif state.dt >= state.explodeCue and not state.played.impact then
    soundmanager:play(sounds.impact)
    state.played.impact = true
  elseif state.dt >= state.yayCue and not state.played.yay then
    soundmanager:play(sounds.yay)
    state.played.yay = true
  elseif state.dt >= state.menuCue then
    Gamestate.switch(Gamestate.main)
  end
end

function state:draw()
  if state.played.impact then
    love.graphics.draw(images.gaycity, 7*state.scale, 147*state.scale, 0, state.scale)
    love.graphics.setColor(233, 233, 233, math.max(0, 255+((math.min(0, (state.dt-state.explodeCue)*-0.8)*510)/2)))
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(255, 255, 255, 255)
  elseif state.played.bombfall then
    love.graphics.draw(images.bg, 198*state.scale, 224*state.scale, 0, state.scale)
    love.graphics.draw(images.city, 243*state.scale, 253*state.scale, 0, state.scale)
    love.graphics.draw(images.bomb, 388*state.scale, ((state.dt-state.bombCue)*170-100)*state.scale, 0, state.scale)
  else
    love.graphics.draw(images.bg, 198*state.scale, 224*state.scale, 0, state.scale)
    love.graphics.draw(images.city, 243*state.scale, 253*state.scale, 0, state.scale)
  end
end

function state:keypressed(key, unicode)
  Gamestate.switch(Gamestate.main)
end

function state:mousepressed(x, y, button)
  Gamestate.switch(Gamestate.main)
end

function state:leave()
  love.audio.stop()
end
