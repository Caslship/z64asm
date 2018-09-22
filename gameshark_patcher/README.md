# Gameshark Patcher for OoT: Debug

As the title implies, this is a very quick and dirty hack to patch most gameshark codes to the Legend of Zelda: Ocarina of Time Debugger's ROM. There are some limitations that I will get into later, but most can easily be circumvented with a little know-how.

## Credits
- spinout - z64hook makes patching code to ROM pretty straightforward; this hack relies on it

## How it works

In a nutshell, this hack works by patching a hand-written gameshark code interpreter to the ROM. The interpreter is loaded into RAM by z64hook and executed continuously. The interpreter reads gameshark codes from a fixed location (directly after the end of the interpreter code). I would recommend reading raw_gsci.S if you're curious about how it's written - there's plenty of comments.

## Usage

While I wouldn't really recommend this method for anybody with a little bit of ASM knowledge (this hack is terribly inefficient), it was made with the intention of being used by people without such experience.

### Apply the z64hook patch

Not much to really say about this hack. Use something like PPF-O-Matic to apply z64hook-0.0.2.ppf to the ROM.

### Fix the ROM CRC

While not really necessary if you're sticking to emulators like nemu, I would recommend updating the ROM's CRC with a tool like rn64crc. The z64hook patch applies modifications to the ROM's checksum area so it's no longer valid. You will need to fix this if you want to run on PJ64 1.6.

### Inject the Gameshark Code Interpreter

Go ahead and take our precompile binary, gsci.bin, and write it at 0x03600000 in the ROM. We use this particular address because that's the location that z64hook will load into RAM and execute.

### Inject your gameshark codes

Take any gameshark codes you want and write them at 0x036000FC in the ROM. You'll notice that this is directly after the interpreter binary. This is where the interpreter will read codes from.

For an example, say we wanted to patch the "Replace Roll with Jump" GS code. We'd take this code:
```
D1224780 3FA0
81224610 40FF
```
And write this at 0x036000FC:
```
D1 22 47 80 3F A0 81 22 46 10 40 FF
```

## Limitations

Because we rely on z64hook to patch our gameshark code interpreter binary, we are are given a couple of restrictions on what we can do:
- z64hook expects our interpreter binary to be 0x03600000 in ROM -  a lot of modders tend to use this space for custom or relocated content so be wary of overwriting the interpreter
- If you have any custom codes that overwrite areas at 0x80600000 then you'll end up overwriting parts of the interpreter - this location in RAM is a popular spot for lot of assembly hacks
- z64hook only loads 0x1000 bytes from ROM to RAM. Along with the 0xFC bytes taken up by the interpreter, you are limited to this amount of space when patching gameshark codes.

A lot of these limitations can be overcome by removing the dependency on z64hook and using our own loader. If you want to do this, then feel free to reach out to me.