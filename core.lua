--[[pod_format="raw",created="2025-11-19 18:34:14",modified="2025-12-20 23:11:23",prog="bbs://strawberry_src.p64",revision=89,xstickers={}]]
-- core.lua
cdata={}
function load_p8(p8path)
	local file=fetch(p8path)
	if(not file)notify("could not load: "..p8path) return nil
	
	--extract sections
	local code=extract_section(file,"__lua__")or file
	local gfx=extract_section(file,"__gfx__")or ""
	code=code:gsub("‹","0"):gsub("‘","1"):gsub("”","2"):gsub("ƒ","3")
	if code:find("%f[%a]goto%f[%A]") then
		notify("'goto' is not supported in P8 Runner")
		return nil
	end
	gfx=gfx:gsub("\n","")
	
	--create env
	local env={}
	for k,v in pairs(p8env) do env[k]=v end
	env._menuitems={}
	--load spritesheet (credits to @pancelor)
	local sizestr=string.format("%02x%02x",mid(0,255,128),mid(0,255,128))
	env._spritesheet=userdata("[gfx]"..sizestr..gfx.."[/gfx]")
	env._time=0
	env.spr=function(i,x,y,w,h,fx,fy)w=(w or 1)*8 h=(h or 1)*8 local bx=(fx and 1) or 0 local by=(fy and 1) or 0 sspr(env._spritesheet,(i%16)*8,flr(i/16)*8,w,h,x+bx*w,y+by*h,w*(1-2*bx),h*(1-2*by))end
	env.sspr=function(sx,sy,sw,sh,dx,dy,dw,dh,fw,fh)sspr(env._spritesheet,sx,sy,sw,sh,dx,dy,dw,dh,fw,fh)end
	env.time=function()return env._time end
	env.t=env.time
	
	--compile and run code
	local fn,err=load(code,p8path,"t",env)
	if(not fn)error("compile error: "..err)
	fn()
	
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

function cdata:load(id)
	local tbl={}
	if(not fstat("/appdata/p8runner/cdata.pod"))store("/appdata/p8runner/cdata.pod",{})
	if(not cdata.database)then
		db=fetch("/appdata/p8runner/cdata.pod")
		if(db)then
			cdata.database=db
		else
			cdata.database={}
		end
	end
	if(not cdata.database[id])then
		for i=0,63 do add(tbl,0)end
		cdata.database[id]=tbl
	end
	return cdata.database[id]
end

function cdata:save()
	if(type(cdata.database)=="table")then
		store("/appdata/p8runner/cdata.pod",cdata.database)
	else
		notify("[CDATA]: no database to save")
	end
end