--[[pod_format="raw",created="2025-12-21 12:56:57",modified="2025-12-21 12:57:03",revision=2]]
function loadCartridge(path)
	p8=load_p8(path)
	if(p8)then
	--			pmenu:init()
		p8.name=sub(p8path,p8path:find("[^/\\]+$"))
		notify("cart loaded: "..path)
	else
		add(cmd,"\feerror loading cart\f6")
	end
	if(p8)window{title=p8.name}
end