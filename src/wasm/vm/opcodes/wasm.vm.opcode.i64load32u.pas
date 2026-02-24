unit wasm.vm.opcode.i64load32u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64Load32UOp(Context : PWASMProcessContext);

implementation

uses console, leb128, wasm.types.builtin, wasm.types.heap, wasm.types.stack;

procedure _WASM_opcode_I64Load32UOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint32(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load32_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(result_val));
end;

end.
