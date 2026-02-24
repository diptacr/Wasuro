unit wasm.vm.opcode.i64const;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64ConstOp(Context : PWASMProcessContext);

implementation

uses leb128, wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64ConstOp(Context : PWASMProcessContext);
var
     bytesRead : TWASMUInt8;
     value : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint64(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @value);
     Inc(Context^.ExecutionState.IP, bytesRead);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(value));
end;

end.
