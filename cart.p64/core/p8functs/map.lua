--[[pod_format="raw",created="2025-12-22 18:43:46",modified="2025-12-22 18:55:35",revision=23]]
p8env.map=function(celx,cely,sx,sy,celw,celh,layer)
	celx=celx or 0
	cely=cely or 0 
	sx=sx or 0
	sy=sy or 0
	celw=celw or 128
	celh=celh or 32
	for x=celx, celx+celw-1 do
		local xx=celx*8
		for y=cely, cely+celh-1 do
			local yy=cely*8
			local sp=mapsheet:get(x,y)
			if (sp!=0) then
				if ((not layer) or (fget(sp)&layer)==layer) then
				local xx=sx+(x-celx)*8
				local yy=sy+(y-cely)*8
				p8env.spr(sp,xx,yy)
				end
			end
		end
	end
end
--deprecated.
p8env.mapdraw=map

p8env.mget=function(x,y)
	return mapsheet:get(x,y)
end

p8env.mset=function(x,y,c)
	return mapsheet:set(x,y,c)
end