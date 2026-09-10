# Shortcuts

Shortcuts, such as `CTRL-M` or `CTRL (-/+)` are stored at `/shortcuts/...`.

These are loaded in automatically by the emulator and are triggered when the `ctrl` key is held.

They can be triggered by multiple keys at the same time (e.g: requiring `A`, `B`, and `C` to be pressed at the same time) or a single key (e.g: `M` for mute).

These are handled by `/keyboard_shortcuts.lua`.

There is a hardcoded `p8ctrl_key` variable, set as `alt`, this will be set to be user definable in the future but acts as what Pico-8 sees as `CTRL` for notifications.

## Adding shortcuts

Shortcuts can be added by adding a `.lua` to `/shortcuts/...`, to function; it must return:

### keys (arg-1)

A table of keys, such as `{"a","b","c"}`, or a string such as `"m"`.

### function (arg-2)

The function to be called when this keyboard shortcut is triggered.

## Example

Found at `/shortcuts/mute.lua`
```lua
return "m",function()
	if (p8settings.sound) then
		notify_p8("sound off ("..p8ctrl_key.."-m)",0)
		p8settings.sound=false
	else
		notify_p8("sound on ("..p8ctrl_key.."-m)",1)
		p8settings.sound=true
	end
end
```