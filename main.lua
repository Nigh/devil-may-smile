
player = require("player")
local bump = require 'bump'
local world = bump.newWorld(25)	-- 64 ~ 70 工作异常
local ground = {
	name="ground_tile",
	x=-100,y=700,w=2000,h=5
}
local box1 = {
	name="box1",
	w=10,h=32
}
local box2 = {
	name="box2",
	w=5,h=64
}
local box3 = {
	name="box3",
	w=200,h=129
}
function love.load()
	print("test")
	love.graphics.setBackgroundColor( 0x0a/0xff, 0x08/0xff, 0x06/0xff )
	love.math.setRandomSeed( 6173420+love.timer.getTime( ) )
	player:init(world)
	world:add(ground,ground.x,ground.y,ground.w,ground.h)
	waog=function(t,x)world:add(t,x,ground.y-t.h,t.w,t.h)end
	waog(box1,400)
	waog(box2,600)
	waog(box3,900)
end

function love.update( dt )
	if love.keyboard.isDown('a') then
		player:run("left")
	elseif love.keyboard.isDown('d') then
		player:run("right")
	else
		player:run()
	end
	player:update(dt)
end

function love.draw( ... )
	love.graphics.setColor(1, 1, 1)
	local tab,len = world:getItems()
	for i=1,len do
		if tab[i].name~="player" then
			love.graphics.rectangle("fill",world:getRect(tab[i]))
		end
	end
	-- love.graphics.rectangle("fill",ground.x,ground.y,ground.w,ground.h)
	player:draw()
end

function love.keypressed( key, scancode, isrepeat )
	if key == 'w' and not isrepeat then
		player:jumpstart()
	end
end

function love.keyreleased( key, scancode )
	if key == 'w' then
		player:jumpstop()
	end
end
