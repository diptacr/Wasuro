unit wasm.test.opcode.f64load;

interface

procedure run;

implementation

uses
    types, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of uint8;
    ctx : PWASMProcessContext;
    d : double;
begin
    test_begin('opcode.f64.load');

    code[0] := $2B; { f64.load }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    d := 2.718281828;
    wasm.types.heap.write_uint64(0, ctx^.ExecutionState.Memory, puint64(@d)^);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0); { base address }
    wasm.vm.tick(ctx);
    assert_f64('load 2.718281828', popf64(ctx^.ExecutionState.Operand_Stack), 2.718281828);

    test_end;
end;

end.
