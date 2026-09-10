# Terminal Utilities

The Pico-8 emulator has a terminal, made to emulate the look (and commands) of the Pico-8 emulator.

All utilities related to the filesystem are run in their own filesystem, by default being `/appdata/p8_emulator/` (location cannot yet be changed by the end-user without modifying the code, root string found at `/fs.lua`).

The terminal can be accessed during cartridge runtime, and then resumed using the `resume` command, alongside being available upon the emulator booting.

## Adding a terminal utility

All terminal utilities are found at `/util/...`, being `.lua` files.

The terminal utility functions are as follows:

```lua
return function(args,options)
	if (args[1]=="hi") then
		return "hey there!"
	end
	if (options.noprint) then
		return ""
	end
	return "mother, i'm inside of the\nterminal text"
end
```

Generally, terminal returns make use of P8SCII for formatting, mainly setting colours. This can be seen with `\f8` for red, or `\f7` for white and `\f6` for gray.

See the Picotron manual for more information on P8SCII.

You should avoid making use of anything that doesn't match the original Pico-8, e.g: using big text in the terminal.