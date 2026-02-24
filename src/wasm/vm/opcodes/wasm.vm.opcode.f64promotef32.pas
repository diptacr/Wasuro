unit wasm.vm.opcode.f64promotef32;

interface

uses wasm.types.context;

procedure _WASM_opcode_F64PromoteF32Op(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_F64PromoteF32Op(Context : PWASMProcessContext);
var v : TWASMFloat;
    r : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     v := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     r := v;
     wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, r);
end;

end.
