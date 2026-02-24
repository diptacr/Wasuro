unit wasm.test.opcode.i64store16;

interface

procedure run;

implementation

uses
    types, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of uint8;
    ctx : PWASMProcessContext;
    readBack : uint16;
begin
    test_begin('opcode.i64.store16');

    code[0] := $3D; { i64.store16 }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);            { address }
    pushi64(ctx^.ExecutionState.Operand_Stack, int64($AABBCCDD)); { value }
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint16(0, ctx^.ExecutionState.Memory, @readBack);
    assert_u32('stored low 16 bits $CCDD', uint32(readBack), $CCDD);

    test_end;
end;

end.
