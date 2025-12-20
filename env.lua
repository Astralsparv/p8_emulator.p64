--[[pod_format="raw",created="2025-11-08 13:49:25",modified="2025-11-21 10:24:46",prog="bbs://strawberry_src.p64",revision=148,xstickers={}]]
-- env.lua
p8env={
	--math
	abs=abs,
	sgn=sgn,flr=flr,
	ceil=ceil,min=min,
	mid=mid,max=max,
	sqrt=sqrt,cos=cos,
	sin=sin,atan2=atan2,
	rnd=rnd,srand=srand,
	--data
	chr=chr,
	ord=ord,split=split,
	sub=sub,tostr=tostr,
	tonum=tonum,add=add,
	del=del,deli=deli,
	all=all,ipairs=ipairs,
	pairs=pairs,foreach=foreach,
	unpack=unpack,type=type,
	--input
	btn=btn,btnp=btnp,
	--gfx
	cls=cls,
	camera=camera,pget=pget,
	pset=pset,line=line,
	rect=rect,rectfill=rectfill,
	circ=circ,circfill=circfill,
	oval=oval,ovalfill=ovalfill,
	print=print,color=color,
	pal=pal,palt=palt,	
	--misc/corutines
	count=count,music=music,
	sfx=sfx,cocreate=cocreate,
	coresume=coresume,costatus=costatus,
	--spr, sspr, time, menuitem and cartdata are in `core.lua`
}

local _stat_switch={
	[1]=stat, --cpu (total)
	[2]=stat, --cpu (sys)
	[4]=get_clipboard,
	[7]=stat, --framerate
	[30]=function()return peektext()!=nil end,
	[31]=function()return readtext(),0 end,
	[32]=function()return select(1,mouse())end, --mouse_x
	[33]=function()return select(2,mouse())end, --mouse_y
	[34]=function()return select(3,mouse())end, --mouse_b
	[35]=function()return select(4,mouse())end, --wheel_x
	[36]=function()return select(5,mouse())end, --wheel_y
}

function p8env.stat(id)
	local fn=_stat_switch[id]
	if(fn)then return fn(id)else return 0 end
end