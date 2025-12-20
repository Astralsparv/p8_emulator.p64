--[[pod_format="raw",created="2025-11-08 13:48:55",modified="2025-11-27 23:48:30",prog="bbs://strawberry_src.p64",revision=418,xstickers={}]]
-- main.lua
include"env.lua"
include"core.lua"

p8=nil
p8path=""
frame_counter=0
pmenu={}
function _init()
	cmd={}
	window{title="P8 Runner",width=128,height=128,resizeable=false,autofocus=true,cursor=0}
	menuitem{id=1,label="Return to CMD",shortcut="Q",action=function() p8=nil end}
	fetch("/system/fonts/p8.font"):poke(0x4000)
	pmenu:init()
	poke4(0x5000+48*4, --set pal 48-63 to the p8 "secret colors"
		0x291814,0x111d35,0x422136,0x125359,
		0x742f29,0x49333b,0xa28879,0xf3ef7d,
		0xbe1250,0xff6c24,0xa8e72e,0x00b543,
		0x065ab5,0x754665,0xff6e59,0xff9d81)--credits to @pancelor
end
function _update()
	local factor=2
	frame_counter+=1
	if(not fstat("/appdata/p8runner"))mkdir("/appdata/p8runner")
	if(not p8)then
		cls()
		spr(1,1,1)
	else
		if(pmenu.bool)then
			pmenu:prc()
		else
			p8._execute()
		end
	end
	if(btnp(6))pmenu.bool=not pmenu.bool pmenu.cursor=1
end

on_event("drop_items",function(msg)
	assert(#msg.items>0)
	local path=msg.items[1].fullpath

	if(not path)then
		add(cmd,"\fesource error\n\f2| \f7invalid path")
		return
	end

	if(sub(path,-3)==".p8")then
		p8=load_p8(path)
		if(p8)then
			pmenu:init()
			p8path=path
			p8.name=sub(p8path,p8path:find("[^/\\]+$"))
			notify("cart loaded: "..path)
		else
			add(cmd,"\feerror loading cart\f6")
		end
		if(p8)window{title=p8.name}
	else
		notify("invalid or incompatible file format")
	end
end)

function pmenu:init()
	pmenu.bool=false
	pmenu.cursor=1
	pmenu.items={
		{label="resume",action=function()self.bool=false end},
		{label="reset cart",action=function()cdata:save()p8=load_p8(p8path)self:init()end},
		{label="quit cart",action=function()cdata:save()p8=nil self:init()window{title="P8 Runner"}end},
	}
end

function pmenu:prc()
	local n=#self.items
	--update
	if(btnp(2))self.cursor-=1
	if(btnp(3))self.cursor+=1
	if self.cursor>n then self.cursor=1
	elseif self.cursor<1 then self.cursor=n end
	if(btnp(4)or btnp(5))then
		local it=self.items[self.cursor]
		if(it and it.action)then
			it.action()
			self.bool=false
		end
	end
	--draw
	local mh=n*8+4*2
	local top=(128-mh)/2
	local bottom=top+mh
	rectfill(21,top,101,bottom,32)
	rect(22,top+1,100,bottom-1,7)

	for i=1,n do
		local p=self.items[i]
		if(p)then
			local y=top+4+(i-1)*8
			print((i==self.cursor and">"or" ")..p.label,27,y+2,7)
		end
	end
end


function pmenu:refresh()
	self.items={{label="resume",action=function()self.bool=false end}}
	if(p8 and #p8._menuitems>0)then
		for i=1,#p8._menuitems do
			add(self.items,p8._menuitems[i])
		end
	end
	add(self.items,{label="reset cart",action=function()cdata:save()p8=load_p8(p8path)self:init()end})
	add(self.items,{label="quit cart",action=function()cdata:save()p8=nil self:init()window{title="P8 Runner"}end})
end