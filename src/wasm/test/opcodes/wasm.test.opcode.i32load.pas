unit wasm.test.opcode.i32load;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i32.load');

    code[0] := $28; { i32.load }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint32(0, ctx^.ExecutionState.Memory, $DEADBEEF);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i32('load $DEADBEEF', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($DEADBEEF));

    { Non-zero base address }
    code[0] := $28;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint32(100, ctx^.ExecutionState.Memory, $12345678);
    pushi32(ctx^.ExecutionState.Operand_Stack, 100);
    wasm.vm.tick(ctx);
    assert_i32('load at addr 100', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($12345678));

    { Non-zero offset }
    code[0] := $28;
    code[1] := $00;
    code[2] := $08; { offset = 8 }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint32(8, ctx^.ExecutionState.Memory, $AABBCCDD);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base = 0, effective = 0 + 8 = 8 }
    wasm.vm.tick(ctx);
    assert_i32('load with offset=8', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($AABBCCDD));

    { Base + offset combination }
    code[0] := $28;
    code[1] := $00;
    code[2] := $04; { offset = 4 }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint32(104, ctx^.ExecutionState.Memory, $CAFEBABE);
    pushi32(ctx^.ExecutionState.Operand_Stack, 100); { base = 100, effective = 100 + 4 = 104 }
    wasm.vm.tick(ctx);
    assert_i32('load base+offset', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($CAFEBABE));

    { OOB trap: address beyond memory }
    code[0] := $28;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($10000)); { exactly at page boundary }
    wasm.vm.tick(ctx);
    assert_true('OOB traps', ctx^.ExecutionState.Running = false);

    { Boundary: last valid 4-byte read at $FFFC }
    code[0] := $28;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint32($FFFC, ctx^.ExecutionState.Memory, $11223344);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FFFC));
    wasm.vm.tick(ctx);
    assert_i32('load at boundary', popi32(ctx^.ExecutionState.Operand_Stack), TWASMInt32($11223344));

    { OOB: straddles page boundary at $FFFD (needs 4 bytes, only 3 remain) }
    code[0] := $28;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($FFFD));
    wasm.vm.tick(ctx);
    assert_true('OOB at boundary traps', ctx^.ExecutionState.Running = false);

    test_end;
end;

end.
