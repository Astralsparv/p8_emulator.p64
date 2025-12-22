--[[pod_format="raw",created="2025-12-21 12:56:57",modified="2025-12-22 16:42:02",revision=6]]
function loadCartridge(path)
	p8=load_p8(path)
	if(p8)then
	--			pmenu:init()
		p8.name=sub(p8path,p8path:find("[^/\\]+$"))
		notify("cart loaded: "..path)
	else
--		notify("error loading cart "..path)
	end
end