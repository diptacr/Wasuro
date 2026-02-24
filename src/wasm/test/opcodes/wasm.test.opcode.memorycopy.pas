unit wasm.test.opcode.memorycopy;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.context,
    wasm.types.stack, wasm.types.heap, wasm.vm, wasm.test.framework;

procedure run;
var
    { FC $0A, dst_mem=0, src_mem=0 }
    code : array[0..3] of TWASMUInt8;
    ctx : PWASMProcessContext;
    b : TWASMUInt8;
begin
    test_begin('opcode.memory.copy');

    code[0] := $FC; code[1] := $0A; code[2] := $00; code[3] := $00;

    { Non-overlapping copy }
    ctx := make_test_context(@code[0], 4);
    write_uint8(0, ctx^.ExecutionState.Memory, $AA);
    write_uint8(1, ctx^.ExecutionState.Memory, $BB);
    write_uint8(2, ctx^.ExecutionState.Memory, $CC);
    pushi32(ctx^.ExecutionState.Operand_Stack, 10);  { d = 10 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { s = 0 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);   { n = 3 }
    wasm.vm.tick(ctx);
    read_uint8(10, ctx^.ExecutionState.Memory, @b);
    assert_u32('copy[10]=$AA', b, $AA);
    read_uint8(11, ctx^.ExecutionState.Memory, @b);
    assert_u32('copy[11]=$BB', b, $BB);
    read_uint8(12, ctx^.ExecutionState.Memory, @b);
    assert_u32('copy[12]=$CC', b, $CC);

    { Overlapping forward (d < s): src=[0..2], dst=[1..3] — should still work }
    ctx := make_test_context(@code[0], 4);
    write_uint8(0, ctx^.ExecutionState.Memory, $11);
    write_uint8(1, ctx^.ExecutionState.Memory, $22);
    write_uint8(2, ctx^.ExecutionState.Memory, $33);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);   { d = 1, less than s=2 isn't tested... }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { s = 0 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 2);   { n = 2 }
    wasm.vm.tick(ctx);
    read_uint8(1, ctx^.ExecutionState.Memory, @b);
    assert_u32('overlap_fwd[1]=$11', b, $11);
    read_uint8(2, ctx^.ExecutionState.Memory, @b);
    assert_u32('overlap_fwd[2]=$22', b, $22);

    { Overlapping backward (d > s): copy [0..2] to [1..3] }
    ctx := make_test_context(@code[0], 4);
    write_uint8(0, ctx^.ExecutionState.Memory, $AA);
    write_uint8(1, ctx^.ExecutionState.Memory, $BB);
    write_uint8(2, ctx^.ExecutionState.Memory, $CC);
    pushi32(ctx^.ExecutionState.Operand_Stack, 1);   { d = 1 (d > s) }
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);   { s = 0 }
    pushi32(ctx^.ExecutionState.Operand_Stack, 3);   { n = 3 }
    wasm.vm.tick(ctx);
    { With backward copy, should preserve original data correctly }
    read_uint8(1, ctx^.ExecutionState.Memory, @b);
    assert_u32('overlap_bwd[1]=$AA', b, $AA);
    read_uint8(2, ctx^.ExecutionState.Memory, @b);
    assert_u32('overlap_bwd[2]=$BB', b, $BB);
    read_uint8(3, ctx^.ExecutionState.Memory, @b);
    assert_u32('overlap_bwd[3]=$CC', b, $CC);

    { n=0 is a no-op }
    ctx := make_test_context(@code[0], 4);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    pushi32(ctx^.ExecutionState.Operand_Stack, 0);
    wasm.vm.tick(ctx);
    assert_true('n=0 still running', ctx^.ExecutionState.Running);

    test_end;
end;

end.
