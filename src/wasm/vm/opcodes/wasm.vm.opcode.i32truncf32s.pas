unit wasm.vm.opcode.i32truncf32s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32TruncF32SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32TruncF32SOp(Context : PWASMProcessContext);
var a : TWASMFloat;
    bits : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt32(@a)^;
     if (((bits and $7F800000) = $7F800000) and ((bits and $007FFFFF) <> 0)) or
        (a >= 2147483648.0) or (a < -2147483648.0) then begin
        Context^.ExecutionState.Running := false;
        exit;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(Trunc(a)));
end;

end.
