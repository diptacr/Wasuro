unit wasm.vm.opcode.i64store32;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64Store32Op(Context : PWASMProcessContext);

implementation

uses console, leb128, wasm.types.builtin, wasm.types.heap, wasm.types.stack;

procedure _WASM_opcode_I64Store32Op(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint32(addr, Context^.ExecutionState.Memory, TWASMUInt32(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.store32 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

end.
