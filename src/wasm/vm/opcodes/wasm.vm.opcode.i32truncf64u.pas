unit wasm.vm.opcode.i32truncf64u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32TruncF64UOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32TruncF64UOp(Context : PWASMProcessContext);
var a : TWASMDouble;
    bits : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     bits := TWASMPUInt64(@a)^;
     if (((bits and $7FF0000000000000) = $7FF0000000000000) and ((bits and $000FFFFFFFFFFFFF) <> 0)) or
        (a >= 4294967296.0) or (a < 0.0) then begin
        Context^.ExecutionState.Running := false;
        exit;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(TWASMUInt32(Trunc(a))));
end;

end.
