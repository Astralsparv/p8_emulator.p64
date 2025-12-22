--[[pod_format="raw",created="2025-11-08 13:49:25",modified="2025-12-22 01:21:15",prog="bbs://strawberry_src.p64",revision=155,xstickers={}]]
local function clone_env(env)
	local new={}
	for k, v in pairs(env) do
		new[k]=v
	end
	return new
end

p8env=clone_env(_ENV)
include "core/p8functs/loader.lua"