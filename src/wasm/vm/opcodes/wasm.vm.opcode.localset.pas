unit wasm.vm.opcode.localset;

interface

uses wasm.types.context;

procedure _WASM_opcode_LocalSetOp(Context : PWASMProcessContext);

implementation

uses console, wasm.types.leb128, wasm.types.builtin, wasm.types.enums, wasm.types.values, wasm.types.stack;

procedure _WASM_opcode_LocalSetOp(Context : PWASMProcessContext);
var idx : TWASMUInt32; bytesRead : TWASMUInt8; entry : PWASMValueEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Locals^.Locals[idx];
     case entry^.ValueType of
        vti32: entry^.i32Value := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
        vti64: entry^.i64Value := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
        vtf32: entry^.f32Value := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
        vtf64: entry^.f64Value := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     else begin
        console.writestringln('[wasm.vm.opcodes.localset] Unknown local type!');
        Context^.ExecutionState.Running := false;
     end;
     end;
end;

end.
