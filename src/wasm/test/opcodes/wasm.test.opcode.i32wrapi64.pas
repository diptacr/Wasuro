unit wasm.test.opcode.i32wrapi64;

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
    test_begin('opcode.i32.wrap_i64');

    code[0] := $A7;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 100);
    wasm.vm.tick(ctx);
    assert_i32('wrap(100)=100', popi32(ctx^.ExecutionState.Operand_Stack), 100);

    code[0] := $A7;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, $100000042);
    wasm.vm.tick(ctx);
    assert_i32('wrap($100000042)=66', popi32(ctx^.ExecutionState.Operand_Stack), 66);

    code[0] := $A7;
    ctx := make_test_context(@code[0], 1);
    pushi64(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_i32('wrap(0)=0', popi32(ctx^.ExecutionState.Operand_Stack), 0);

    test_end;
end;

end.
