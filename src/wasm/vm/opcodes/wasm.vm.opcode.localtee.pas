unit wasm.vm.opcode.localtee;

interface

uses wasm.types.context;

procedure _WASM_opcode_LocalTeeOp(Context : PWASMProcessContext);

implementation

uses wasm.vm.io, wasm.types.leb128, wasm.types.builtin, wasm.types.enums, wasm.types.values, wasm.types.stack;

procedure _WASM_opcode_LocalTeeOp(Context : PWASMProcessContext);
var idx : TWASMUInt32; bytesRead : TWASMUInt8; entry : PWASMValueEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Locals^.Locals[idx];
     { tee = set local but keep value on stack (peek then set) }
     case entry^.ValueType of
        vti32: entry^.i32Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].i32Value;
        vti64: entry^.i64Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].i64Value;
        vtf32: entry^.f32Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].f32Value;
        vtf64: entry^.f64Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].f64Value;
     else begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes.localtee] Unknown local type!');
        Context^.ExecutionState.Running := false;
     end;
     end;
end;

end.
