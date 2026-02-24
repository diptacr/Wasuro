unit wasm.test.opcode.i32store;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    readBack : TWASMUInt32;
begin
    test_begin('opcode.i32.store');

    code[0] := $36; { i32.store }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);              { address }
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($DEADBEEF)); { value }
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint32(0, ctx^.ExecutionState.Memory, @readBack);
    assert_u32('stored DEADBEEF', readBack, $DEADBEEF);

    test_end;
end;

end.
