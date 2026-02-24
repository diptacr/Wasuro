unit wasm.vm.opcode.i64leu;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64LeUOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64LeUOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if TWASMUInt64(a) <= TWASMUInt64(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

end.
