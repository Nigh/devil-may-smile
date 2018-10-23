
local dynamics = {
    _VERSION     = 'dynamics v0.0.0',
    _URL         = '',
    _DESCRIPTION = 'A simple dynamics library',
    };

-- 精度宽容度
local small = 1e-06
-- 背景重力
local dyna_g = 1500
-- y轴限速
local max_vy = 750

local gravity = {type="static",ay=dyna_g}

dynamics.items={}

local function notSmall(n)
    if n<small and n>-small then
        return false
    else
        return true
    end
end

function dynamics:link_bump(world)
    self.world = world
end

function dynamics:add( item )
    table.insert( self.items, item )
end

function dynamics:drive(item, driver)
    item.driver = driver
end

function dynamics:update( dt )
    for i=#self.items,1,-1 do
        local v = self.items[i]
        if v._gc then
            table.remove( self.items, i )
        else
            v.driver = v.driver or gravity
            v.driver.fx = v.driver.fx or 0
            v.driver.fy = v.driver.fy or 0
            v.driver.ax = v.driver.ax or 0
            v.driver.ay = v.driver.ay or 0
            v.driver.ix = v.driver.ix or 0
            v.driver.iy = v.driver.iy or 0
            v.driver.dur = v.driver.dur or 0
            if v.driver.type == "static" then
                v.dx = v.vx*dt + 0.5*v.driver.ax*dt*dt
                v.vx = v.vx+v.driver.ax*dt
                v.dy = v.vy*dt + 0.5*v.driver.ay*dt*dt
                v.vy = v.vy+v.driver.ay*dt
                if v.vy>max_vy then v.vy = max_vy end
            elseif v.driver.type == "force" then
                if v.driver.dur>dt then
                    v.driver.dur = v.driver.dur - dt
                else
                    dt = v.driver.dur
                    v.driver.dur = 0
                end
                if notSmall(v.driver.ax) then
                    v.dx = v.vx*dt + 0.5*v.driver.ax*dt*dt
                    v.vx = v.vx+v.driver.ax*dt
                elseif notSmall(v.driver.fx) then
                    v.dx = v.vx*dt + 0.5*v.driver.fx/v.mass*dt*dt
                    v.vx = v.vx+v.driver.fx/v.mass*dt
                end
                if notSmall(v.driver.ay) then
                    v.dy = v.vy*dt + 0.5*v.driver.ay*dt*dt
                    v.vy = v.vy+v.driver.ay*dt
                elseif notSmall(v.driver.fy) then
                    v.dy = v.vy*dt + 0.5*v.driver.fy/v.mass*dt*dt
                    v.vy = v.vy+v.driver.fy/v.mass*dt
                end
                if v.vy>max_vy then v.vy = max_vy end
                if v.driver.dur<=0 then
                    v.driver = nil
                end
            elseif v.driver.type == "pulse" then
                if notSmall(v.driver.ax) then
                    v.vx = v.vx+v.driver.ax
                    v.dx = v.vx*dt
                elseif notSmall(v.driver.ix) then
                    v.vx = v.vx+v.driver.ix/v.mass
                    v.dx = v.vx*dt
                end
                if notSmall(v.driver.ay) then
                    v.vy = v.vy+v.driver.ay
                    v.dy = v.vy*dt
                elseif notSmall(v.driver.iy) then
                    v.vy = v.vy+v.driver.iy/v.mass
                    v.dy = v.vy*dt
                end
                print(v.name)
                print(v.driver.ay)
                print(v.vy)
                print(v.dy)
                if v.vy>max_vy then v.vy = max_vy end
                v.driver = nil
            end
        end
    end
    
    for i=#self.items,1,-1 do
        local v = self.items[i]
        local col_solve = v.col_solve or nil
        local actualX, actualY, cols, len = self.world:move(v, v.x+v.dx,v.y+v.dy,col_solve)
        if not notSmall(v.y-actualY) then v.vy = 0 end
        if not notSmall(v.x-actualX) then v.vx = -v.vx end
        v.x, v.y = actualX, actualY
        if notSmall(v.vx) then v.vx = v.vx - v.vx*0.8*dt end
    end
end

return dynamics
