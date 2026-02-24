unit wasm.test.opcode.i64extendi32u;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..0] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.i64.extend_i32_u');

    code[0] := $AD;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);
    wasm.vm.tick(ctx);
    assert_i64('extend(1)=1', popi64(ctx^.ExecutionState.Operand_Stack), 1);

    code[0] := $AD;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, -1);
    wasm.vm.tick(ctx);
    assert_i64('extend(-1)=4294967295', popi64(ctx^.ExecutionState.Operand_Stack), TWASMInt64(4294967295));

    code[0] := $AD;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i64('extend(0)=0', popi64(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
