unit wasm.vm.opcode.i32store16;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32Store16Op(Context : PWASMProcessContext);

implementation

uses console, wasm.types.leb128, wasm.types.builtin, wasm.types.heap, wasm.types.stack;

procedure _WASM_opcode_I32Store16Op(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint16(addr, Context^.ExecutionState.Memory, TWASMUInt16(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.store16 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

end.
