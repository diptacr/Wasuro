unit wasm.vm.opcode.memorysize;

interface

uses wasm.types.context;

procedure _WASM_opcode_MemorySizeOp(Context : PWASMProcessContext);

implementation

uses leb128, wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_MemorySizeOp(Context : PWASMProcessContext);
var reserved : TWASMUInt32; bytesRead : TWASMUInt8;
begin
     Inc(Context^.ExecutionState.IP);
     { memory index immediate (reserved, must be 0) }
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @reserved);
     Inc(Context^.ExecutionState.IP, bytesRead);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(Context^.ExecutionState.Memory^.PageCount));
end;

end.
