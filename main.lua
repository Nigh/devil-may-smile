
player = require("player")
local bump = require 'bump'
local world = bump.newWorld(25)	-- 64 ~ 70 工作异常

local box_draw=function(self,x,y,w,h)
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("fill",x,y,w,h)
end

local ground_draw=function(self,x,y,w,h)
	love.graphics.setColor(0.6,0.6,0.7,1)
	love.graphics.rectangle("fill",x,y,w,h)
end

local devil_draw=function(self,x,y,w,h)
	love.graphics.setColor(0.9,0.3,0.2,1)
	love.graphics.rectangle("line",x,y,w,h)
	love.graphics.rectangle("fill",x+(self.face+1)*0.25*self.w,y,self.w*0.5,self.w*0.5)
end

local ground = {
	name="ground_tile",
	x=-100,y=700,w=2000,h=50,
	draw=ground_draw
}
local box1 = {
	name="box1",
	w=30,h=32,
	draw=box_draw
}
local box2 = {
	name="box2",
	w=10,h=64,
	draw=box_draw
}
local box3 = {
	name="box3",
	w=200,h=129,
	draw=box_draw
}
local enemy = {
	name="devil0",group="red",
	w=15,h=40,face=-1,
	draw=devil_draw
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
	waog(enemy,760)
end

function love.update( dt )
	if love.keyboard.isDown('a') then
		player:faceto("left")
		player:run()
	elseif love.keyboard.isDown('d') then
		player:faceto("right")
		player:run()
	else
		player:stop()
	end
	player:update(dt)
end

function love.draw( ... )
	love.graphics.setColor(1, 1, 1)
	local tab,len = world:getItems()
	for i=1,len do
		if tab[i].name~="player" then
			tab[i]:draw(world:getRect(tab[i]))
		end
	end
	player:draw()
end

function love.keypressed( key, scancode, isrepeat )
	if key == 'w' and not isrepeat then
		player:jumpstart()
	end
	if key == 'j' and not isrepeat then
		player:attack()
	end
end

function love.keyreleased( key, scancode )
	if key == 'w' then
		player:jumpstop()
	end
end
