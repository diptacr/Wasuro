unit wasm.vm.opcode.i32truncf64s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32TruncF64SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32TruncF64SOp(Context : PWASMProcessContext);
var a : TWASMDouble;
    bits : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt64(@a)^;
     if (((bits and $7FF0000000000000) = $7FF0000000000000) and ((bits and $000FFFFFFFFFFFFF) <> 0)) or
        (a >= 2147483648.0) or (a < -2147483649.0) then begin
        Context^.ExecutionState.Running := false;
        exit;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(Trunc(a)));
end;

end.
