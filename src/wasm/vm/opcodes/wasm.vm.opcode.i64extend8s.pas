unit wasm.vm.opcode.i64extend8s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64Extend8SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64Extend8SOp(Context : PWASMProcessContext);
var v : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     v := TWASMInt64(TWASMSInt8(v and $FF));
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, v);
end;

end.
