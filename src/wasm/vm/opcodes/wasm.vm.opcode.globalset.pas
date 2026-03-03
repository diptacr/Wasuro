unit wasm.vm.opcode.globalset;

interface

uses wasm.types.context;

procedure _WASM_opcode_GlobalSetOp(Context : PWASMProcessContext);

implementation

uses wasm.vm.io, wasm.types.leb128, wasm.types.builtin, wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.stack;

procedure _WASM_opcode_GlobalSetOp(Context : PWASMProcessContext);
var idx : TWASMUInt32; bytesRead : TWASMUInt8; entry : PWASMGlobalEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Globals^.Globals[idx];
     if not entry^.Mutable then begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes.globalset] Trap: attempt to set immutable global!');
        Context^.ExecutionState.Running := false;
     end else begin
        case entry^.ValueType of
           vti32: entry^.Value.i32Value := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
           vti64: entry^.Value.i64Value := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
           vtf32: entry^.Value.f32Value := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
           vtf64: entry^.Value.f64Value := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
        else begin
           wasm.vm.io.writestringln('[wasm.vm.opcodes.globalset] Unknown global type!');
           Context^.ExecutionState.Running := false;
        end;
        end;
     end;
end;

end.
