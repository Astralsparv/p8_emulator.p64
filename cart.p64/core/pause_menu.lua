--[[pod_format="raw",created="2025-12-22 23:51:18",modified="2025-12-23 18:23:00",revision=108]]
menu={
	forcedItems={
		{label="continue"},
		{label="options"},
		{label="reset cart",callback=function() p8env.reset() end},
		{label="exit emulator",callback=function() exit() end} --in the future, you can hold enter to exit (pt-side)
	},
	editableItems={},
	items={},
	selected=1,
	width=80,
	height=0,
	active=false
}
menu.x=64-menu.width/2

function updMenuData()
	menu.items={}
	add(menu.items,menu.forcedItems[1])
	--editable ones come after
	for i=1, #menu.editableItems do
		add(menu.items,menu.editableItems[i])
	end
	--rest of forced items
	for j=2, #menu.forcedItems do
		add(menu.items,menu.forcedItems[j])
	end
	
	menu.height=#menu.items*6+12 --6px top/bottom
	menu.y=64-menu.height/2
end
updMenuData()

menu.update=function()
	if (btnp(2)) menu.selected-=1
	if (btnp(3)) menu.selected+=1
	if (menu.selected<1) menu.selected=#menu.items
	if (menu.selected>#menu.items) menu.selected=1
	local bitfield=-1
	if (btnp(0)) bitfield=0
	if (btnp(1)) bitfield=1
	if (btnp(4) or btnp(5) or btnp(6)) bitfield=112
	local item=menu.items[menu.selected]
	if (bitfield!=-1) then
		if (item.callback) then
			if (type(item.callback)=="function") item.callback(bitfield)
		else
			menu.active=false
		end
	end
end

menu.draw=function()
	local x,y=menu.x,menu.y
	rectfill(x,y,x+menu.width-1,y+menu.height-1,0)
	rect(x,y,x+menu.width-1,y+menu.height-1,7)
	x+=8
	y+=6
	for i=1, #menu.items do
		local s=menu.items[i].label
		if (i==menu.selected) then
			print("\^:0818381808000000",x-8,y,7)
			print(s,x+1,y,7)
		else
			print(s,x,y,7)
		end
		y+=6
	end
end