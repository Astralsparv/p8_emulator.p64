--[[pod_format="raw",created="2025-11-19 18:34:14",modified="2025-12-24 00:15:39",prog="bbs://strawberry_src.p64",revision=925,xstickers={}]]
include "core/env.lua"

local _time=0
local frame_counter=0
wantedFramerate=30 --global, needed by stat

spritesheet={}
mapsheet={}

local cartTitle=""

local function split(str, sep)
	local t={}
	sep=sep or "%s"
	local pattern = "([^"..sep.."]+)"
	for part in str:gmatch(pattern) do
		table.insert(t, part)
	end
	return t
end

local function ripGFF(section) --sprite flags
	local gff=section.gff
--	local gff=extract_section(file,"__gff__")
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

local function ripSpritesheet(section)
	local gfx=section.gfx
--	local gfx=extract_section(file,"__gfx__")
	if (not gfx) return userdata("u8",128,128)
	gfx=gfx:split("\n",false)
	
	spritesheet=userdata("u8",128,128)
	
	for y=0,127 do
		local line=gfx[y+1] or ""
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

local function ripMap(sections,spritesheet)
	local map=sections.map
	if (not map) return nil
	map=map:gsub("\n","")
	mapsheet=userdata("u8",128,64)
	--custom map setup
	
	--load top half from __map__
	for y=0, 31 do
		for x=0, 127 do
			local i=(y*128+x)*2+1
			local hex=map:sub(i,i+1)
			local tile=tonumber(hex,16) or 0 --base 16
			mapsheet:set(x,y,tile)
		end
	end
	
	--load bottom from __gfx__
	--1 pixel = 4 bits (0-15), so half a byte
	--spritesheet:get(x,y) == gets two pixels because get returns 1 byte
	
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

			mapsheet:set(x,y,tile)
		end
	end
	
	return ud
end

local translations={
	[""]=-2560.5,
	["–"]=-31455.5,
	["„"]=32125.5,
	["‘"]=1,
	["“"]=6943.5,
	["˜"]=3855.5,
	["”"]=2,
	["ˆ"]=-19008.5,
	["Ž"]=4,
	[""]=-20032.5,
	["€"]=0.5,
	["’"]=-20128.5,
	["ƒ"]=3,
	["…"]=-18402.5,
	["†"]=-1632.5,
	["‡"]=20927.5,
	["‰"]=-26208.5,
	["Š"]=-20192.5,
	["‹"]=0,
	["™"]=21845.5,
	["—"]=5,
	["‚"]=20767.5,
	["•"]=-2624.5,
	[""]=23130.5,
	[""]=-25792.5,
	["Œ"]=-24351.5
}

local function ripLua(sections)
--	local lua=extract_section(file,"__lua__")
	local lua=sections.lua
	--does conversion stuff
	store("/ram/lua.lua",lua)
	lua=fetch("/ram/lua.lua")
	rm("/ram/lua.lua")
	local nextCode=128
	local mapping={}
	lua=lua:gsub("//", "--") --pico8 supports // as a comment
	if (settings.ripTitle) then
		local nl=lua:split("\n",false)
		if (nl[1]:sub(1,2)=="--") then
			cartTitle=nl[1]:sub(3,#nl[1])
			if (cartTitle:sub(1,1)==" ") cartTitle=cartTitle:sub(2,#cartTitle)
		end
		nl=nil
	end
	
--	--btn(...) btnp(...)
--	lua=lua:gsub("(%f[%w]btn[p]?)%((.-)%)", function(func, arg)
--		for emoji,num in pairs(translations) do
--			arg=arg:gsub(emoji, tostring(num))
--		end
--		return func.."("..arg..")"
--	end)
--	
--	--fillp(...)
--	lua=lua:gsub("(%f[%w]fillp?)%((.-)%)", function(func, arg)
--		for emoji,num in pairs(translations) do
--			arg=arg:gsub(emoji, tostring(num))
--		end
--		return func.."("..arg..")"
--	end)
	
	return lua
end

--todo: i hate you, i hope you get turned into paper and ripped
local function ripSFX(file)
	local sfx=extract_section(file,"__sfx__")
	
	--[[
p8 storage
The sound effects section begins with the delimiter __sfx__.

Sound data is stored in the .p8 file as 64 lines of 168 hexadecimal digits
(84 bytes, most significant nybble first), one line per sound effect (0-63).

The byte values (hex digit pairs, MSB) are as follows:

byte 0: The editor mode and filter switches. See Here for more info.
byte 1: The note duration, in multiples of 1/128 second.
byte 2: Loop range start, as a note number (0-63).
byte 3: Loop range end, as a note number (0-63).
bytes 4-84: 32 notes
Each note is represented by 20 bits = 5 nybbles = 5 hex digits. (Two notes use five bytes.) The nybbles are:

nybble 0-1: pitch (0-63): c-0 to d#-5, chromatic scale
nybble 2: waveform (0-F): 0 sine, 1 triangle, 2 sawtooth, 3 long square, 4 short square, 5 ringing, 6 noise, 7 ringing sine; 8-F are the custom waveforms corresponding to sound effects 0 through 7 (PICO-8 0.1.11 "version 11" and later)
nybble 3: volume (0-7)
nybble 4: effect (0-7): 0 none, 1 slide, 2 vibrato, 3 drop, 4 fade_in, 5 fade_out, 6 arp fast, 7 arp slow; arpeggio commands loop over groups of four notes at speed 2 (fast) and 4 (slow)
Note that this is very different from the in-memory layout for sound data.

ptron memory
	/system/apps/system/sfx.p64/data.lua
		poke2(addr, 64) -- len
		poke(addr+2,16) -- spd
		poke(addr+3,0)  -- loop0
		poke(addr+4,0)  -- loop1
		poke(addr+5,0)  -- delay
		poke(addr+6,0)  -- flags (0x1 mute)
		poke(addr+7,0)  -- unused
		
		-- pitch, inst, vol: not set (0xff)
		memset(addr+8, 0xff, 64*3)
		
		-- fx, fx_p: clear
		memset(addr+8+64*3, 0x0, 64*2)
	--]]
end

function load_p8(path)
	if (not fstat(path)) then
		notify(path.." doesn't exist :C")
		return nil
	end
	
	local file=fetch(path,{raw_str=true})
	if (not file) then
		notify("could not fetch: "..path)
		return nil
	end
	include "core/pause_menu.lua"
	
	cartTitle=(fetch_metadata(path) or {}).title or path:basename()
	--extract sections
	
	local sections=extract_sections(file)
	
	local code=ripLua(sections)
	
	--why?
	if code:find("%f[%a]goto%f[%A]") then
		notify("'goto' is not supported in P8 Runner")
		return nil
	end
	
	--create env
	local env={}
	for k,v in pairs(p8env) do env[k]=v end
	for k,v in pairs(translations) do env[k]=v end
	
	spritesheet=ripSpritesheet(sections)
	ripGFF(sections)
	ripMap(sections,spritesheet)
--	memmap(ripMap(sections,spritesheet),0x100000)
	env.time=function()return _time end
	env.t=env.time
	
	--compile and run code
	local fn,err=load(code,path,"t",env)
	
	if(not fn) then
		store("/ram/lua.lua",code)
		open("/ram/lua.lua")
		printh("compile error: "..err)
		error("compile error: "..err)
	end
	srand(flr(rnd(0x7fff)))
	
	_time=0
	p8frame=userdata("u8",128,128)
	frame_counter=0
	wantedFramerate=30
	fn()
	
	set_draw_target(p8frame)
	set_draw_target()
	
	--check `_update` and/or `_draw`
	if(env._update60)then
		env._draw=env._draw or function() end
		wantedFramerate=60
		env._execute=function()
			env._update60()
			env._draw()
			_time+=0.0167
		end
	elseif(env._update)then
		env._draw=env._draw or function() end
		wantedFramerate=30
		--is that how time is handled??
		env._execute=function()
			env._update()
			env._draw()
			_time+=0.0333
		end
	elseif(env._draw)then
		wantedFramerate=30
		env._execute=function()
			env._draw()
			_time+=0.0333
		end
	else
		wantedFramerate=0
		env._execute=function()
			_time+=0.0333 --still do this?
		end
	end
--	wantedFramerate=300
	
	if(env._init)env._init()
	
	p8path=path
	window{title=cartTitle}
	return env
end

function extract_sections(file)
	local sections={}
	local pattern="__([%w_]+)__\n?" --section headers
	local last_pos=1
	while true do
		local s,e,header=file:find(pattern,last_pos)
		if (not s) break
		local next_s=file:find("__[%w_]+__",e+1)
		local content
		if (next_s) then
			content=file:sub(e+1,next_s-1)
		else
			content=file:sub(e+1)
		end
		if (content:sub(1,1)=="\n") then
			content=content:sub(2)
		end
		sections[header]=content
		last_pos=e+1
	end
	return sections
end


local acc=0
function update_p8()
	frame_counter+=1
	acc+=wantedFramerate
	while (acc>=60) do
		acc-=60 --pt fps
		set_draw_target(p8frame)
		
		if (menu.active) then
			menu:update()
			menu:draw()
		else
			p8._execute()
		end
		fillp()
		
		if (btnp(6)) then --i don't think this is right?
			menu.active=not menu.active
		end
		
		set_draw_target()
		updateCartdata()
	end
end