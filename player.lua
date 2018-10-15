
local player={}

function player:init(world)
	self.name = "player"
	self.x = 50
	self.y = 50
	self.w = 20
	self.h = 36
	self.vx = 0
	self.vy = 0
	self.jumpcount = 0
	self.jpt = 0	-- 大小跳时间阈值
	self.state = "init"
	self.jumpstate = ""
	self.world = world
	self.world:add(self,self.x,self.y,self.w,self.h)

	self:effectInit()
end

function player:effectInit()
	self.jumpeffect = love.graphics.newParticleSystem(love.graphics.newImage( "dot.png" ),40)
	self.jumpeffect:setOffset( 12, 4 )
	self.jumpeffect:setParticleLifetime(.2,.3)
	self.jumpeffect:setEmissionRate(400)
	self.jumpeffect:setEmitterLifetime(.2)
	self.jumpeffect:setColors(
		1, .7, .5, 1, 
		1, .4, .5, 0.2,
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
	self.jumpeffect:reset()
	self.jumpeffect:setPosition(x,y)
	self.jumpeffect:start()
end

function player:jumpstart()
	if self.jumpcount<1 then
		self.vy = -300
		if self.state=="air" then
			self:jumpeffectAdd(self.x+self.w*0.5,self.y+self.h)
			self.jumpcount = self.jumpcount+1
		end
		self.jumpstate="jumpstart"
		self.jpt = 0.14
	end
end

function player:jumpstop()
	if self.jumpstate=="jumpstart" then
		self.jumpstate = ""
	end
end

function player:jumphigh()
	-- self.vy = -300
	self.jumpstate="jumphigh"
end

function player:run(dir)
	if dir=="left" then
		self.vx = -300
	elseif dir=="right" then
		self.vx = 300
	else
		self.vx = 0
	end
end

function player:draw()
	love.graphics.rectangle("line",self.x,self.y,self.w,self.h)
	local mode = love.graphics.getBlendMode()
	love.graphics.setBlendMode( "add" )
	love.graphics.draw(self.jumpeffect,0,0)
	love.graphics.setBlendMode( mode )
end


height={0,0,0}
function player:update(dt)
	self.jumpeffect:moveTo(self.x+self.w*0.5,self.y+self.h)
	self.jumpeffect:update(dt)
	if self.jumpstate=="jumpstart" then
		self.jpt = self.jpt-dt
		if self.jpt<=0 then
			self:jumphigh()
		end
	end
	-- 掉落测试
	local _, actualY = self.world:check(self, self.x, self.y+10)
	self.onGround = self.y==actualY

	local g = 0
	if self.onGround == true then
		if self.jumpstate~="jumpstart" then
			self.vy = 0
		end
		self.jumpcount = 0
		self.state = "ground"
	else
		self.state = "air"
	end
	if self.jumpstate~="jumpstart" then
		g = 1500
	end
	-- print("dt:"..dt.."\tvy:"..self.vy.."\tdh:"..self.vy*dt + 0.5*a*dt*dt)
	player:move(self.vx * dt,self.vy*dt + 0.5*g*dt*dt)
	self.vy = self.vy+g*dt
	if self.vy>750 then self.vy=750 end
	height[1] = height[2]
	height[2] = height[3]
	height[3] = self.y
	if height[2]<height[1] and height[2]<height[3] then
		print("jump:" .. 664-height[2])
	end
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
