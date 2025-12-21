--[[pod_format="raw",created="2025-12-21 13:26:06",modified="2025-12-21 13:35:06",revision=13]]
on_event("select_file", function(msg)
	if not msg.filename then
		return
	end
	if (not awaitingFile) return
	
	loadCartridge(msg.filename)
	awaitingFile=false
end)

function wrangle()
	menuitem{
		id="open",
		label="Open p8 file",
		shortcut="CTRL-O",
		action=function()
			create_process("/system/apps/filenav.p64", {
				open_with = pid(),
				intention = "select_file",
				path = pwd().."/p8_roms",
				window_attribs = {
					workspace="current",
					autoclose=true
				}
			})
			--stops false select_file events
			awaitingFile=true
		end
	}
end