--[[pod_format="raw",created="2025-12-22 23:52:57",modified="2025-12-23 17:53:42",revision=17]]
p8env.menuitem=function(index,label,callback)
	if (label==nil) then
		deli(menu.editableItems,index)
	else
		if (index>0 and index<6) then
			menu.editableItems[index]={
				label=label,
				callback=callback
			}
		else
			return --avoid updating menu for 0 reason
		end
	end
	updMenuData()
end