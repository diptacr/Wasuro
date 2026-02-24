unit wasm.vm.opcode.i64truncsatf32u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64TruncSatF32UOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64TruncSatF32UOp(Context : PWASMProcessContext);
var a : TWASMFloat;
    bits : TWASMUInt32;
    d : TWASMDouble;
    half : TWASMInt64;
begin
    a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
    bits := TWASMPUInt32(@a)^;
    if (((bits and $7F800000) = $7F800000) and ((bits and $007FFFFF) <> 0)) or (a < 0.0) then
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, 0)
    else begin
        d := a;
        if d >= 18446744073709551616.0 then
            wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64($FFFFFFFFFFFFFFFF))
        else if d >= 9223372036854775808.0 then begin
            { Value too large for signed i64 — split: subtract 2^63, trunc, add back }
            d := d - 9223372036854775808.0;
            half := Trunc(d);
            wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack,
                TWASMInt64(TWASMUInt64(half) + TWASMUInt64($8000000000000000)));
        end else
            wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, Trunc(d));
    end;
end;

end.
