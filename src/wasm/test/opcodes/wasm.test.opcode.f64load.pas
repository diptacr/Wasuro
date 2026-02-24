unit wasm.test.opcode.f64load;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    d : TWASMDouble;
begin
    test_begin('opcode.f64.load');

    code[0] := $2B; { f64.load }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    d := 2.718281828;
    wasm.types.heap.write_uint64(0, ctx^.ExecutionState.Memory, TWASMPUInt64(@d)^);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_f64('load 2.718281828', popf64(ctx^.ExecutionState.Operand_Stack), 2.718281828);

    { Non-zero offset }
    code[0] := $2B;
    code[1] := $00;
    code[2] := $10; { offset = 16 }
    ctx := make_test_context(@code[0], 3);
    d := 9.81;
    wasm.types.heap.write_uint64(16, ctx^.ExecutionState.Memory, TWASMPUInt64(@d)^);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_f64('load with offset=16', popf64(ctx^.ExecutionState.Operand_Stack), 9.81);

    { OOB trap }
    code[0] := $2B;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($10000));
    wasm.vm.tick(ctx);
    assert_true('OOB traps', ctx^.ExecutionState.Running = false);

    test_end;
end;

end.
