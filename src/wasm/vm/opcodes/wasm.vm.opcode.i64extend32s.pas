unit wasm.vm.opcode.i64extend32s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64Extend32SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64Extend32SOp(Context : PWASMProcessContext);
var v : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     v := TWASMInt64(TWASMInt32(v and $FFFFFFFF));
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, v);
end;

end.
