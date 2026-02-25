unit wasm.test.leb128;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.leb128, wasm.test.framework;

procedure run;
var
    buf : array[0..9] of TWASMUInt8;
    buf_end : TWASMPUInt8;
    res32 : TWASMUInt32;
    res64 : TWASMUInt64;
    bytesRead : TWASMUInt8;
begin
    test_begin('wasm.types.leb128');
    buf_end := @buf[10];

    { Test: single byte, value 0 }
    buf[0] := $00;
    bytesRead := read_leb128_to_uint32(@buf[0], buf_end, @res32);
    assert_u32('u32 value=0', res32, 0);
    assert_u32('u32 value=0 bytes=1', TWASMUInt32(bytesRead), 1);

    { Test: single byte, value 42 }
    buf[0] := $2A;
    bytesRead := read_leb128_to_uint32(@buf[0], buf_end, @res32);
    assert_u32('u32 value=42', res32, 42);
    assert_u32('u32 value=42 bytes=1', TWASMUInt32(bytesRead), 1);

    { Test: single byte, value 127 }
    buf[0] := $7F;
    bytesRead := read_leb128_to_uint32(@buf[0], buf_end, @res32);
    assert_u32('u32 value=127', res32, 127);

    { Test: two bytes, value 128 }
    buf[0] := $80;
    buf[1] := $01;
    bytesRead := read_leb128_to_uint32(@buf[0], buf_end, @res32);
    assert_u32('u32 value=128', res32, 128);
    assert_u32('u32 value=128 bytes=2', TWASMUInt32(bytesRead), 2);

    { Test: two bytes, value 255 }
    buf[0] := $FF;
    buf[1] := $01;
    bytesRead := read_leb128_to_uint32(@buf[0], buf_end, @res32);
    assert_u32('u32 value=255', res32, 255);

    { Test: two bytes, value 256 }
    buf[0] := $80;
    buf[1] := $02;
    bytesRead := read_leb128_to_uint32(@buf[0], buf_end, @res32);
    assert_u32('u32 value=256', res32, 256);

    { Test: larger value 624485 = 0xE5 0x8E 0x26 }
    buf[0] := $E5;
    buf[1] := $8E;
    buf[2] := $26;
    bytesRead := read_leb128_to_uint32(@buf[0], buf_end, @res32);
    assert_u32('u32 value=624485', res32, 624485);
    assert_u32('u32 value=624485 bytes=3', TWASMUInt32(bytesRead), 3);

    { Test: TWASMUInt64 single byte }
    buf[0] := $2A;
    bytesRead := read_leb128_to_uint64(@buf[0], buf_end, @res64);
    assert_u64('u64 value=42', res64, 42);
    assert_u32('u64 value=42 bytes=1', TWASMUInt32(bytesRead), 1);

    { Test: TWASMUInt64 two bytes }
    buf[0] := $80;
    buf[1] := $01;
    bytesRead := read_leb128_to_uint64(@buf[0], buf_end, @res64);
    assert_u64('u64 value=128', res64, 128);

    { Test: TWASMUInt64 multi-byte }
    buf[0] := $E5;
    buf[1] := $8E;
    buf[2] := $26;
    bytesRead := read_leb128_to_uint64(@buf[0], buf_end, @res64);
    assert_u64('u64 value=624485', res64, 624485);

    test_end;
end;

end.
