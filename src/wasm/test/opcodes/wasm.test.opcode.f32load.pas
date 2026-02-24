unit wasm.test.opcode.f32load;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

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

    { Non-zero offset }
    code[0] := $2A;
    code[1] := $00;
    code[2] := $0C; { offset = 12 }
    ctx := make_test_context(@code[0], 3);
    f := 1.5;
    wasm.types.heap.write_uint32(12, ctx^.ExecutionState.Memory, TWASMPUInt32(@f)^);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_f32('load with offset=12', popf32(ctx^.ExecutionState.Operand_Stack), 1.5);

    { OOB trap }
    code[0] := $2A;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($10000));
    wasm.vm.tick(ctx);
    assert_true('OOB traps', ctx^.ExecutionState.Running = false);

    test_end;
end;

end.
