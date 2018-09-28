
player = require("player")
local bump = require 'bump'
local world = bump.newWorld(25)	-- 64 ~ 70 工作异常
local ground = {
	name="ground_tile",
	x=-100,y=700,w=2000,h=2
}
function love.load()
	print("test")
	love.graphics.setBackgroundColor( 0x0a/0xff, 0x08/0xff, 0x06/0xff )
	love.math.setRandomSeed( 6173420+love.timer.getTime( ) )
	player:init(world)
	world:add(ground,ground.x,ground.y,ground.w,ground.h)
end

function love.update( dt )
	
	player:update(dt)
end

function love.draw( ... )

	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill",ground.x,ground.y,ground.w,ground.h)
	player:draw()
end

function love.keypressed( key, scancode, isrepeat )
	if key == 'w' and not isrepeat then
		player:jump()
	end
end
