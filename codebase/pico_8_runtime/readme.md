# Pico-8 runtime

Most things related to the Pico-8 runtime is found at `/core/...`, with `/core/core.lua` (may be renamed to `/core/main.lua`) stitching it together.

This defines things such as `wantedFramerate` (will be moved to be a property of `loaded_p8`) and `loaded_p8`, general things for the Pico-8 environment.

The variable `p8frame` (defined in `/main.lua`, will be moved to `/core/core.lua`) is a `userdata u8`, being the 128x128 Pico-8 display. Each time the pico-8 environment is in runtime; the draw target is set to this userdata.

The picotron `_draw()` function simply `blit()`s (windowed) or `sspr()`s (fullscreen) to the screen.

## `loaded_p8`

This is the table that will hold all data to do with the pico-8 environment that is globally accessible.

It's properties are as follows:

### filepath (str)
The filepath of the Pico-8 cartridge

### title (str)
The title of the Pico-8 cartridge, generated from the comments in the first Pico-8 code tab or the basename of the file.

### env (table)
The Pico-8 lua environment; this shouldn't need to be touched manually and new functions are implemented in `/core/p8functs/...`.

### code (str)
The raw code of the Pico-8 cartridge (should be able to just delete to save memory once all actions related are done)

### code_length (number)
The length of the code, for the print in the terminal with:
```
> load cart.p8
```
(should be able to just delete to save memory once all actions related are done)

### mem (table)
The memory of the Pico-8 environments for where it can't be passed through to Picotron. This will likely be changed to a `u8` userdata in the future but would technically be more memory efficient as a table. Pico-8 memory operations on userdata will likely be faster though.

The userdata size would be allocated 8000 bytes (though most passthrough to Picotron)

### active (bool)
Whether the cartridge is actively running or not.

### spritesheet (userdata u8)
A 128x128 userdata defining the loaded spritesheet. This mixes in with memory peeking/poking **(but is barely implemented!)** and is also `set_spr()`'d for `map()` optimisations (using Picotron's C map function for speed, may be improved with sprite batching but still requires `set_spr`).

### mapsheet (userdata i16)
A 128x64 userdata defining the mapsheet. Memory operations related to this are **not** implemented in any state.

### spriteflags (userdata u8)
A 256x1 userdata defining the spriteflags. These are also `fset()`'d for optimisations for `map()` as it uses Picotron's C map function for speed.

### created (number)
A timestamp (with `time()`, accurate to picotron `_update`) of when the cart was loaded

### created_epoch (number)
An epoch timestamp (with `stat(86)()`) of when the cart was loaded.

### menu_triggered (bool|nil)
When set, the menu will be triggered the next time the cart is updated.

Used by `extcmd()`.

## Ripping

Ripping is triggered in `/core/core.lua`, using either `.p8` or `.p8.png` (`.p8.png` not fully supported) format.

Ripping code can be found at `/core/ripping/...`.

The code for splitting sections for `.p8` format is found in `/core/core.lua` and will be moved to a file in `/core/ripping/p8/...`

The wiki is the best location for documentation on the file formats.

## Functions

Pico-8 functions can be added to the Pico-8 environment by making a file or adding them to a pre-existing file in `/core/p8functs/...`.

Each file in here is automatically fetched and included in runtime, and does not need to be manually added to the code when a new `.lua` or function is added.

New Pico-8 functions are added in a `.lua` file in `/core/p8functs/...`; feel free to look at pre-existing files for this. `.lua` files should be made for new categories, and pre-existing `.lua` files should be used for categories already added.

They look like the following:
```lua
p8env.example_function=function(argument)
    return argument+1
end
```

and the Pico-8 cart would call `example_function()`.

Non pico-8 functions should **not** be added to this.

> Currently any picotron functions that exist can be used by the Pico-8 environment. This will eventually be changed with a list of all Pico-8 functions and only allowing those to be in the virtual environment. Some Picotron functions are included for compatibility as many work the same or very similar (very similar functions will require custom creations, but can likely be a wrapper for the picotron function)