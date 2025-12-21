--[[pod_format="raw",created="2025-11-08 13:49:25",modified="2025-12-20 22:55:48",prog="bbs://strawberry_src.p64",revision=152,xstickers={}]]
local function clone_env(env)
	local new={}
	for k, v in pairs(env) do
		new[k]=v
	end
	return new
end

p8env=clone_env(_ENV)
include "overwritefuncts.lua"

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