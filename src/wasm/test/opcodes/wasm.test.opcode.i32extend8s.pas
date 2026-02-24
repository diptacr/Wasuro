unit wasm.test.opcode.i32extend8s;

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
    test_begin('opcode.i32.extend8_s');

    code[0] := $C0;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, $7F);
    wasm.vm.tick(ctx);
    assert_i32('extend8s($7F)=127', popi32(ctx^.ExecutionState.Operand_Stack), 127);

    code[0] := $C0;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, $80);
    wasm.vm.tick(ctx);
    assert_i32('extend8s($80)=-128', popi32(ctx^.ExecutionState.Operand_Stack), -128);

    code[0] := $C0;
    ctx := make_test_context(@code[0], 1);
    pushi32(ctx^.ExecutionState.Operand_Stack, $FF);
    wasm.vm.tick(ctx);
    assert_i32('extend8s($FF)=-1', popi32(ctx^.ExecutionState.Operand_Stack), -1);

    test_end;
end;

end.
