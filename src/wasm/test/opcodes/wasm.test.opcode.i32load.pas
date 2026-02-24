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

    test_end;
end;

end.
