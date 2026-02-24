unit wasm.vm.opcode.f64le;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64LeOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64LeOp(Context : PWASMProcessContext);
var a, b : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a <= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

end.
