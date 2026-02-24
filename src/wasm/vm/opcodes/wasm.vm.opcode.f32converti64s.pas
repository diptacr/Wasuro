unit wasm.vm.opcode.f32converti64s;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32ConvertI64SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F32ConvertI64SOp(Context : PWASMProcessContext);
var v : TWASMInt64;
    r : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     r := v;
     wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, r);
end;

end.
