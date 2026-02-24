unit wasm.vm.opcode.i64eqz;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64EqzOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64EqzOp(Context : PWASMProcessContext);
var a : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a = 0 then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

end.
