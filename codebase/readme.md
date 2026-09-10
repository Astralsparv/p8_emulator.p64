# Codebase

The code is messy in a lot of places, and many places likely need commenting in detail.

These docs will explain how the cart/code is structured.

Information on the pico-8 runtime can be found [here](pico_8_runtime/readme.md)

Information on the automated test suite can be found [here](test_suite/readme.md)

Information on keyboard shortcuts can be found [here](shortcuts.md)

Information on terminal commands can be found [here](terminal_util.md)

## Miscellaneous sections

### `/gfx/...`

`/gfx/0.gfx` should be empty; this will be overwritten by Pico-8 anyway.

`/gfx/1.gfx` is used to store miscellaneous sprites, such as color tables or the Pico-8 logo for the boot animation.

### `/sfx/...`

`/sfx/0.sfx` contains the Pico-8 instruments (not fully done, also requires filters for each effect, such as vibrato or dampen) and sfx 0 is the sound effect for Pico-8's boot.

### `/p8_roms/...`

These are any pico-8 roms that are just stored in the cart for safe-keeping.

Pico-8 carts found at `/p8_roms/tests/...` can be installed to the Pico-8 virtual drive with the `install_tests` command.

### not_implemented warning

The function `not_implemented` should be used when warning the end-user of a feature that has been detected that isn't yet supported.

For example, if `print` wasn't supported

```lua
p8env.print=function()
    not_implemented("print() function")
end
```
Currently this prints to the terminal and is notified on the screen, but may be updated later on. By using the same function for all warnings, it allows for it to be easily updated without manually updating other code.

## Debug mode

Debug mode, mainly useful for messing with file formats and monitoring stored data such as the spritesheet, mapsheet or spriteflags, can be enabled by commenting `--debug=nil` in:

```lua
local debug={ --fullscreen required
	spritesheet_spr=false,
	spriteflags_fget=false
}
debug=nil --easy to comment in/out! if nil it wont debug, comment to enable debug
```

This requires full screen to be enabled in the settings, and fills the left side of screen with debug display and the right with the Pico-8 frame (at 256x256 compared to 128x128).