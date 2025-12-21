--[[pod_format="raw",created="2025-11-19 18:34:14",modified="2025-12-21 21:10:41",prog="bbs://strawberry_src.p64",revision=546,xstickers={}]]
-- core.lua
cdata={}

spritesheet={}

local function split(str, sep)
	local t={}
	sep=sep or "%s"
	local pattern = "([^"..sep.."]+)"
	for part in str:gmatch(pattern) do
		table.insert(t, part)
	end
	return t
end

local function ripGFF(file) --sprite flags
	local gff=extract_section(file,"__gff__")
	if (gff==nil) return
	gff=split(gff,"\n")
	
	for sp=0, 255 do
		local y=1
		if (sp>=128) y=2
		local i=(sp%128)*2+1
		local hex=gff[y]:sub(i,i+1)
		fset(sp,tonumber(hex,16))
	end
end

local function ripSpritesheet(file)
	local gfx=extract_section(file,"__gfx__")
	if (not gfx) return userdata("u8",128,128)
	gfx=gfx:split("\n",false)
	
	spritesheet=userdata("u8",128,128)
	
	for y=0,127 do
		local line=gfx[y+2] or ""
		for x=0,127 do
			local c=line:sub(x+1, x+1) or "0"
			spritesheet:set(x, y, tonum("0x"..c))
		end
	end
	
	for i=0, 255 do
		local x,y=(i%16)*8,flr(i/16)*8
		local sprUD=userdata("u8",8,8)
		spritesheet:blit(sprUD,x,y,0,0,8,8)
		set_spr(i,sprUD)
	end
	return spritesheet
end

local function ripMap(file)
	spritesheet=spritesheet or ripSpritesheet(file)
	local map=extract_section(file,"__map__")
	if (not map) return nil
	map=map:gsub("\n","")
	local ud=userdata("i16",128,64)
	--maps == i16
	
	--load top half from __map__
	for y=0, 31 do
		for x=0, 127 do
			local i=(y*128+x)*2+1
			local hex=map:sub(i,i+1)
			local tile=tonumber(hex,16) or 0 --base 16
			ud:set(x,y,tile)
		end
	end
	
	--load bottom from __gfx__
	--1 pixel = 4 bits (0-15), so half a byte
	--spritesheet:get(x,y) == gets two pixels because get returns 1 byte
	
	local hit={}
	for y=32,63 do
		local sy=64+(y-32)*2
		for x=0,127 do
			--1 byte = 1 tile
			local offset=flr(x/64)
			local px=(x%64)*2
			local py=sy+offset
			
			local low=spritesheet:get(px, py)
			local high=spritesheet:get(px+1, py)
			local tile=low|(high << 4)
			hit[sy]=true

			ud:set(x,y,tile)
		end
	end
	
	printh(pod(hit))
	return ud
end

function load_p8(path)
	if (not fstat(path)) then
		notify(path.." doesn't exist :C")
		return nil
	end
	
	local file=fetch(path,{raw_str=true})
	if (not file) then
		notify("could not fetch: "..path.." - try clearing metadata") return nil
	end
	
	--extract sections
	local code=extract_section(file,"__lua__")or file
	code=code:gsub("‹","0"):gsub("‘","1"):gsub("”","2"):gsub("ƒ","3")
	if code:find("%f[%a]goto%f[%A]") then
		notify("'goto' is not supported in P8 Runner")
		return nil
	end
	
	--create env
	local env={}
	for k,v in pairs(p8env) do env[k]=v end
	env._menuitems={}
	env._time=0
	spritesheet=ripSpritesheet(file)
	ripGFF(file)
	memmap(ripMap(file,spritesheet),0x100000)
--	env.spr=function(i,x,y,w,h,fx,fy)w=(w or 1)*8 h=(h or 1)*8 local bx=(fx and 1) or 0 local by=(fy and 1) or 0 sspr(spritesheet,(i%16)*8,flr(i/16)*8,w,h,x+bx*w,y+by*h,w*(1-2*bx),h*(1-2*by))end
--	env.sspr=function(sx,sy,sw,sh,dx,dy,dw,dh,fw,fh)sspr(spritesheet,sx,sy,sw,sh,dx,dy,dw,dh,fw,fh)end
	env.time=function()return env._time end
	env.t=env.time
	
	--compile and run code
	local fn,err=load(code,path,"t",env)
	if(not fn)error("compile error: "..err)
	set_draw_target(p8frame)
	fn()
	set_draw_target()
	
	--check `_update` and/or `_draw`
	if(env._update60)then
		env._draw=env._draw or function()end
		env._execute=function()env._update60()env._draw()env._time+=0.0167 end
	elseif(env._update)then
		env._draw=env._draw or function()end
		env._execute=function()if(frame_counter%2==0)then env._update()env._draw()env._time+=0.0333 end end
	elseif(env._draw)then
		env._execute=function()if(frame_counter%2==0)then env._draw()env._time+=0.0333 end end
	end
	
	--execute `_init` if exists
	if(env._init)env._init()
	srand(flr(rnd(0x7fff)))
--	pmenu:refresh()
	p8path=path
	return env
end

function extract_section(filestr,header)
	local a0,a1=filestr:find(header)
	if not a0 then return nil end
	local b0=filestr:find("\n__[%w_]+__\n",a1+1)
	local i0=a1+1
	local i1=b0 and (b0-1)or #filestr
	return filestr:sub(i0,i1)
end