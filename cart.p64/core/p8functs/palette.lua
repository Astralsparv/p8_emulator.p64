--[[pod_format="raw",created="2025-12-22 18:21:08",modified="2025-12-22 19:58:43",revision=69]]
poke(0x550b,0x3f) --actually enable color tables.

--@thelxinoe5 made all of this, i just set it up for the p8s

local function settransparent(c)
	for i=0,15 do
		poke(0x8000+c*64+i,i)
	end
end

local function setopaque(c)
	memset(0x8000+c*64,c,16)
end

local function reassignpal(c0,c1)
	memset(0x8000+c0*64,c1,16)
end

p8env.pal=function(c0,c1,p)
	--make p do stuff
	if (c0) then
		local t=(peek((c0+1)+(c0*64)+0x8000)&0xf)!=c0
		reassignpal(c0,c1)
		if (t) then
			settransparent(c1)
		else
			setopaque(c1)
		end
	else
		pal()
	end
end

p8env.palt=function(c,t)
	if (c) then
		if (t) then
			settransparent(c)
		else
			setopaque(c)
		end
	else
		palt()
	end
end