unit wasm.vm.opcode.i64extendi32s;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64ExtendI32SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64ExtendI32SOp(Context : PWASMProcessContext);
var v : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(v));
end;

end.
