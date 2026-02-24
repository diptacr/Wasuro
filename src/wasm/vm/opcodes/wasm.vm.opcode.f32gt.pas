unit wasm.vm.opcode.f32gt;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32GtOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32GtOp(Context : PWASMProcessContext);
var a, b : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a > b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

end.
