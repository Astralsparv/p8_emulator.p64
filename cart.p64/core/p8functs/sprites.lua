--[[pod_format="raw",created="2025-12-21 15:10:09",modified="2025-12-22 18:55:31",revision=106]]
--uses built in spritebank
--some fixes applied through stuff found in Soupster's code
--spr(i,x,y,w,h,fx,fy)
p8env.spr=function(i,x,y,w,h,fx,fy)
	i=i or 0
	i\=1
	x=x or 0
	y=y or 0
	w=(w or 1)*8
	h=(h or 1)*8
	--sspr(userdata,sx,sy,sw,sh,dx,dy,dw,dh,fx,fy)
	return sspr(spritesheet,(i%16)*8,flr(i/16)*8,w,h,x,y,w,h,fx,fy)
end

p8env.sspr=function(...)
	return sspr(spritesheet,...)
end
p8env.sget=function(x,y)
	return spritesheet:get(x,y)
end