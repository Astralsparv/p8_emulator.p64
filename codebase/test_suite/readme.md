# Test Suite

The Pico-8 emulator has a test suite for Pico-8 emulation.

Tests are found in `/tests/[category]/...`. To add test(s), you should add them to a category folder inside `/tests/`, such as `/tests/memory/...`. Within the category folder, you place all the `.lua` files.

## Running tests

Tests are run with the command `run_tests` in the emulator terminal, e.g:
```
> run_tests memory
> run_tests memory -o
> run_tests memory -o -pod
```

With no options, it only prints out to host os terminal.

With `-o`, it opens the results in a .txt.

With `-o -pod`, it opens all results in a .pod.

When there are no arguments, all tests that exist are listed.

## Creating tests

The top of all `.lua` test files should be a comment explaining what it does and the following code snippet:
```lua
expect=expect or function(value,actual,label)
	label=label or "unlabelled"
	actual=actual or "[nil]"
	printh(label.." | "..actual)
end
```

This `expect` function only exists for compatibility with Pico-8, when in the emulator it will be injected into the testing environment.

An example of `expect()` usage is the following:
```lua
expect(0,sget(-1,-1),"sget() not returning default; no pokes")
```
where 0 is the expected output, sget(-1,-1) is the function that should return 0, and the string is the label to use when saying that a test has failed.

At the end of the test, the `stop()` function *must* be called. This can also contain a string (similar to Pico-8 syntax where the string is the reason it stopped) which has a label of the test; rather than being just the filename of the test.

An example test is as follows (for testing pget,mget and sget default values with memory pokes):

```lua
--[[
	Tests for when 0x5f36 is 0x10
	Sets default results for out-of-bounds values of sget/mget/pget
]]

expect=expect or function(value,actual,label)
	label=label or "unlabelled"
	actual=actual or "[nil]"
	printh(label.." | "..actual)
end

function _init()
	expect(0,sget(-1,-1),"sget() not returning default; no pokes")
	expect(0,pget(-1,-1),"pget() not returning default; no pokes")
	expect(0,mget(-1,-1),"mget() not returning default; no pokes")
	poke(0x5f36,0x10)
	expect(0,sget(-1,-1),"mget() not returning default; no pokes")
	expect(0,pget(-1,-1),"pget() not returning default; 0x5f36 poked but 0x5f5b not")
	expect(0,mget(-1,-1),"mget() not returning default; 0x5f36 poked but 0x5f5a not")
	poke(0x5f59,1)
	expect(1,sget(-1,-1),"sget() not returning peek(0x5f59) when oob & 0x5f36 & 0x5f59 poked")
	poke(0x5f5b,2)
	expect(2,pget(-1,-1),"pget() not returning peek(0x5f5b) when oob & 0x5f36 & 0x5f5b poked")
	poke(0x5f5a,3)
	expect(3,mget(-1,-1),"mget() not returning peek(0x5f5a) when oob & 0x5f36 & 0x5f5a poked")
	stop("0x5f36 0x10 pokes for default values with sget/pget/mget")
end
```