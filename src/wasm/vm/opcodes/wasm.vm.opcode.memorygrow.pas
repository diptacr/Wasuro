unit wasm.vm.opcode.memorygrow;

interface

uses wasm.types.context;

procedure _WASM_opcode_MemoryGrowOp(Context : PWASMProcessContext);

implementation

uses wasm.types.leb128, wasm.types.builtin, wasm.types.heap, wasm.types.stack;

procedure _WASM_opcode_MemoryGrowOp(Context : PWASMProcessContext);
var reserved : TWASMUInt32; bytesRead : TWASMUInt8; pages_to_grow, old_size : TWASMUInt32; i : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     { memory index immediate (reserved, must be 0) }
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @reserved);
     Inc(Context^.ExecutionState.IP, bytesRead);
     pages_to_grow := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     old_size := Context^.ExecutionState.Memory^.PageCount;
     if pages_to_grow > 0 then begin
        for i := 0 to pages_to_grow - 1 do begin
           if not wasm.types.heap.expand_heap(Context^.ExecutionState.Memory) then begin
              wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, -1);
              exit;
           end;
        end;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(old_size));
end;

end.
