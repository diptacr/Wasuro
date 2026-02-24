unit wasm.vm.opcode.f32demotef64;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32DemoteF64Op(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32DemoteF64Op(Context : PWASMProcessContext);
var v : TWASMDouble;
    r : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     r := v;
     wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, r);
end;

end.
