unit wasm.test.opcode.memoryfill;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context,
    wasm.types.stack, wasm.types.heap, wasm.vm, wasm.test.framework;

procedure run;
var
    { FC $0B, mem_idx=0 }
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    b : TWASMUInt8;
begin
    test_begin('opcode.memory.fill');

    code[0] := $FC; code[1] := $0B; code[2] := $00;

    { Fill 4 bytes with $42 at offset 5 }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 5);    { d = 5 }
    pushi32(ctx^.ExecutionState.Operand_Stack, $42);  { val = 0x42 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 4);    { n = 4 }
    wasm.vm.tick(ctx);
    read_uint8(5, ctx^.ExecutionState.Memory, @b);
    assert_u32('fill[5]=$42', b, $42);
    read_uint8(6, ctx^.ExecutionState.Memory, @b);
    assert_u32('fill[6]=$42', b, $42);
    read_uint8(7, ctx^.ExecutionState.Memory, @b);
    assert_u32('fill[7]=$42', b, $42);
    read_uint8(8, ctx^.ExecutionState.Memory, @b);
    assert_u32('fill[8]=$42', b, $42);

    { Only low byte of val is used }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);      { d = 0 }
    pushi32(ctx^.ExecutionState.Operand_Stack, $1FF);   { val = 0x1FF, low byte = $FF }
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);      { n = 1 }
    wasm.vm.tick(ctx);
    read_uint8(0, ctx^.ExecutionState.Memory, @b);
    assert_u32('low_byte=$FF', b, $FF);

    { n=0 is a no-op }
    ctx := make_test_context(@code[0], 3);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, $99);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_true('n=0 still running', ctx^.ExecutionState.Running);

    test_end;
end;

end.
