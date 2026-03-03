unit wasm.vm.opcode.globalget;

interface

uses wasm.types.context;

procedure _WASM_opcode_GlobalGetOp(Context : PWASMProcessContext);

implementation

uses wasm.vm.io, wasm.types.leb128, wasm.types.builtin, wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.stack;

procedure _WASM_opcode_GlobalGetOp(Context : PWASMProcessContext);
var idx : TWASMUInt32; bytesRead : TWASMUInt8; entry : PWASMGlobalEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Globals^.Globals[idx];
     case entry^.ValueType of
        vti32: wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, entry^.Value.i32Value);
        vti64: wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, entry^.Value.i64Value);
        vtf32: wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, entry^.Value.f32Value);
        vtf64: wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, entry^.Value.f64Value);
     else begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes.globalget] Unknown global type!');
        Context^.ExecutionState.Running := false;
     end;
     end;
end;

end.
