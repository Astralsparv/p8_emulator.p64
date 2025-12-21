--[[pod_format="raw",created="2025-11-08 13:48:55",modified="2025-12-21 21:03:26",prog="bbs://strawberry_src.p64",revision=630,xstickers={}]]
include "fs.lua"
include "wrangle.lua"
include "env.lua"
include "core.lua"
include "helper.lua"


p8=nil
p8path=""
frame_counter=0

function _init()
	cmd={}
	if (settings.fullscreen) then
		window{cursor=0,pauseable=true}
	else
		window{title="P8 Emulator",width=128,height=128,resizeable=false,autofocus=true,cursor=1,pauseable=true}
	end
	wrangle()
	menuitem{id=1,label="Return to CMD",shortcut="Q",action=function() p8=nil end}
	fetch("/system/fonts/p8.font"):poke(0x4000)
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
	
	loadCartridge("p8_roms/welcome.p8")
end

p8frame=userdata("u8",128,128)

function _update()
	local factor=2
	frame_counter+=1
	if(not p8)then
		cls()
--		spr(1,1,1)
	else
		set_draw_target(p8frame)
		p8._execute()
		set_draw_target()
		updateCartdata()
		if (settings.fullscreen) then
			--480/2=240, half of screen width
			--270/2=135, half of screen height
			--240-(256/2),135-(7/2), centered based on a double scale p8 frame
			--position = 112,7
			cls()
			sspr(p8frame,0,0,128,128,112,7,256,256)
		else
			p8frame:blit()
--			cls()
--			for i=0, 255 do
--				spr(i,(i%16)*8,flr(i/16)*8)
--			end
		end
	end
--	notify(stat(1)*100)
end

on_event("drop_items",function(msg)
	assert(#msg.items>0)
	local path=msg.items[1].fullpath

	if(not path)then
		add(cmd,"\fesource error\n\f2| \f7invalid path")
		return
	end

	if(path:ext()=="p8")then
		loadCartridge(path)
	else
		notify("invalid or incompatible file format (must be .p8)")
	end
end)