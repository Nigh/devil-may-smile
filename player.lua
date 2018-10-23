

local be = require("boxeffect")
local player={}

function player:init(world)
	self.name = "player"
	self.x = 50
	self.y = 50
	self.w = 20
	self.h = 36
	self.vx = 0
	self.vy = 0
	self.face = 1	-- 1 for right, -1 for left
	self.jumpcount = 0
	self.state = "init"
	self.jumpstate = ""
	self.world = world
	self.world:add(self,self.x,self.y,self.w,self.h)
	self.col_solve = col_solve
	self:effectInit()
end

function player:effectInit()
	self.jumpeffect = love.graphics.newParticleSystem(love.graphics.newImage( "dot.png" ),40)
	self.jumpeffect:setOffset( 12, 4 )
	self.jumpeffect:setParticleLifetime(.2,.3)
	self.jumpeffect:setEmissionRate(400)
	self.jumpeffect:setEmitterLifetime(.2)
	self.jumpeffect:setColors(
		.5, .7, .5, 1, 
		.5, .3, .5, 0.2,
		1, 1, 1, 0
	)
	self.jumpeffect:setSizes(1,2,4)
	self.jumpeffect:setDirection( math.pi )
	self.jumpeffect:setSpread( math.pi*0.3 )
	self.jumpeffect:setSpeed( -200,200 )
	self.jumpeffect:setLinearAcceleration(0,666)
	self.jumpeffect:setEmissionArea( "uniform", 20, 5, 0 )
	self.jumpeffect:setLinearDamping(3)
	self.jumpeffect:stop()
end

function player:jumpeffectAdd(x,y)
	-- self.jumpeffect:reset()
	-- self.jumpeffect:setPosition(x,y)
	-- self.jumpeffect:start()
	be:new(x-15,y,30,3,0.2)
end

function player:jumpstart()
	if self.jumpcount<1 then
		self.vy = -300
		if self.state=="air" then
			self:jumpeffectAdd(self.x+self.w*0.5,self.y+self.h)
			self.jumpcount = self.jumpcount+1
		end
		self.jumpstate="jumpstart"
		self.driver = {type="force",ay=500,dur=0.3}
	end
end

function player:jumpstop()
	if self.jumpstate=="jumpstart" then
		self.jumpstate = ""
		self.driver = nil
	end
end

function player:jumphigh()
	-- self.vy = -300
	self.jumpstate="jumphigh"
end

function player:faceto(dir)
	if dir=="left" then
		self.face = -1
	elseif dir=="right" then
		self.face = 1
	end
end

function player:attack()
	local atw = 36
	local ax,ay,aw,ah = self.x+0.5*self.w-0.5*atw+0.5*self.face*(atw+self.w),self.y,atw,20
	local items, len = self.world:queryRect(ax,ay,aw,ah,
	function(i)
		if i.group~="red" then
			return false
		else
			return true
		end
	end)
	be:new(ax,ay,aw,ah,0.3)
	for _,v in ipairs(items) do
		local x,y,w,h = self.world:getRect(v)
		be:new(x,y,w,h,0.7)
		v.driver = {type="pulse",ay=-200,ax=self.face*100}
	end
end

function player:stop()
	self.vx = 0
end

function player:run()
	self.vx = 300 * self.face
end

function player:draw()
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("line",self.x,self.y,self.w-1,self.h-1)
	love.graphics.rectangle("fill",self.x+(self.face+1)*0.25*self.w,self.y,self.w*0.5,self.w*0.5)
	local mode = love.graphics.getBlendMode()
	love.graphics.setBlendMode( "add" )
	love.graphics.draw(self.jumpeffect,0,-10)
	love.graphics.setBlendMode( mode )
	be:draw()
end

height={0,0,0}
function player:update(dt)
	be:update(dt)
	self.jumpeffect:moveTo(self.x+self.w*0.5,self.y+self.h)
	self.jumpeffect:update(dt)
	-- 掉落测试
	local _, actualY = self.world:check(self, self.x, self.y+10)
	self.onGround = self.y==actualY

	if self.onGround == true then
		if self.jumpstate~="jumpstart" then
			self.vy = 0
		end
		self.jumpcount = 0
		self.state = "ground"
	else
		self.state = "air"
	end

	-- print("dt:"..dt.."\tvy:"..self.vy.."\tdh:"..self.vy*dt + 0.5*a*dt*dt)
	-- player:move(self.vx * dt,self.vy*dt + 0.5*g*dt*dt)
	-- self.vy = self.vy+g*dt
	-- if self.vy>750 then self.vy=750 end
	-- height[1] = height[2]
	-- height[2] = height[3]
	-- height[3] = self.y
	-- if height[2]<height[1] and height[2]<height[3] then
	-- 	print("jump:" .. 664-height[2])
	-- end
end

local function col_solve(item, other)
	if other.name == "ground_tile" then
		item.vy = 0
		if item.onGround == true then
			return "slide"
		else
			return "touch"
		end
	else
		return "slide"
	end
end

function player:move(dx,dy)
	local actualX, actualY, cols, len = self.world:move(self, self.x+dx,self.y+dy,col_solve)
	self.x, self.y = actualX, actualY
	-- self.world:update(self,self.x, self.y)
	-- for i=1,len do
	-- 	print('collided with ' .. tostring(cols[i].other))
	-- end
end

return player
