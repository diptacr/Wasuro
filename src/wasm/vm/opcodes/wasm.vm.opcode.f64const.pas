unit wasm.vm.opcode.f64const;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64ConstOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64ConstOp(Context : PWASMProcessContext);
var
     value : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     value := TWASMPDouble(@Context^.ExecutionState.Code[Context^.ExecutionState.IP])^;
     Inc(Context^.ExecutionState.IP, 8);
     wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, value);
end;

end.
