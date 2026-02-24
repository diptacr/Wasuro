unit wasm.vm.opcode.i32extend16s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32Extend16SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32Extend16SOp(Context : PWASMProcessContext);
var v : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     v := TWASMInt32(TWASMSInt16(v and $FFFF));
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, v);
end;

end.
