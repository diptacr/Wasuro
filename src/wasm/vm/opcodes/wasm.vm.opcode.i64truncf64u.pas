unit wasm.vm.opcode.i64truncf64u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64TruncF64UOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64TruncF64UOp(Context : PWASMProcessContext);
var a : TWASMDouble;
    bits : TWASMUInt64;
    r : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt64(@a)^;
     if (((bits and $7FF0000000000000) = $7FF0000000000000) and ((bits and $000FFFFFFFFFFFFF) <> 0)) or
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
