unit wasm.test.opcode.f64store;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types, wasm.types.heap, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    readBack : TWASMUInt64;
    d : TWASMDouble;
begin
    test_begin('opcode.f64.store');

    code[0] := $39; { f64.store }
    code[1] := $00; { align }
    code[2] := $00; { offset }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);          { address }
    pushf64(ctx^.ExecutionState.Operand_Stack, 2.718281828); { value }
    wasm.vm.tick(ctx);
    wasm.types.heap.read_uint64(0, ctx^.ExecutionState.Memory, @readBack);
    d := TWASMPDouble(@readBack)^;
    assert_f64('stored 2.718281828', d, 2.718281828);

    test_end;
end;

end.
