unit wasm.test.opcode.f32load;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    f : TWASMFloat;
begin
    test_begin('opcode.f32.load');

    code[0] := $2A; { f32.load }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    f := 3.14;
    wasm.types.heap.write_uint32(0, ctx^.ExecutionState.Memory, TWASMPUInt32(@f)^);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_f32('load 3.14', popf32(ctx^.ExecutionState.Operand_Stack), 3.14);

    test_end;
end;

end.
