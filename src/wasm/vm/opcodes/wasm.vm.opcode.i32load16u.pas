unit wasm.vm.opcode.i32load16u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32Load16UOp(Context : PWASMProcessContext);

implementation

uses wasm.vm.io, wasm.types.leb128, wasm.types.builtin, wasm.types.heap, wasm.types.stack;

procedure _WASM_opcode_I32Load16UOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt16;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint16(addr, Context^.ExecutionState.Memory, @result_val) then begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes] Trap: i32.load16_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(result_val));
end;

end.
