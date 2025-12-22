--[[pod_format="raw",created="2025-12-21 22:21:25",modified="2025-12-22 17:24:40",revision=23]]
local cart
if (#env().fileview>0) then
	cart=env().fileview[1].location
end

if (cart==nil or cart:sub(-3)!=".p8") then
	cart="p8_roms/welcome.p8"
end

loadCartridge(cart)