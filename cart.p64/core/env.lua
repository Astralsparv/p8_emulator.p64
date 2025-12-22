--[[pod_format="raw",created="2025-11-08 13:49:25",modified="2025-12-22 17:53:32",prog="bbs://strawberry_src.p64",revision=159,xstickers={}]]
local function clone_env(env)
	local new={}
	for k, v in pairs(env) do
		new[k]=v
	end
	return new
end

p8env=clone_env(_ENV)
--p8env["‹"]=0
--p8env["‘"]=1
--p8env["”"]=2
--p8env["ƒ"]=3
--p8env["—"]=4
--p8env["Ž"]=5
include "core/p8functs/loader.lua"