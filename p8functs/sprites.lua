--[[pod_format="raw",created="2025-12-21 15:10:09",modified="2025-12-21 16:26:04",revision=43]]
--uses built in spritebank
p8env.spr=function(i,x,y,w,h,fx,fy)
	w=(w or 1)*8
	h=(h or 1)*8
	local bx=(fx and 1) or 0
	local by=(fy and 1) or 0
	return sspr(spritesheet,(i%16)*8,flr(i/16)*8,w,h,x+bx*w,y+by*h,w*(1-2*bx),h*(1-2*by))
end

p8env.sspr=function(...)
	return sspr(spritesheet,...)
end