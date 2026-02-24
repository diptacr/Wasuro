unit wasm.vm.opcode.localget;

interface

uses wasm.types.context;

procedure _WASM_opcode_LocalGetOp(Context : PWASMProcessContext);

implementation

uses console, leb128, wasm.types.builtin, wasm.types.enums, wasm.types.values, wasm.types.stack;

procedure _WASM_opcode_LocalGetOp(Context : PWASMProcessContext);
var idx : TWASMUInt32; bytesRead : TWASMUInt8; entry : PWASMValueEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Locals^.Locals[idx];
     case entry^.ValueType of
        vti32: wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, entry^.i32Value);
        vti64: wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, entry^.i64Value);
        vtf32: wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, entry^.f32Value);
        vtf64: wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, entry^.f64Value);
     else begin
        console.writestringln('[wasm.vm.opcodes.localget] Unknown local type!');
        Context^.ExecutionState.Running := false;
     end;
     end;
end;

end.
