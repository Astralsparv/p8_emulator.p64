--[[pod,author="Astralsparv",modified="2025-12-21 14:05:35",notes="Test for cartdata, dget, dset\nIncludes error tests\nCARTDATA ID: p8emulator",title="Cartdata Test",version="1.0b"]]pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
mode="init"
page=0
pagesize=16

local options={
	{label="dset()",action=function() dset(0,0) end},
	{label="dget()",action=function() dget(0) end},
	{label="cartdata()",action=function() cartdata("p8emulator") end},
	{label="enter viewing mode",action=function() mode="viewing" end}
}
local pointer=1

function _update()
	if (mode=="init") then
		if (btnp(2)) pointer-=1
		if (btnp(3)) pointer+=1
		if (pointer<1) pointer=#options
		if (pointer>#options) pointer=1
		if (btnp(4)) options[pointer].action()
	elseif (mode=="viewing") then
		if (btnp(0)) page-=1
		if (btnp(1)) page+=1
		if (page<0) page=3
		if (page>3) page=0
		if (btnp(4)) then
			for i=0,63 do
				dset(i,i)
			end
		elseif (btnp(5)) then
			for i=0, 63 do
				dset(i,flr(rnd(255)))
			end
		end
	end
end

function _draw()
	cls()
	color(7)
	if (mode=="init") then
		print("no cartdata loaded.")
		print("options:")
		for i=1, #options do
			if (pointer==i) then
				print("> "..options[i].label)
			else
				print(options[i].label)
			end
		end
	elseif (mode=="viewing") then
		local x,y=0,0
		for i=0, 63 do
			local s=tostr(i)
			if (#s==1) s="0"..s
			
			print(s.."="..dget(i),x,y)
			y+=6
			if (y>72) y=0 x+=24+4
		end
		
		print("❎ randomise",0,110,7)
		print("🅾️ rebuild indexed",0,116,7)
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
