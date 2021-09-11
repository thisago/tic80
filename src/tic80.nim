#[
  Created at: 09/10/2021 18:18:42 Friday
  Modified at: 09/10/2021 06:54:22 PM Friday

        Copyright (C) 2021 Thiago Navarro
  See file "license" for details about copyright
]#

import sugar

when not defined(js) and not defined(nimsuggest) and not defined(nimdoc):
  {.fatal: "At now, this module just works with Javascript backend.".}

proc ticHeader*(title, author, desc: string; saveId = ""): string =
  ## Generates the game header
  var saveIdStr = ""
  if saveId.len > 0:
    saveIdStr = "// saveid: " & saveId
  return """// title: `title`
// author: `author`
// desc: `desc``saveIdStr`
// script: js
"""

template TIC*(body: untyped): untyped =
  ## Game loop
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/TIC
  proc TIC() {.exportc.} =
    body

type
  DisplaySize* = object
    width: range[0..239]
    height: range[0..135]

template SCN*(scanline: untyped; body: untyped): untyped =
  ## Code between rendering of each scan line
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/SCN
  proc SCN(scanline: DisplaySize.height) {.exportc.} =
    body

template OVR*(scanline: untyped; body: untyped): untyped =
  ## Code between rendering of each scan line
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/OVR
  proc OVR(scanline: Scanline) {.exportc.} =
    body

type
  Button* = range[0..31]
    ## All buttons
  Buttons* = enum
    ## Buttons by name
    ##
    ## Refence https://github.com/nesbox/TIC-80/wiki/key-map
    BtnUp, BtnDown, BtnLeft, BtnRight
    BtnA, BtnB, BtnX, BtnY

  Color* = range[-1..15]
    ## All available colors
    ## -1 is for no color
  DefaultPallete* {.pure.} = enum
    ## Colors by name
    ##
    ## Reference https://github.com/nesbox/TIC-80/wiki/palette
    black = Color(0), purple, red, orange, yellow,
        lightGreen, green, darkGreen, darkBlue, blue,
        lightBlue, cyan, white, lightGrey, grey, darkGrey

  SpriteWithFlag* = range[0..511]
    ## All the sprites using 4 BPP
  SpriteFlag* = range[0..7]
    ## All sprite flags

  Key* = range[1..65]
    ## All keys of keyboard
  Keys* {.pure.} = enum
    ## All keyboard keys by name
    a = 1, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x,
        y, z,
    zero, one, two, three, four, five, six, seven, eight, nine,
    minus, equals, leftbracket, rightbracket, backslash, semicolon, apostrophe, grave,
    comma, period, slash, space, tab, `return`, backspace, delete, insert,
    pageup, pagedown, home, `end`, up, down, left, right,
    capslock, ctrl, shift, alt

  MapTile* = byte
    ## The id of tile in map

  Sprite* = range[0..2047]
    ## All possible sprites (even with 1 BPP)

  MusicTrack* = range[0..7]
    ## The music track
  MusicFrame* = range[-1..15]
    ## The frame of music track
  MusicRow* = range[-1..63]
    ## The row of frame of the music track
  MusicTempo* = range[-1..90]
    ## Music tempo
  MusicSpeed* = range[-1..90]
    ## Music speed

  Byte4* = range[0..15]
    ## 4 bits value

  AudioSfx* = range[-1..63]
    ## All possible sfx
    ##
    ## The -1 is for stop playing in `sfx`
  AudioNote* = range[-1..95]
    ## All possible notes
    ##
    ## The -1 is for stop playing in `sfx`
  AudioChannel* = range[0..3]
    ## The channel of sfx
  AudioVolume* = range[0..15]
    ## The volume of sfx
  AudioSpeed* = range[-4..3]
    ## The speed of sfx

  TransformFlip* = range[0..3]
    ## 0 = No Flip
    ## 1 = Flip horizontally
    ## 2 = Flip vertically
    ## 3 = Flip both vertically and horizontally
  TransformRotate* = range[0..3]
    ## When you rotate the sprite, it's rotated clockwise in 90° steps:
    ##
    ## 0 = No rotation
    ## 1 = 90° rotation
    ## 2 = 180° rotation
    ## 3 = 270° rotation

  MemoryBank* = range[0..7]
    ## All memory banks available on PRO version


const noColor*: Color = -1

converter toColor(x: DefaultPallete): Color =
  Color ord x

{.push importc.}
proc btn*(id: Buttons): bool
  ## Returns true if button is pressed in the current frame
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/btn
proc btnp*(id: Buttons; hold, period: int): bool
  ## returns true if pressed in the current but wasn't pressed in the previous frame
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/btnp
proc clip*(x, y, width, height: int)
  ## This function limits drawing to a clipping region or 'viewport' defined by x,y, width, and height.
  ## Any pixels falling outside of this area will not be drawn.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/clip
proc clip*()
  ## Calling clip() with no parameters will reset the drawing area to the entire screen.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/clip
proc cls*(color: Color = 0)
  ## Calling clip() with no parameters will reset the drawing area to the entire screen.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/cls
proc circ*(x, y, radius: int; color: Color)
  ## This function draws a filled circle of the desired radius and color with its center at x, y.
  ## It uses the Bresenham algorithm.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/circ
proc circb*(x, y, radius: int; color: Color)
  ## Draws the circumference of a circle with its center at x, y using the radius and color requested.
  ## It uses the Bresenham algorithm.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/circb
proc circb*(x, y, radiusH, radiusW: int; color: Color)
  ## This function draws a filled ellipse of the desired radiuses a b and color with its center at x, y.
  ## It uses the Bresenham algorithm.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/elli
proc exit*()
  ## This function causes program execution to be interrupted after the current TIC function ends.
  ## All code in the TIC function for the current frame will be executed - including any code that follows exit().
  ## See the example below for a demo of this behavior.
  ##
  ## Once execution is interrupted you are returned to the console.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/exit
proc fget*(spriteId: SpriteWithFlag; flag: SpriteFlag): bool
  ## Returns true if the specified flag of the sprite is set.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/fget
proc fset*(spriteId: SpriteWithFlag; flag: SpriteFlag; state: bool)
  ## Each sprite has eight flags which can be used to store information or signal different conditions.
  ## For example, flag 0 might be used to indicate that the sprite is invisible, flag 6 might indicate that the sprite should be draw scaled etc.
  ##
  ## To check these flags, see `fget`.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/fset
proc font*(text: cstring; x, y: int; transparentColor: Color; charWidth,
           charHeight: int; fixed = false; scale = 1)
  ## This function will draw text to the screen using the foreground spritesheet as the font.
  ## Sprite #256 is used for ASCII code 0, #257 for code 1 and so on.
  ## The character 'A' has the ASCII code 65 so will be drawn using the sprite with sprite #321 (256+65).
  ## See the example below or check out the In-Browser Demo (http://tic.computer/play?cart=20)
  ##
  ## To simply print text to the screen using the system font, please see `print`
  ##
  ## To print to the console, please see `trace`
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/font
proc key*(code: Key)
  ## The function returns true if the key denoted by keycode is pressed.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/key
proc keyp*(code: Key; hold, pediod: int)
  ## This function returns true if the given key is pressed but wasn't pressed in the previous frame.
  ## Refer to btnp for an explanation of the optional hold and period parameters
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/key
proc line*(x0, y0, x1, y1: int; color: Color)
  ## Draws a straight line from point (x0,y0) to point (x1,y1) in the specified color.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/line
proc map*(x, y: int; w = 30; h = 17; sx = 0; sy = 0; colorkey: Color = noColor;
          scale = 1; remap = (tileId, x, y: int64) => [tileId, 0, 0])
  ## The map consists of cells of 8x8 pixels, each of which can be filled with a tile (sprite) using the map editor.
  ## The map can be up to 240 cells wide by 136 deep.
  ## This function will draw the desired area of the map to a specified screen position.
  ## For example, map(5,5,12,10,0,0) will draw a 12x10 section of the map, starting from map co-ordinates (5,5) to screen position (0,0).
  ## Calling map() without parameters will draw 30x17 tiles to screen position (0,0).
  ##
  ## The map function’s last parameter is a powerful callback function​ for changing how map cells are drawn when map() is called.
  ## It can be used to rotate, flip and replace sprites while the game is running.
  ## Unlike mset, which saves changes to the map, this special function can be used to create animated tiles or replace them completely.
  ## Some examples include changing sprites to open doorways, hiding sprites used to spawn objects in your game and even to emit the objects themselves.
  ##
  ## The tilemap is laid out sequentially in RAM - writing 1 to 0x08000 will cause tile(sprite) #1 to appear at top left when map() is called.
  ## To set the tile immediately below this we need to write to 0x08000 + 240, ie 0x080F0
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/map
proc memcpy*(toAddr, fromAddr, length: int)
  ## This function copies a continuous block of RAM from one address to another. Addresses are specified are in hexadecimal format, values are decimal.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/memcpy
proc memset*(memAddr: int; value: byte; length: int)
  ## This function sets a continuous block of RAM to the same value. The address is specified in hexadecimal format, the value in decimal.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/memset
proc mget*(x, y: int): MapTile
  ## This function returns the tile at the specified map coordinates, the top left cell of the map being (0, 0).
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/mget
proc mset*(x, y: int; tile: MapTile)
  ## This function will change the tile at the specified MAP coordinates. By default, changes made are only kept while the current game is running. To make permanent changes to the map (persisting them back to the cartridge), see sync.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/mset
proc mouse*(): array[7, int]
  ## This function returns the mouse coordinates and a boolean value for the state of each mouse button, with true indicating that a button is pressed.
  ##
  ## Note: The values of index: 2, 3 and 4 are boolean
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/mouse
proc music*(track: MusicTrack; frame: MusicFrame = -1; row: MusicRow = -1;
            loop = true; sustain = false; tempo: MusicTempo = -1;
            speed: MusicSpeed = -1)
  ## This function starts playing a track created in the Music Editor (https://github.com/nesbox/TIC-80/wiki#music-editor).
  ##
  ## The music function needs to be called outside of the tic() function.
  ## If you would like to call the music function inside of the tic function you can try the following.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/music
proc music*()
  ## Stops the music
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/music
proc peek*(ramAddr: int): byte
  ## This function allows you to read from TIC's RAM. It can be used to access resources created with the integrated tools, such as the sprite, map and sound editors, as well as cartridge data. The address is specified in hexadecimal format.
  ##
  ## To write to a memory address, use poke.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/peek
proc peek4*(ramAddr4: int): Byte4
  ## This function enables you to read values from TIC's RAM. The address should be specified in hexadecimal format.
  ##
  ## See also: poke4
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/peek4
proc pix*(x, y: int; color: Color)
  ## This function can read or write individual pixel color values.
  ## When called with color, the pixel at the specified coordinates is set to that color.
  ## When called with only x and y values, the color of the pixel at the specified position is returned.
  ##
  ## Writing
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/pix
proc pix*(x, y: int): Color
  ## This function can read or write individual pixel color values.
  ## When called with color, the pixel at the specified coordinates is set to that color.
  ## When called with only x and y values, the color of the pixel at the specified position is returned.
  ##
  ## Reading
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/pix
proc pmem*(index: byte; value: uint32)
  ## This function allows you to save and retrieve data in one of the 256 individual 32-bit slots available in the cartridge's persistent memory.
  ## This is useful for saving high-scores, level advancement or achievements.
  ## Data is stored as unsigned 32-bit integers (from 0 to 4294967295).
  ##
  ## Tips:
  ##   - pmem depends on the cartridge hash (md5), so don't change your lua script if you want to keep the data.
  ##   - Use saveid: with a personalized string in the header metadata to override the default MD5 calculation. This allows the user to update a cart without losing their saved data.
  ##
  ## Saving
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/pmem
proc pmem*(index: byte): uint32
  ## This function allows you to save and retrieve data in one of the 256 individual 32-bit slots available in the cartridge's persistent memory.
  ## This is useful for saving high-scores, level advancement or achievements.
  ## Data is stored as unsigned 32-bit integers (from 0 to 4294967295).
  ##
  ## Tips:
  ##   -pmem depends on the cartridge hash (md5), so don't change your lua script if you want to keep the data.
  ##   -Use saveid: with a personalized string in the header metadata to override the default MD5 calculation. This allows the user to update a cart without losing their saved data.
  ##
  ## Reading
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/pmem
proc poke*(ramAddr: int; val: byte)
  ## This function allows you to write a single byte to any address in TIC's RAM.
  ## The address should be specified in hexadecimal format, the value in decimal.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/poke
proc poke4*(ramAddr: int; val: Byte4)
  ## This function allows you to write a single byte to any address in TIC's RAM.
  ## The address should be specified in hexadecimal format, the value in decimal.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/poke
proc print*(text: cstring; x = 0; y = 0; color: Color = DefaultPallete.white;
            fixed = false; scale = 1; smallfont = false)
  ## This will simply print text to the screen using the font defined in config.
  ## When set to true, the fixed width option ensures that each character will be printed in a 'box' of the same size, so the character 'i' will occupy the same width as the character 'w' for example. When fixed width is false, there will be a single space between each character.
  ## Refer to the example for an illustration.
  ##
  ## To use a custom rastered font, check out `font`.
  ##
  ## To print to the console, check out `trace`.
  ##
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/print
proc rect*(x, y, w, h: int; color: Color)
  ## This function draws a filled rectangle of the desired size and color at the specified position.
  ## If you only need to draw the border or outline of a rectangle (ie not filled) see rectb
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/rect
proc rectb*(x, y, w, h: int; color: Color)
  ## This function draws a one pixel thick rectangle border at the position requested.
  ## If you need to fill the rectangle with a color, see `rect` instead.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/rectb
proc reset*()
  ## Resets and immediately restarts the cartridge.
  ##
  ## To simply return to the console, please use `exit`.
  ##
  ## This API was added in version 0.60.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/reset
proc sfx*(id: AudioSfx; note: AudioNote = -1; duration = -1;
    channel: AudioChannel = 0; volume: AudioVolume = 15; speed: AudioSpeed = 0)
  ## This function will play the sound with id created in the sfx editor. Calling the function with an id of -1 will stop playing the channel.
  ##
  ## The note can be supplied as an integer between 0 and 95 (representing 8 octaves of 12 notes each) or as a string giving the note name and octave. For example, a note value of '14' will play the note 'D' in the second octave. The same note could be specified by the string 'D-2'.
  ## Note names consist of two characters, the note itself (in upper case) followed by '-' to represent the natural note or '#' to represent a sharp.
  ## There is no option to indicate flat values.
  ## The available note names are therefore: C-, C#, D-, D#, E-, F-, F#, G-, G#, A-, A#, B-.
  ## The octave is specified using a single digit in the range 0 to 8.
  ##
  ## The duration specifies how many ticks to play the sound for; since TIC-80 runs at 60 frames per second, a value of 30 represents half a second.
  ## A value of -1 will play the sound continuously.
  ##
  ## The channel parameter indicates which of the four channels to use.
  ## Allowed values are 0 to 3.
  ##
  ## Volume can be between 0 and 15.
  ##
  ## Speed in the range -4 to 3 can be specified and means how many 'ticks+1' to play each step, so speed==0 means 1 tick per step.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/sfx
proc spr*(id: Sprite; x, y: int; transparentColor: Color = noColor; scale = 1;
          flip: TransformFlip = 0; rotate: TransformRotate = 0; w = 1; h = 1)
  ## Draws the sprite number index at the x and y coordinate.
  ##
  ## You can specify a colorkey in the palette which will be used as the transparent color or use a value of -1 for an opaque sprite.
  ##
  ## The sprite can be scaled up by a desired factor.
  ## For example, a scale factor of 2 means an 8x8 pixel sprite is drawn to a 16x16 area of the screen.
  ##
  ## You can flip the sprite where:
  ##
  ## - 0 = No Flip
  ## - 1 = Flip horizontally
  ## - 2 = Flip vertically
  ## - 3 = Flip both vertically and horizontally
  ## When you rotate the sprite, it's rotated clockwise in 90° steps:
  ##
  ## - 0 = No rotation
  ## - 1 = 90° rotation
  ## - 2 = 180° rotation
  ## - 3 = 270° rotation
  ## You can draw a composite sprite (consisting of a rectangular region of sprites from the sprite sheet) by specifying the w and h parameters (which default to 1).
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/spr
proc sync*(mask = 0; bank: MemoryBank = 0; toCart = false)
  ## The PRO version of TIC-80 contains 8 memory banks.
  ## To switch between these banks, sync can be used to either load contents from a memory bank to runtime, or save contents from the active runtime to a bank.
  ## The function can only be called once per frame.
  ##
  ## - tiles   = 1<<0 -- 1
  ## - sprites = 1<<1 -- 2
  ## - map     = 1<<2 -- 4
  ## - sfx     = 1<<3 -- 8
  ## - music   = 1<<4 -- 16
  ## - palette = 1<<5 -- 32
  ## - flags   = 1<<6 -- 64
  ## screen  = 1<<7 -- 128 (as of 0.90)
  ##
  ## Use sync() to save data you modify during runtime and would like to persist, or to restore runtime data from the cartridge.
  ## For example, if you have manipulated the runtime memory (e.g. by using mset), you can reset the active state by calling sync(0,0,false).
  ## This resets the whole of runtime memory to the contents of bank 0.
  ##
  ## Note that sync is never used to load code from banks; this is done automatically.
  ## All data is restored from cartridge on every startup.
  ##
  ## Note: In older versions of TIC-80, calling sync was not required to save runtime map and sprite data.
  ## Sync should be called any time changes to the sprites and map are made during runtime if you'd like the changes to be applied.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/sync
proc time*(): uint64
  ## This function returns the number of milliseconds elapsed since the cartridge began execution. Useful for keeping track of time, animating items and triggering events.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/time
proc tstamp*(): uint64
  ## This function returns the number of seconds elapsed since January 1st, 1970. This can be quite useful for creating persistent games which evolve over time between plays.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/tstamp
proc trace*(message: cstring; color: Color = DefaultPallete.black)
  ## This is a service function, useful for debugging your code. It prints the message parameter to the console in the (optional) color specified.
  ##
  ## Tips:
  ##   - The Lua concatenation operator is .. (two periods)
  ##   - Use the console cls command to clear the output from trace
  ##
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/trace
proc tri*(x1, y1, x2, y2, x3, y3: int; color: Color)
  ## This function draws a triangle filled with color, using the supplied vertices.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/tri
proc trib*(x1, y1, x2, y2, x3, y3: int; color: Color)
  ## This function draws a triangle border with color, using the supplied vertices.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/trib
proc textri*(x1, y1, x2, y2, x3, y3, u1, v1, u2, v2, u3, v3: int;
             use_map = false; trans: seq[Color] = @[])
  ## This function draws a triangle border with color, using the supplied vertices.
  ##
  ## Reference https://github.com/nesbox/TIC-80/wiki/trib
{.pop.}
