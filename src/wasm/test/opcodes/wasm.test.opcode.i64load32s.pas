unit wasm.test.opcode.i64load32s;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i64.load32_s');

    { Test: $FFFFFFFF sign-extends to -1 }
    code[0] := $34; { i64.load32_s }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint32(0, ctx^.ExecutionState.Memory, $FFFFFFFF);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i64('load32_s $FFFFFFFF = -1', popi64(ctx^.ExecutionState.Operand_Stack), -1);

    { Test: $7FFFFFFF sign-extends to 2147483647 }
    ctx := make_test_context(@code[0], 3);
    wasm.types.heap.write_uint32(0, ctx^.ExecutionState.Memory, $7FFFFFFF);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_i64('load32_s $7FFFFFFF = 2147483647', popi64(ctx^.ExecutionState.Operand_Stack), 2147483647);

    test_end;
end;

end.
