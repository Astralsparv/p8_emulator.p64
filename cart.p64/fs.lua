--[[pod_format="raw",created="2025-12-21 13:10:28",modified="2025-12-22 17:08:58",revision=11]]
local root="/appdata/p8_emulator/"
fs={
	cartdata="cartdata/"
}
mkdir(root)
for k,v in pairs(fs) do
	fs[k]=root..v
	mkdir(fs[k])
end

--also handles updates to settings!
local default_settings={
	fullscreen=false,
	ripTitle=true
}

settings=fetch(root.."settings.pod") or {}
local dirty=false
for k,v in pairs(default_settings) do
	if (settings[k]==nil) settings[k]=v dirty=true
end

if (dirty) store(root.."settings.pod",settings) dirty=nil