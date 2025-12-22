--[[pod_format="raw",created="2025-11-08 13:48:55",modified="2025-12-22 18:20:08",prog="bbs://strawberry_src.p64",revision=685,xstickers={}]]
include "fs.lua"
include "wrangle.lua"
include "core/core.lua"
include "helper.lua"
fetch("/system/fonts/p8.font"):poke(0x4000)

p8=nil
p8path=""

function _init()
	cmd={}
	if (settings.fullscreen) then
		window{cursor=0,pauseable=true}
	else
		window{title="P8 Emulator",width=128,height=128,resizeable=false,autofocus=true,pauseable=true}
	end
	wrangle()
	
--	poke4(0x5000+48*4, --set pal 48-63 to the p8 "secret colors"
--		0x291814,0x111d35,0x422136,0x125359,
--		0x742f29,0x49333b,0xa28879,0xf3ef7d,
--		0xbe1250,0xff6c24,0xa8e72e,0x00b543,
--		0x065ab5,0x754665,0xff6e59,0xff9d81)--credits to @pancelor
	--make it match p8, idk if this is right but it feels it - gotta check properly
	--isn't seem 100%, letting go and repeating has too long of a delay
	--going based on 1/2 of ptron since thats 60fps 
	poke(0x5f5e, 15)
	poke(0x5f5d, 4)
	
	include "autoboot.lua"
end

p8frame=userdata("u8",128,128)

function _update()
	local factor=2
	if (p8) then --safety: there should always be a p8
		update_p8()
		if (settings.fullscreen) then
			cls()
			sspr(p8frame,0,0,128,128,112,7,256,256)
		else
			p8frame:blit()
--			cls()
--			for i=0, 255 do
--				local x,y=(i%16)*8,flr(i/16)*8
--				spr(i,x,y)
--			end
		end
	end
end

on_event("drop_items",function(msg)
	assert(#msg.items>0)
	local path=msg.items[1].fullpath

	if(not path)then
		notify("invalid path")
		return
	end

	if(path:sub(-3)==".p8")then --don't use ext(), v1.0.p8:ext() is  ".0.p8"
		loadCartridge(path)
	else
		notify("invalid or incompatible file format (must be .p8)")
	end
end)