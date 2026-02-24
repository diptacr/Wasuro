unit wasm.test.opcode.f32store;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    readBack : TWASMUInt32;
    f : TWASMFloat;
begin
    test_begin('opcode.f32.store');

    code[0] := $38; { f32.store }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { address }
    pushf32(ctx^.ExecutionState.Operand_Stack, 3.14); { value }
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint32(0, ctx^.ExecutionState.Memory, @readBack);
    f := TWASMPFloat(@readBack)^;
    assert_f32('stored 3.14', f, 3.14);

    { Non-zero offset }
    code[0] := $38;
    code[1] := $00;
    code[2] := $08; { offset = 8 }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushf32(ctx^.ExecutionState.Operand_Stack, 2.5);
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint32(8, ctx^.ExecutionState.Memory, @readBack);
    f := TWASMPFloat(@readBack)^;
    assert_f32('store with offset=8', f, 2.5);

    { OOB trap }
    code[0] := $38;
    code[1] := $00;
    code[2] := $00;
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, TWASMInt32($10000));
    pushf32(ctx^.ExecutionState.Operand_Stack, 1.0);
    wasm.vm.tick(ctx);
    assert_true('store OOB traps', ctx^.ExecutionState.Running = false);

    test_end;
end;

end.
