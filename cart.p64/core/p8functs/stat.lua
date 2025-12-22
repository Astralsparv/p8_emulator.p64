--[[pod_format="raw",created="2025-12-22 00:31:06",modified="2025-12-22 01:49:47",revision=103]]
local function getTime(wanted,utc)
	local prefix=utc and "!" or ""
	if (wanted=="year") then
		return date(prefix.."%Y")
	elseif (wanted=="month") then
		return date(prefix.."%m")
	elseif (wanted=="day") then
		return date(prefix.."%d")
	elseif (wanted=="hour") then
		return date(prefix.."%H")
	elseif (wanted=="minute") then
		return date(prefix.."%M")
	elseif (wanted=="second") then
		return date(prefix.."%S")
	end
end

local stats={
	[0]={0,"stat"},
	--currently identical, make some cpu logger to make these match somewhat to p8 system?
	[1]={1,"stat"},
	[2]={1,"stat"},
	
	[4]={get_clipboard},
	[5]={"43"}, --0.2.7
	[6]={""}, --arbritrary - Parameter string from a third-party load
	[7]={function() return flr(stat(7)/(60/wantedFramerate)) end}, --should be correct, untested
	[8]={function() return wantedFramerate end}, --need to add
	[10]={0}, --unknown stat
	[11]={1}, --amount of displays?
	
	--Pause menu location, to add
--	[12]=-1,
--	[13]=-1,
--	[14]=-1,
--	[15]=-1,
	
--	[16]= --deprec, need more details

--	[27]=, --unknown stat
	[28]={28,"stat"},
--	[29]=-1, --no known equivalent between pt and p8, reportedly returns the number of connected controllers, in 32-bit integer format
	[30]={function()return peektext()!=nil end},
	[31]={function()return readtext(),0 end},
	[32]={function()return select(1,mouse())end}, --mouse_x
	[33]={function()return select(2,mouse())end}, --mouse_y
	[34]={function()return select(3,mouse())end}, --mouse_b
	[35]={function()return select(4,mouse())end}, --wheel_x
	[36]={function()return select(5,mouse())end}, --wheel_y
	
	--[46-56] music, need to check passthrough to PT music (isn't even supported yet, though)
	
	[64]={nil},
	[65]={nil},
	[66]={nil},
	[67]={nil},
	[68]={nil},
	[69]={nil},
	[70]={nil},
	[71]={nil},
	--to 71 nil, but isn't that js default??
	
	[80]={function() return getTime("year",true) end},
	[81]={function() return getTime("month",true) end},
	[82]={function() return getTime("day",true) end},
	[83]={function() return getTime("hour",true) end},
	[84]={function() return getTime("minute",true) end},
	[85]={function() return getTime("second",true) end},
	
	[90]={function() return getTime("year") end},
	[91]={function() return getTime("month") end},
	[92]={function() return getTime("day") end},
	[93]={function() return getTime("hour") end},
	[94]={function() return getTime("minute") end},
	[95]={function() return getTime("second") end},
	
	[90]={3,"stat"},
	[124]={pwd}
}

function p8env.stat(id,...)
	local res=stats[id]
	if (res) then
		if (res[1]==nil) return ""
		if (res[2]) then
			if (res[2]=="stat") return stat(res[1],...)
		elseif (res[2]==nil) then
			local typ=type(res[1])
			if (typ=="function") then
				return res[1]()
			else
				return res[1]
			end
		end
	else
		return 0
	end
end

p8env.tostr=function(v,...)
	return tostr(v,...) or "[nil]"
end