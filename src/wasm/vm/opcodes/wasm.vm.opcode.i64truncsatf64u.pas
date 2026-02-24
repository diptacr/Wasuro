unit wasm.vm.opcode.i64truncsatf64u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64TruncSatF64UOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64TruncSatF64UOp(Context : PWASMProcessContext);
var a : TWASMDouble;
    bits : TWASMUInt64;
    half : TWASMInt64;
begin
    a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
    bits := TWASMPUInt64(@a)^;
    if (((bits and $7FF0000000000000) = $7FF0000000000000) and ((bits and $000FFFFFFFFFFFFF) <> 0)) or (a < 0.0) then
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, 0)
    else if a >= 18446744073709551616.0 then
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64($FFFFFFFFFFFFFFFF))
    else if a >= 9223372036854775808.0 then begin
        { Value too large for signed i64 — split: subtract 2^63, trunc, add back }
        a := a - 9223372036854775808.0;
        half := Trunc(a);
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack,
            TWASMInt64(TWASMUInt64(half) + TWASMUInt64($8000000000000000)));
    end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, Trunc(a));
end;

end.
