unit wasm.vm.opcode.f32converti32s;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32ConvertI32SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32ConvertI32SOp(Context : PWASMProcessContext);
var v : TWASMInt32;
    r : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     r := v;
     wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, r);
end;

end.
