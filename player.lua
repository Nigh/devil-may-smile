
local player={}

function player:init(world)
	self.x = 50
	self.y = 50
	self.w = 20
	self.h = 36
	self.vx = 50
	self.vy = 0
	self.world = world
	self.world:add(self,self.x,self.y,self.w,self.h)
end

function player:jump()
	self.vy = -400
end


function player:draw()
	love.graphics.rectangle("line",self.x,self.y,self.w,self.h)
end


function player:update(dt)
	self.onGround = self.isTouchGround
	if self.onGround ~= true then
		self.vy = self.vy + 1000*dt
	end
	if self.vy>750 then self.vy=750 end
	self.isTouchGround = false
	player:move(self.vx * dt,self.vy * dt)
	print(self.vy)
end

local function col_solve(item, other)
	if other.name == "ground_tile" then
		item.vy = 0
		item.isTouchGround = true
		if item.onGround == true then
			return "slide"
		else
			item.onGround = true
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
	for i=1,len do
		print('collided with ' .. tostring(cols[i].other))
	end
end

return player
