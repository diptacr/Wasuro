unit wasm.test.opcode.f32store;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

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

    test_end;
end;

end.
