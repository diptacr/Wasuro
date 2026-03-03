unit wasm.vm.opcode.f32store;

interface

uses wasm.types.context;

procedure _WASM_opcode_F32StoreOp(Context : PWASMProcessContext);

implementation

uses wasm.vm.io, wasm.types.leb128, wasm.types.builtin, wasm.types.heap, wasm.types.stack;

procedure _WASM_opcode_F32StoreOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint32(addr, Context^.ExecutionState.Memory, TWASMPUInt32(@val)^) then begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes] Trap: f32.store out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

end.
