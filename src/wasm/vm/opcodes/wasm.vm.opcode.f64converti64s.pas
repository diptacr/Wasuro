unit wasm.vm.opcode.f64converti64s;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64ConvertI64SOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64ConvertI64SOp(Context : PWASMProcessContext);
var v : TWASMInt64;
    r : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     r := v;
     wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, r);
end;

end.
