unit wasm.test.heap;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.heap, wasm.test.framework;

procedure run;
var
    h : PWasmHeap;
    v8 : TWASMUInt8;
    v16 : TWASMUInt16;
    v32 : TWASMUInt32;
    v64 : TWASMUInt64;
    ok : TWASMBoolean;
begin
    test_begin('heap');

    h := new_heap();

    { Test: new heap has 1 page }
    assert_u32('new heap pagecount=1', h^.PageCount, 1);

    { Test: write/read TWASMUInt8 }
    ok := write_uint8(0, h, $AB);
    assert_bool('write_uint8 success', ok, true);
    ok := read_uint8(0, h, @v8);
    assert_bool('read_uint8 success', ok, true);
    assert_u32('read_uint8 value', TWASMUInt32(v8), $AB);

    { Test: write/read TWASMUInt16 }
    ok := write_uint16(4, h, $1234);
    assert_bool('write_uint16 success', ok, true);
    ok := read_uint16(4, h, @v16);
    assert_bool('read_uint16 success', ok, true);
    assert_u32('read_uint16 value', TWASMUInt32(v16), $1234);

    { Test: write/read TWASMUInt32 }
    ok := write_uint32(8, h, $DEADBEEF);
    assert_bool('write_uint32 success', ok, true);
    ok := read_uint32(8, h, @v32);
    assert_bool('read_uint32 success', ok, true);
    assert_u32('read_uint32 value', v32, $DEADBEEF);

    { Test: write/read TWASMUInt64 }
    ok := write_uint64(16, h, TWASMUInt64($CAFEBABE12345678));
    assert_bool('write_uint64 success', ok, true);
    ok := read_uint64(16, h, @v64);
    assert_bool('read_uint64 success', ok, true);
    assert_u64('read_uint64 value', v64, TWASMUInt64($CAFEBABE12345678));

    { Test: out of bounds read fails }
    ok := read_uint8($10000, h, @v8);
    assert_bool('oob read fails', ok, false);

    { Test: out of bounds write fails }
    ok := write_uint8($10000, h, $FF);
    assert_bool('oob write fails', ok, false);

    { Test: expand heap }
    ok := expand_heap(h);
    assert_bool('expand_heap success', ok, true);
    assert_u32('expanded pagecount=2', h^.PageCount, 2);

    { Test: can now access page 2 }
    ok := write_uint32($10000, h, $BAADF00D);
    assert_bool('write page2 success', ok, true);
    ok := read_uint32($10000, h, @v32);
    assert_bool('read page2 success', ok, true);
    assert_u32('read page2 value', v32, $BAADF00D);

    { Test: data persists after expand on page 1 }
    ok := read_uint32(8, h, @v32);
    assert_bool('page1 data persists', ok, true);
    assert_u32('page1 data value', v32, $DEADBEEF);

    { Test: cross-page boundary read }
    ok := write_uint8($FFFE, h, $11);
    ok := write_uint8($FFFF, h, $22);
    ok := write_uint8($10000, h, $33);
    ok := write_uint8($10001, h, $44);
    ok := read_uint32($FFFE, h, @v32);
    assert_bool('cross-page read success', ok, true);
    assert_u32('cross-page read value', v32, $44332211);

    test_end;
end;

end.
