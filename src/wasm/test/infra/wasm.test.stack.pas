unit wasm.test.stack;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.stack, wasm.test.framework;

procedure run;
var
    s : PWASMStack;
    v128 : uint128;
begin
    test_begin('stack');

    { Test: push/pop i32 }
    s := newStack(16);
    pushi32(s, 42);
    assert_i32('pushi32/popi32 basic', popi32(s), 42);

    { Test: push/pop i32 negative }
    pushi32(s, -100);
    assert_i32('pushi32/popi32 negative', popi32(s), -100);

    { Test: push/pop i64 }
    pushi64(s, 1234567890123);
    assert_i64('pushi64/popi64 basic', popi64(s), 1234567890123);

    { Test: push/pop i64 negative }
    pushi64(s, -9876543210);
    assert_i64('pushi64/popi64 negative', popi64(s), -9876543210);

    { Test: push/pop f32 }
    pushf32(s, 3.14);
    assert_f32('pushf32/popf32 basic', popf32(s), 3.14);

    { Test: push/pop f64 }
    pushf64(s, 2.718281828);
    assert_f64('pushf64/popf64 basic', popf64(s), 2.718281828);

    { Test: push/pop func ref }
    pushfunc(s, 7);
    assert_u32('pushfunc/popfunc basic', popfunc(s), 7);

    { Test: push/pop extn ref }
    pushextn(s, 99);
    assert_u32('pushextn/popextn basic', popextn(s), 99);

    { Test: push/pop v128 }
    v128.low := $DEADBEEF;
    v128.high := $CAFEBABE;
    pushv128(s, v128);
    v128 := popv128(s);
    assert_u64('pushv128/popv128 low', v128.low, $DEADBEEF);
    assert_u64('pushv128/popv128 high', v128.high, $CAFEBABE);

    { Test: LIFO order }
    pushi32(s, 1);
    pushi32(s, 2);
    pushi32(s, 3);
    assert_i32('LIFO order 3', popi32(s), 3);
    assert_i32('LIFO order 2', popi32(s), 2);
    assert_i32('LIFO order 1', popi32(s), 1);

    { Test: stack top tracking }
    assert_u32('empty stack top=0', s^.Top, 0);
    pushi32(s, 10);
    assert_u32('one item top=1', s^.Top, 1);
    pushi32(s, 20);
    assert_u32('two items top=2', s^.Top, 2);
    popi32(s);
    assert_u32('after pop top=1', s^.Top, 1);
    popi32(s);
    assert_u32('after pop top=0', s^.Top, 0);

    { Test: stack full flag }
    s := newStack(2);
    assert_bool('new stack not full', s^.Full, false);
    pushi32(s, 1);
    pushi32(s, 2);
    assert_bool('full stack', s^.Full, true);

    test_end;
end;

end.
