unit wasm.vm.opcode.i64extend16s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64Extend16SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64Extend16SOp(Context : PWASMProcessContext);
var v : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     v := TWASMInt64(TWASMSInt16(v and $FFFF));
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, v);
end;

end.
