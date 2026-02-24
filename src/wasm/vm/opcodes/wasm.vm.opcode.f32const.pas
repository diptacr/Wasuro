unit wasm.vm.opcode.f32const;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32ConstOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32ConstOp(Context : PWASMProcessContext);
var
     value : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     value := TWASMPFloat(@Context^.ExecutionState.Code[Context^.ExecutionState.IP])^;
     Inc(Context^.ExecutionState.IP, 4);
     wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, value);
end;

end.
