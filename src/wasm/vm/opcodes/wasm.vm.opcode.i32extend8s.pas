unit wasm.vm.opcode.i32extend8s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32Extend8SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32Extend8SOp(Context : PWASMProcessContext);
var v : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     v := TWASMInt32(TWASMSInt8(v and $FF));
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, v);
end;

end.
