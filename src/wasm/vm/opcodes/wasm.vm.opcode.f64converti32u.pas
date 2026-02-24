unit wasm.vm.opcode.f64converti32u;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64ConvertI32UOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64ConvertI32UOp(Context : PWASMProcessContext);
var v : TWASMInt32;
    uv : TWASMUInt32;
    r : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     uv := TWASMUInt32(v);
     r := uv;
     wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, r);
end;

end.
