unit wasm.test.opcode.f32const;

interface

procedure run;

implementation

uses
    types, wasm.types, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..4] of uint8;
    ctx : PWASMProcessContext;
    f : float;
begin
    test_begin('opcode.f32const');

    { Test: f32.const 3.14 }
    code[0] := $43; { f32.const }
    f := 3.14;
    code[1] := puint8(@f)[0];
    code[2] := puint8(@f)[1];
    code[3] := puint8(@f)[2];
    code[4] := puint8(@f)[3];
    ctx := make_test_context(@code[0], 5);
    wasm.vm.tick(ctx);
    assert_f32('const 3.14', popf32(ctx^.ExecutionState.Operand_Stack), 3.14);

    { Test: f32.const 0.0 }
    f := 0.0;
    code[1] := puint8(@f)[0];
    code[2] := puint8(@f)[1];
    code[3] := puint8(@f)[2];
    code[4] := puint8(@f)[3];
    ctx := make_test_context(@code[0], 5);
    wasm.vm.tick(ctx);
    assert_f32('const 0.0', popf32(ctx^.ExecutionState.Operand_Stack), 0.0);

    { Test: f32.const -1.0 }
    f := -1.0;
    code[1] := puint8(@f)[0];
    code[2] := puint8(@f)[1];
    code[3] := puint8(@f)[2];
    code[4] := puint8(@f)[3];
    ctx := make_test_context(@code[0], 5);
    wasm.vm.tick(ctx);
    assert_f32('const -1.0', popf32(ctx^.ExecutionState.Operand_Stack), -1.0);

    test_end;
end;

end.
