unit wasm.vm.opcode.i64truncf32u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64TruncF32UOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64TruncF32UOp(Context : PWASMProcessContext);
var a : TWASMFloat;
    bits : TWASMUInt32;
    r : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt32(@a)^;
     if (((bits and $7F800000) = $7F800000) and ((bits and $007FFFFF) <> 0)) or
        (a >= 18446744073709551616.0) or (a < 0.0) then begin
        Context^.ExecutionState.Running := false;
        exit;
     end;
     if a < 9223372036854775808.0 then
        r := Trunc(a)
     else
        r := TWASMInt64(TWASMUInt64(Trunc(a - 9223372036854775808.0)) + TWASMUInt64($8000000000000000));
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, r);
end;

end.
