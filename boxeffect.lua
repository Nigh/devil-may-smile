
local be={}
local array={}

function be:new(x,y,w,h,duration)
    local rect = {x=x,y=y,w=w,h=h,duration=duration,alpha=1}
    table.insert(array,rect)
end

function be:draw()
    for _,v in ipairs(array) do
        love.graphics.setColor(.3,1,.3,v.alpha)
        love.graphics.rectangle("fill",v.x,v.y,v.w,v.h) 
    end
end

function be:update(dt)
    for i=#array,1,-1 do
        v=array[i]
        v.t = v.t or 0
        v.t = v.t+dt
        v.alpha = (v.duration-v.t)/v.duration
        if v.t>v.duration then
            table.remove( array, i )
        end
    end
end

return be
