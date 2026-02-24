unit wasm.test.opcode.i64store32;

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
    test_begin('opcode.i64.store32');

    code[0] := $3E; { i64.store32 }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);                        { address }
    pushi64(ctx^.ExecutionState.Operand_Stack, TWASMInt64($AABBCCDD11223344)); { value }
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint32(0, ctx^.ExecutionState.Memory, @readBack);
    assert_u32('stored low 32 bits $11223344', readBack, $11223344);

    test_end;
end;

end.
