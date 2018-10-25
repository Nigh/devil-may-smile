
local dynamics = {
    _VERSION     = 'dynamics v0.0.0',
    _URL         = '',
    _DESCRIPTION = 'A simple dynamics library',
    };

-- 精度宽容度
local _small = 1e-06
-- 背景重力
local dyna_g = 1500
-- y轴限速
local max_vy = 750

local gravity = {type="static",ay=dyna_g}

dynamics.items={}

local function small(n)
    if n<_small and n>-_small then
        return true
    else
        return false
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
            elseif v.driver.type == "velocity" then
                v.driver.dur = v.driver.dur - dt
                v.vx = v.driver.ax
                v.vy = v.driver.ay
                v.dx = v.vx*dt
                v.dy = v.vy*dt
            elseif v.driver.type == "force" then
                if v.driver.dur>dt then
                    v.driver.dur = v.driver.dur - dt
                else
                    dt = v.driver.dur
                    v.driver.dur = 0
                end
                if not small(v.driver.ax) then
                    v.dx = v.vx*dt + 0.5*v.driver.ax*dt*dt
                    v.vx = v.vx+v.driver.ax*dt
                elseif not small(v.driver.fx) then
                    v.dx = v.vx*dt + 0.5*v.driver.fx/v.mass*dt*dt
                    v.vx = v.vx+v.driver.fx/v.mass*dt
                end
                if not small(v.driver.ay) then
                    v.dy = v.vy*dt + 0.5*v.driver.ay*dt*dt
                    v.vy = v.vy+v.driver.ay*dt
                elseif not small(v.driver.fy) then
                    v.dy = v.vy*dt + 0.5*v.driver.fy/v.mass*dt*dt
                    v.vy = v.vy+v.driver.fy/v.mass*dt
                end
                if v.vy>max_vy then v.vy = max_vy end
                if v.driver.dur<=0 then
                    v.driver = nil
                end
            elseif v.driver.type == "pulse" then
                if not small(v.driver.ax) then
                    v.vx = v.vx+v.driver.ax
                    v.dx = v.vx*dt
                elseif not small(v.driver.ix) then
                    v.vx = v.vx+v.driver.ix/v.mass
                    v.dx = v.vx*dt
                end
                if not small(v.driver.ay) then
                    v.vy = v.vy+v.driver.ay
                    v.dy = v.vy*dt
                elseif not small(v.driver.iy) then
                    v.vy = v.vy+v.driver.iy/v.mass
                    v.dy = v.vy*dt
                end
                -- print(v.name)
                -- print(v.driver.ay)
                -- print(v.vy)
                -- print(v.dy)
                if v.vy>max_vy then v.vy = max_vy end
                v.driver = nil
            end
        end
    end
    
    for i=#self.items,1,-1 do
        local v = self.items[i]
        local col_solve = v.col_solve or nil
        local actualX, actualY, cols, len = self.world:move(v, v.x+v.dx,v.y+v.dy,col_solve)
        if small(v.y-actualY) then v.vy = 0 end
        if small(v.x-actualX) then v.vx = -v.vx*0.6 end
        v.x, v.y = actualX, actualY
        -- if not small(v.vx) then v.vx = v.vx - v.vx*0.7*dt end
    end
end

return dynamics
