unit wasm.vm.opcode.i32truncf32u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32TruncF32UOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32TruncF32UOp(Context : PWASMProcessContext);
var a : TWASMFloat;
    bits : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt32(@a)^;
     if (((bits and $7F800000) = $7F800000) and ((bits and $007FFFFF) <> 0)) or
        (a >= 4294967296.0) or (a < 0.0) then begin
        Context^.ExecutionState.Running := false;
        exit;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(TWASMUInt32(Trunc(a))));
end;

end.
