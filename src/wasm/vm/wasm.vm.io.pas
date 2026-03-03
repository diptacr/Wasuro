unit wasm.vm.io;
{ Hookable I/O abstraction for the WASM VM.
  All output from the VM funnels through a single writechar hook
  that the OS/emulator layer provides.  On bare-metal this would
  point at a VGA/serial driver; under the emulator it wraps RTL Write.

  High-level helpers (writestring, writeint, etc.) are built entirely
  on top of writechar — no RTL, no sysutils, ring-0 safe. }

interface

uses
    wasm.types.builtin;

type
    TIOWriteCharHook = procedure(ch : TWASMChar);

{ Initialisation / hook registration }
procedure io_init;
procedure io_set_writechar(hook : TIOWriteCharHook);
function  io_get_writechar : TIOWriteCharHook;

{ Fundamental output — calls the registered hook }
procedure writechar(ch : TWASMChar);

{ String output }
procedure writestring(str : TWASMPChar);
procedure writestringln(str : TWASMPChar);

{ Numeric output (bare-metal safe, no Str/IntToStr) }
procedure writeintWND(i : TWASMInt64; WND : TWASMUInt32);
procedure writeintlnWND(i : TWASMInt64; WND : TWASMUInt32);

{ Hex pair output (e.g. $AB -> '0xAB') }
procedure writehexpair(b : TWASMUInt8);

{ Convenience wrappers matching legacy names }
procedure writecharWND(character : TWASMChar; WND : TWASMUInt32);
procedure writecharlnWND(character : TWASMChar; WND : TWASMUInt32);
procedure writestringWND(str : TWASMPChar; WND : TWASMUInt32);
procedure writestringlnWND(str : TWASMPChar; WND : TWASMUInt32);
procedure Output(identifier : TWASMPChar; str : TWASMPChar);
procedure Outputln(identifier : TWASMPChar; str : TWASMPChar);

implementation

var
    WriteCharHook : TIOWriteCharHook;

{ ---- Initialisation -------------------------------------------------- }

procedure io_init;
begin
    WriteCharHook := nil;
end;

procedure io_set_writechar(hook : TIOWriteCharHook);
begin
    WriteCharHook := hook;
end;

function io_get_writechar : TIOWriteCharHook;
begin
    io_get_writechar := WriteCharHook;
end;

{ ---- Fundamental output ---------------------------------------------- }

procedure writechar(ch : TWASMChar);
begin
    if WriteCharHook <> nil then
        WriteCharHook(ch);
end;

{ ---- String output --------------------------------------------------- }

procedure writestring(str : TWASMPChar);
var
    i : TWASMUInt32;
begin
    if str = nil then exit;
    i := 0;
    while str[i] <> #0 do begin
        writechar(str[i]);
        Inc(i);
    end;
end;

procedure writestringln(str : TWASMPChar);
begin
    writestring(str);
    writechar(#10);
end;

{ ---- Numeric output -------------------------------------------------- }

procedure writeintWND(i : TWASMInt64; WND : TWASMUInt32);
var
    buf   : array[0..20] of TWASMChar; { enough for -2^63 }
    pos   : TWASMUInt32;
    neg   : TWASMBoolean;
    digit : TWASMUInt8;
    u     : TWASMUInt64;
    j     : TWASMUInt32;
begin
    if i = 0 then begin
        writechar('0');
        exit;
    end;

    neg := (i < 0);
    if neg then
        u := TWASMUInt64(-i)
    else
        u := TWASMUInt64(i);

    pos := 0;
    while u > 0 do begin
        digit := TWASMUInt8(u mod 10);
        buf[pos] := TWASMChar(ord('0') + digit);
        Inc(pos);
        u := u div 10;
    end;

    if neg then
        writechar('-');

    { buf contains digits in reverse order }
    for j := pos downto 1 do
        writechar(buf[j - 1]);
end;

procedure writeintlnWND(i : TWASMInt64; WND : TWASMUInt32);
begin
    writeintWND(i, WND);
    writechar(#10);
end;

{ ---- Hex pair output ------------------------------------------------- }

procedure writehexpair(b : TWASMUInt8);
const
    HexDigits : array[0..15] of TWASMChar = ('0','1','2','3','4','5','6','7',
                                              '8','9','A','B','C','D','E','F');
begin
    writestring('0x');
    writechar(HexDigits[b shr 4]);
    writechar(HexDigits[b and $0F]);
end;

{ ---- Convenience wrappers -------------------------------------------- }

procedure writecharWND(character : TWASMChar; WND : TWASMUInt32);
begin
    wasm.vm.io.writechar(character);
end;

procedure writecharlnWND(character : TWASMChar; WND : TWASMUInt32);
begin
    writechar(character);
    writechar(#10);
end;

procedure writestringWND(str : TWASMPChar; WND : TWASMUInt32);
begin
    writestring(str);
end;

procedure writestringlnWND(str : TWASMPChar; WND : TWASMUInt32);
begin
    writestringln(str);
end;

procedure Output(identifier : TWASMPChar; str : TWASMPChar);
begin
    writechar('[');
    writestring(identifier);
    writestring('] ');
    writestring(str);
end;

procedure Outputln(identifier : TWASMPChar; str : TWASMPChar);
begin
    Output(identifier, str);
    writechar(#10);
end;

end.
