unit wasm.vm.opcodes;

interface

uses
    console, leb128, types,
    wasm.types, wasm.types.heap, wasm.types.stack;

procedure initializeOpcodeJumpTable(Table : PWASMOpcodeJumpTable);

implementation

procedure _WASM_opcode_UnreachableOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] Trap: unreachable executed!');
     Context^.ExecutionState.Running := false;
end;

procedure _WASM_opcode_NopOp(Context : PWASMProcessContext);
begin
     Inc(Context^.ExecutionState.IP);
end;

procedure _WASM_opcode_BlockOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] BlockOp not implemented!');
end;

procedure _WASM_opcode_LoopOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] LoopOp not implemented!');
end;

procedure _WASM_opcode_IfOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] IfOp not implemented!');
end;

procedure _WASM_opcode_ElseOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] ElseOp not implemented!');
end;

procedure _WASM_opcode_EndOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] EndOp not implemented!');
end;

procedure _WASM_opcode_BrOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] BrOp not implemented!');
end;

procedure _WASM_opcode_BrIfOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] BrIfOp not implemented!');
end;

procedure _WASM_opcode_BrTableOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] BrTableOp not implemented!');
end;

procedure _WASM_opcode_ReturnOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes.returnop] Partially implemented Opcode!');
     if Context^.ExecutionState.Control_Stack^.Top > 0 then begin
          Context^.ExecutionState.IP := wasm.types.stack.popfunc(Context^.ExecutionState.Control_Stack);
          Context^.ExecutionState.Control_Stack^.Top := wasm.types.stack.popfunc(Context^.ExecutionState.Control_Stack);
     end else begin
          console.writestringln('[wasm.vm.opcodes.returnop] No frame to return to! Stopping Execution.');
          Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_CallOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] CallOp not implemented!');
end;

procedure _WASM_opcode_CallIndirectOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] CallIndirectOp not implemented!');
end;

procedure _WASM_opcode_DropOp(Context : PWASMProcessContext);
begin
     Inc(Context^.ExecutionState.IP);
     if Context^.ExecutionState.Operand_Stack^.Top > 0 then
        Dec(Context^.ExecutionState.Operand_Stack^.Top)
     else begin
        console.writestringln('[wasm.vm.opcodes.dropop] Stack underflow!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_SelectOp(Context : PWASMProcessContext);
var
     cond : int32;
     val2_idx, val1_idx : uint32;
begin
     Inc(Context^.ExecutionState.IP);
     cond := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     { After popping cond, Top points past val2. val2 is at Top-1, val1 at Top-2. }
     val2_idx := Context^.ExecutionState.Operand_Stack^.Top - 1;
     val1_idx := Context^.ExecutionState.Operand_Stack^.Top - 2;
     { Pop both val2 and val1 }
     Dec(Context^.ExecutionState.Operand_Stack^.Top, 2);
     if cond <> 0 then begin
        { push val1 }
        Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top] := Context^.ExecutionState.Operand_Stack^.Entries[val1_idx];
     end else begin
        { push val2 }
        Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top] := Context^.ExecutionState.Operand_Stack^.Entries[val2_idx];
     end;
     Inc(Context^.ExecutionState.Operand_Stack^.Top);
end;

procedure _WASM_opcode_LocalGetOp(Context : PWASMProcessContext);
var idx : uint32; bytesRead : uint8; entry : PWASMValueEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
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

procedure _WASM_opcode_LocalSetOp(Context : PWASMProcessContext);
var idx : uint32; bytesRead : uint8; entry : PWASMValueEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
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

procedure _WASM_opcode_LocalTeeOp(Context : PWASMProcessContext);
var idx : uint32; bytesRead : uint8; entry : PWASMValueEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Locals^.Locals[idx];
     { tee = set local but keep value on stack (peek then set) }
     case entry^.ValueType of
        vti32: entry^.i32Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].i32Value;
        vti64: entry^.i64Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].i64Value;
        vtf32: entry^.f32Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].f32Value;
        vtf64: entry^.f64Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].f64Value;
     else begin
        console.writestringln('[wasm.vm.opcodes.localtee] Unknown local type!');
        Context^.ExecutionState.Running := false;
     end;
     end;
end;

procedure _WASM_opcode_GlobalGetOp(Context : PWASMProcessContext);
var idx : uint32; bytesRead : uint8; entry : PWASMGlobalEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Globals^.Globals[idx];
     case entry^.ValueType of
        vti32: wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, entry^.Value.i32Value);
        vti64: wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, entry^.Value.i64Value);
        vtf32: wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, entry^.Value.f32Value);
        vtf64: wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, entry^.Value.f64Value);
     else begin
        console.writestringln('[wasm.vm.opcodes.globalget] Unknown global type!');
        Context^.ExecutionState.Running := false;
     end;
     end;
end;

procedure _WASM_opcode_GlobalSetOp(Context : PWASMProcessContext);
var idx : uint32; bytesRead : uint8; entry : PWASMGlobalEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Globals^.Globals[idx];
     if not entry^.Mutable then begin
        console.writestringln('[wasm.vm.opcodes.globalset] Trap: attempt to set immutable global!');
        Context^.ExecutionState.Running := false;
     end else begin
        case entry^.ValueType of
           vti32: entry^.Value.i32Value := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
           vti64: entry^.Value.i64Value := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
           vtf32: entry^.Value.f32Value := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
           vtf64: entry^.Value.f64Value := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
        else begin
           console.writestringln('[wasm.vm.opcodes.globalset] Unknown global type!');
           Context^.ExecutionState.Running := false;
        end;
        end;
     end;
end;

procedure _WASM_opcode_I32LoadOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint32(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.load out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(result_val));
end;

procedure _WASM_opcode_I64LoadOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint64(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(result_val));
end;

procedure _WASM_opcode_F32LoadOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint32(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: f32.load out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, pfloat(@result_val)^);
end;

procedure _WASM_opcode_F64LoadOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint64(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: f64.load out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, pdouble(@result_val)^);
end;

procedure _WASM_opcode_I32Load8SOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint8;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint8(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.load8_s out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(sint8(result_val)));
end;

procedure _WASM_opcode_I32Load8UOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint8;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint8(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.load8_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(result_val));
end;

procedure _WASM_opcode_I32Load16SOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint16;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint16(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.load16_s out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(sint16(result_val)));
end;

procedure _WASM_opcode_I32Load16UOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint16;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint16(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.load16_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(result_val));
end;

procedure _WASM_opcode_I64Load8SOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint8;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint8(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load8_s out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(sint8(result_val)));
end;

procedure _WASM_opcode_I64Load8UOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint8;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint8(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load8_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(result_val));
end;

procedure _WASM_opcode_I64Load16SOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint16;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint16(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load16_s out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(sint16(result_val)));
end;

procedure _WASM_opcode_I64Load16UOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint16;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint16(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load16_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(result_val));
end;

procedure _WASM_opcode_I64Load32SOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint32(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load32_s out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(int32(result_val)));
end;

procedure _WASM_opcode_I64Load32UOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; result_val : uint32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint32(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load32_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(result_val));
end;

procedure _WASM_opcode_I32StoreOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; val : int32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint32(addr, Context^.ExecutionState.Memory, uint32(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.store out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I64StoreOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; val : int64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint64(addr, Context^.ExecutionState.Memory, uint64(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.store out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_F32StoreOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; val : float;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint32(addr, Context^.ExecutionState.Memory, puint32(@val)^) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: f32.store out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_F64StoreOp(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; val : double;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint64(addr, Context^.ExecutionState.Memory, puint64(@val)^) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: f64.store out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I32Store8Op(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; val : int32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint8(addr, Context^.ExecutionState.Memory, uint8(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.store8 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I32Store16Op(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; val : int32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint16(addr, Context^.ExecutionState.Memory, uint16(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.store16 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I64Store8Op(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; val : int64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint8(addr, Context^.ExecutionState.Memory, uint8(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.store8 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I64Store16Op(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; val : int64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint16(addr, Context^.ExecutionState.Memory, uint16(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.store16 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I64Store32Op(Context : PWASMProcessContext);
var align_val, offset_val : uint32; bytesRead : uint8; addr : uint32; val : int64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     addr := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint32(addr, Context^.ExecutionState.Memory, uint32(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.store32 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_MemorySizeOp(Context : PWASMProcessContext);
var reserved : uint32; bytesRead : uint8;
begin
     Inc(Context^.ExecutionState.IP);
     { memory index immediate (reserved, must be 0) }
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @reserved);
     Inc(Context^.ExecutionState.IP, bytesRead);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(Context^.ExecutionState.Memory^.PageCount));
end;

procedure _WASM_opcode_MemoryGrowOp(Context : PWASMProcessContext);
var reserved : uint32; bytesRead : uint8; pages_to_grow, old_size : uint32; i : uint32;
begin
     Inc(Context^.ExecutionState.IP);
     { memory index immediate (reserved, must be 0) }
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @reserved);
     Inc(Context^.ExecutionState.IP, bytesRead);
     pages_to_grow := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     old_size := Context^.ExecutionState.Memory^.PageCount;
     if pages_to_grow > 0 then begin
        for i := 0 to pages_to_grow - 1 do begin
           if not wasm.types.heap.expand_heap(Context^.ExecutionState.Memory) then begin
              wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, -1);
              exit;
           end;
        end;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(old_size));
end;

procedure _WASM_opcode_I32ConstOp(Context : PWASMProcessContext);
var
     bytesRead, value : int32;

begin
     console.writestringln('[wasm.vm.opcodes.i32constop] I32ConstOp');
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @Value);
     Inc(Context^.ExecutionState.IP, bytesRead);
     if Context^.ExecutionState.Operand_Stack^.Full then begin
            console.writestringln('[wasm.vm.opcodes.i32constop] I32ConstOp: Stack Overflow!');
            Context^.ExecutionState.Running := false;
     end else
          wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, Value);
end;

procedure _WASM_opcode_I64ConstOp(Context : PWASMProcessContext);
var
     bytesRead : uint8;
     value : uint64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint64(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], puint8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @value);
     Inc(Context^.ExecutionState.IP, bytesRead);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(value));
end;

procedure _WASM_opcode_F32ConstOp(Context : PWASMProcessContext);
var
     value : float;
begin
     Inc(Context^.ExecutionState.IP);
     value := pfloat(@Context^.ExecutionState.Code[Context^.ExecutionState.IP])^;
     Inc(Context^.ExecutionState.IP, 4);
     wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, value);
end;

procedure _WASM_opcode_F64ConstOp(Context : PWASMProcessContext);
var
     value : double;
begin
     Inc(Context^.ExecutionState.IP);
     value := pdouble(@Context^.ExecutionState.Code[Context^.ExecutionState.IP])^;
     Inc(Context^.ExecutionState.IP, 8);
     wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, value);
end;

procedure _WASM_opcode_I32EqzOp(Context : PWASMProcessContext);
var a : int32;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a = 0 then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32EqOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a = b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32NeOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a <> b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32LtSOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a < b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32LtUOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if uint32(a) < uint32(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32GtSOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a > b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32GtUOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if uint32(a) > uint32(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32LeSOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a <= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32LeUOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if uint32(a) <= uint32(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32GeSOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a >= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32GeUOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if uint32(a) >= uint32(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64EqzOp(Context : PWASMProcessContext);
var a : int64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a = 0 then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64EqOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a = b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64NeOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a <> b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64LtSOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a < b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64LtUOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if uint64(a) < uint64(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64GtSOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a > b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64GtUOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if uint64(a) > uint64(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64LeSOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a <= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64LeUOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if uint64(a) <= uint64(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64GeSOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a >= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64GeUOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if uint64(a) >= uint64(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32EqOp(Context : PWASMProcessContext);
var a, b : float;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a = b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32NeOp(Context : PWASMProcessContext);
var a, b : float;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a <> b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32LtOp(Context : PWASMProcessContext);
var a, b : float;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a < b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32GtOp(Context : PWASMProcessContext);
var a, b : float;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a > b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32LeOp(Context : PWASMProcessContext);
var a, b : float;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a <= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32GeOp(Context : PWASMProcessContext);
var a, b : float;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a >= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64EqOp(Context : PWASMProcessContext);
var a, b : double;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a = b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64NeOp(Context : PWASMProcessContext);
var a, b : double;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a <> b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64LtOp(Context : PWASMProcessContext);
var a, b : double;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a < b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64GtOp(Context : PWASMProcessContext);
var a, b : double;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a > b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64LeOp(Context : PWASMProcessContext);
var a, b : double;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a <= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64GeOp(Context : PWASMProcessContext);
var a, b : double;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a >= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32ClzOp(Context : PWASMProcessContext);
var a : uint32; count : int32;
begin
     Inc(Context^.ExecutionState.IP);
     a := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     if a = 0 then count := 32
     else begin
        count := 0;
        while (a and $80000000) = 0 do begin
           Inc(count);
           a := a shl 1;
        end;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I32CtzOp(Context : PWASMProcessContext);
var a : uint32; count : int32;
begin
     Inc(Context^.ExecutionState.IP);
     a := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     if a = 0 then count := 32
     else begin
        count := 0;
        while (a and 1) = 0 do begin
           Inc(count);
           a := a shr 1;
        end;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I32PopcntOp(Context : PWASMProcessContext);
var a : uint32; count : int32;
begin
     Inc(Context^.ExecutionState.IP);
     a := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     count := 0;
     while a <> 0 do begin
        Inc(count, int32(a and 1));
        a := a shr 1;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I32AddOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a + b);
end;

procedure _WASM_opcode_I32SubOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a - b);
end;

procedure _WASM_opcode_I32MulOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a * b);
end;

procedure _WASM_opcode_I32DivSOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.div_s division by zero!');
        Context^.ExecutionState.Running := false;
     end else if (a = int32($80000000)) and (b = -1) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.div_s overflow!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a div b);
end;

procedure _WASM_opcode_I32DivUOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.div_u division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(uint32(a) div uint32(b)));
end;

procedure _WASM_opcode_I32RemSOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.rem_s division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a mod b);
end;

procedure _WASM_opcode_I32RemUOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.rem_u division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(uint32(a) mod uint32(b)));
end;

procedure _WASM_opcode_I32AndOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a and b);
end;

procedure _WASM_opcode_I32OrOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a or b);
end;

procedure _WASM_opcode_I32XorOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a xor b);
end;

procedure _WASM_opcode_I32ShlOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(uint32(a) shl (uint32(b) and 31)));
end;

procedure _WASM_opcode_I32ShrSOp(Context : PWASMProcessContext);
var a, b : int32; shift : uint32; res : uint32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     shift := uint32(b) and 31;
     res := uint32(a) shr shift;
     if (a < 0) and (shift > 0) then
        res := res or (uint32($FFFFFFFF) shl (32 - shift));
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(res));
end;

procedure _WASM_opcode_I32ShrUOp(Context : PWASMProcessContext);
var a, b : int32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32(uint32(a) shr (uint32(b) and 31)));
end;

procedure _WASM_opcode_I32RotlOp(Context : PWASMProcessContext);
var a : uint32; b : uint32; k : uint32;
begin
     Inc(Context^.ExecutionState.IP);
     b := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     a := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     k := b and 31;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32((a shl k) or (a shr (32 - k))));
end;

procedure _WASM_opcode_I32RotrOp(Context : PWASMProcessContext);
var a : uint32; b : uint32; k : uint32;
begin
     Inc(Context^.ExecutionState.IP);
     b := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     a := uint32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     k := b and 31;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, int32((a shr k) or (a shl (32 - k))));
end;

procedure _WASM_opcode_I64ClzOp(Context : PWASMProcessContext);
var a : uint64; count : int64;
begin
     Inc(Context^.ExecutionState.IP);
     a := uint64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     if a = 0 then count := 64
     else begin
        count := 0;
        while (a and uint64($8000000000000000)) = 0 do begin
           Inc(count);
           a := a shl 1;
        end;
     end;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I64CtzOp(Context : PWASMProcessContext);
var a : uint64; count : int64;
begin
     Inc(Context^.ExecutionState.IP);
     a := uint64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     if a = 0 then count := 64
     else begin
        count := 0;
        while (a and 1) = 0 do begin
           Inc(count);
           a := a shr 1;
        end;
     end;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I64PopcntOp(Context : PWASMProcessContext);
var a : uint64; count : int64;
begin
     Inc(Context^.ExecutionState.IP);
     a := uint64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     count := 0;
     while a <> 0 do begin
        Inc(count, int64(a and 1));
        a := a shr 1;
     end;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I64AddOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a + b);
end;

procedure _WASM_opcode_I64SubOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a - b);
end;

procedure _WASM_opcode_I64MulOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a * b);
end;

procedure _WASM_opcode_I64DivSOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.div_s division by zero!');
        Context^.ExecutionState.Running := false;
     end else if (a = int64($8000000000000000)) and (b = -1) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.div_s overflow!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a div b);
end;

procedure _WASM_opcode_I64DivUOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.div_u division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(uint64(a) div uint64(b)));
end;

procedure _WASM_opcode_I64RemSOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.rem_s division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a mod b);
end;

procedure _WASM_opcode_I64RemUOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.rem_u division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(uint64(a) mod uint64(b)));
end;

procedure _WASM_opcode_I64AndOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a and b);
end;

procedure _WASM_opcode_I64OrOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a or b);
end;

procedure _WASM_opcode_I64XorOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a xor b);
end;

procedure _WASM_opcode_I64ShlOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(uint64(a) shl (uint64(b) and 63)));
end;

procedure _WASM_opcode_I64ShrSOp(Context : PWASMProcessContext);
var a, b : int64; shift : uint64; res : uint64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     shift := uint64(b) and 63;
     res := uint64(a) shr shift;
     if (a < 0) and (shift > 0) then
        res := res or (uint64($FFFFFFFFFFFFFFFF) shl (64 - shift));
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(res));
end;

procedure _WASM_opcode_I64ShrUOp(Context : PWASMProcessContext);
var a, b : int64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64(uint64(a) shr (uint64(b) and 63)));
end;

procedure _WASM_opcode_I64RotlOp(Context : PWASMProcessContext);
var a, b, k : uint64;
begin
     Inc(Context^.ExecutionState.IP);
     b := uint64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     a := uint64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     k := b and 63;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64((a shl k) or (a shr (64 - k))));
end;

procedure _WASM_opcode_I64RotrOp(Context : PWASMProcessContext);
var a, b, k : uint64;
begin
     Inc(Context^.ExecutionState.IP);
     b := uint64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     a := uint64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     k := b and 63;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, int64((a shr k) or (a shl (64 - k))));
end;

procedure initializeOpcodeJumpTable(Table: PWASMOpcodeJumpTable);
begin
    console.writestringln('[wasm.vm.opcodes] Init Opcode Jump Table.');
    if (Table = nil) then exit;
    Table^[ord(TWasmOpcode.UnreachableOp)] := @_WASM_opcode_UnreachableOp;
    Table^[ord(TWasmOpcode.NopOp)] := @_WASM_opcode_NopOp;
    Table^[ord(TWasmOpcode.BlockOp)] := @_WASM_opcode_BlockOp;
    Table^[ord(TWasmOpcode.LoopOp)] := @_WASM_opcode_LoopOp;
    Table^[ord(TWasmOpcode.IfOp)] := @_WASM_opcode_IfOp;
    Table^[ord(TWasmOpcode.ElseOp)] := @_WASM_opcode_ElseOp;
    Table^[ord(TWasmOpcode.EndOp)] := @_WASM_opcode_EndOp;
    Table^[ord(TWasmOpcode.BrOp)] := @_WASM_opcode_BrOp;
    Table^[ord(TWasmOpcode.BrIfOp)] := @_WASM_opcode_BrIfOp;
    Table^[ord(TWasmOpcode.BrTableOp)] := @_WASM_opcode_BrTableOp;
    Table^[ord(TWasmOpcode.ReturnOp)] := @_WASM_opcode_ReturnOp;
    Table^[ord(TWasmOpcode.CallOp)] := @_WASM_opcode_CallOp;
    Table^[ord(TWasmOpcode.CallIndirectOp)] := @_WASM_opcode_CallIndirectOp;
    Table^[ord(TWasmOpcode.DropOp)] := @_WASM_opcode_DropOp;
    Table^[ord(TWasmOpcode.SelectOp)] := @_WASM_opcode_SelectOp;
    Table^[ord(TWasmOpcode.LocalGetOp)] := @_WASM_opcode_LocalGetOp;
    Table^[ord(TWasmOpcode.LocalSetOp)] := @_WASM_opcode_LocalSetOp;
    Table^[ord(TWasmOpcode.LocalTeeOp)] := @_WASM_opcode_LocalTeeOp;
    Table^[ord(TWasmOpcode.GlobalGetOp)] := @_WASM_opcode_GlobalGetOp;
    Table^[ord(TWasmOpcode.GlobalSetOp)] := @_WASM_opcode_GlobalSetOp;
    Table^[ord(TWasmOpcode.I32LoadOp)] := @_WASM_opcode_I32LoadOp;
    Table^[ord(TWasmOpcode.I64LoadOp)] := @_WASM_opcode_I64LoadOp;
    Table^[ord(TWasmOpcode.F32LoadOp)] := @_WASM_opcode_F32LoadOp;
    Table^[ord(TWasmOpcode.F64LoadOp)] := @_WASM_opcode_F64LoadOp;
    Table^[ord(TWasmOpcode.I32Load8SOp)] := @_WASM_opcode_I32Load8SOp;
    Table^[ord(TWasmOpcode.I32Load8UOp)] := @_WASM_opcode_I32Load8UOp;
    Table^[ord(TWasmOpcode.I32Load16SOp)] := @_WASM_opcode_I32Load16SOp;
    Table^[ord(TWasmOpcode.I32Load16UOp)] := @_WASM_opcode_I32Load16UOp;
    Table^[ord(TWasmOpcode.I64Load8SOp)] := @_WASM_opcode_I64Load8SOp;
    Table^[ord(TWasmOpcode.I64Load8UOp)] := @_WASM_opcode_I64Load8UOp;
    Table^[ord(TWasmOpcode.I64Load16SOp)] := @_WASM_opcode_I64Load16SOp;
    Table^[ord(TWasmOpcode.I64Load16UOp)] := @_WASM_opcode_I64Load16UOp;
    Table^[ord(TWasmOpcode.I64Load32SOp)] := @_WASM_opcode_I64Load32SOp;
    Table^[ord(TWasmOpcode.I64Load32UOp)] := @_WASM_opcode_I64Load32UOp;
    Table^[ord(TWasmOpcode.I32StoreOp)] := @_WASM_opcode_I32StoreOp;
    Table^[ord(TWasmOpcode.I64StoreOp)] := @_WASM_opcode_I64StoreOp;
    Table^[ord(TWasmOpcode.F32StoreOp)] := @_WASM_opcode_F32StoreOp;
    Table^[ord(TWasmOpcode.F64StoreOp)] := @_WASM_opcode_F64StoreOp;
    Table^[ord(TWasmOpcode.I32Store8Op)] := @_WASM_opcode_I32Store8Op;
    Table^[ord(TWasmOpcode.I32Store16Op)] := @_WASM_opcode_I32Store16Op;
    Table^[ord(TWasmOpcode.I64Store8Op)] := @_WASM_opcode_I64Store8Op;
    Table^[ord(TWasmOpcode.I64Store16Op)] := @_WASM_opcode_I64Store16Op;
    Table^[ord(TWasmOpcode.I64Store32Op)] := @_WASM_opcode_I64Store32Op;
    Table^[ord(TWasmOpcode.MemorySizeOp)] := @_WASM_opcode_MemorySizeOp;
    Table^[ord(TWasmOpcode.MemoryGrowOp)] := @_WASM_opcode_MemoryGrowOp;
    Table^[ord(TWasmOpcode.I32ConstOp)] := @_WASM_opcode_I32ConstOp;
    Table^[ord(TWasmOpcode.I64ConstOp)] := @_WASM_opcode_I64ConstOp;
    Table^[ord(TWasmOpcode.F32ConstOp)] := @_WASM_opcode_F32ConstOp;
    Table^[ord(TWasmOpcode.F64ConstOp)] := @_WASM_opcode_F64ConstOp;
    Table^[ord(TWasmOpcode.I32EqzOp)] := @_WASM_opcode_I32EqzOp;
    Table^[ord(TWasmOpcode.I32EqOp)] := @_WASM_opcode_I32EqOp;
    Table^[ord(TWasmOpcode.I32NeOp)] := @_WASM_opcode_I32NeOp;
    Table^[ord(TWasmOpcode.I32LtSOp)] := @_WASM_opcode_I32LtSOp;
    Table^[ord(TWasmOpcode.I32LtUOp)] := @_WASM_opcode_I32LtUOp;
    Table^[ord(TWasmOpcode.I32GtSOp)] := @_WASM_opcode_I32GtSOp;
    Table^[ord(TWasmOpcode.I32GtUOp)] := @_WASM_opcode_I32GtUOp;
    Table^[ord(TWasmOpcode.I32LeSOp)] := @_WASM_opcode_I32LeSOp;
    Table^[ord(TWasmOpcode.I32LeUOp)] := @_WASM_opcode_I32LeUOp;
    Table^[ord(TWasmOpcode.I32GeSOp)] := @_WASM_opcode_I32GeSOp;
    Table^[ord(TWasmOpcode.I32GeUOp)] := @_WASM_opcode_I32GeUOp;
    Table^[ord(TWasmOpcode.I64EqzOp)] := @_WASM_opcode_I64EqzOp;
    Table^[ord(TWasmOpcode.I64EqOp)] := @_WASM_opcode_I64EqOp;
    Table^[ord(TWasmOpcode.I64NeOp)] := @_WASM_opcode_I64NeOp;
    Table^[ord(TWasmOpcode.I64LtSOp)] := @_WASM_opcode_I64LtSOp;
    Table^[ord(TWasmOpcode.I64LtUOp)] := @_WASM_opcode_I64LtUOp;
    Table^[ord(TWasmOpcode.I64GtSOp)] := @_WASM_opcode_I64GtSOp;
    Table^[ord(TWasmOpcode.I64GtUOp)] := @_WASM_opcode_I64GtUOp;
    Table^[ord(TWasmOpcode.I64LeSOp)] := @_WASM_opcode_I64LeSOp;
    Table^[ord(TWasmOpcode.I64LeUOp)] := @_WASM_opcode_I64LeUOp;
    Table^[ord(TWasmOpcode.I64GeSOp)] := @_WASM_opcode_I64GeSOp;
    Table^[ord(TWasmOpcode.I64GeUOp)] := @_WASM_opcode_I64GeUOp;
    Table^[ord(TWasmOpcode.F32EqOp)] := @_WASM_opcode_F32EqOp;
    Table^[ord(TWasmOpcode.F32NeOp)] := @_WASM_opcode_F32NeOp;
    Table^[ord(TWasmOpcode.F32LtOp)] := @_WASM_opcode_F32LtOp;
    Table^[ord(TWasmOpcode.F32GtOp)] := @_WASM_opcode_F32GtOp;
    Table^[ord(TWasmOpcode.F32LeOp)] := @_WASM_opcode_F32LeOp;
    Table^[ord(TWasmOpcode.F32GeOp)] := @_WASM_opcode_F32GeOp;
    Table^[ord(TWasmOpcode.F64EqOp)] := @_WASM_opcode_F64EqOp;
    Table^[ord(TWasmOpcode.F64NeOp)] := @_WASM_opcode_F64NeOp;
    Table^[ord(TWasmOpcode.F64LtOp)] := @_WASM_opcode_F64LtOp;
    Table^[ord(TWasmOpcode.F64GtOp)] := @_WASM_opcode_F64GtOp;
    Table^[ord(TWasmOpcode.F64LeOp)] := @_WASM_opcode_F64LeOp;
    Table^[ord(TWasmOpcode.F64GeOp)] := @_WASM_opcode_F64GeOp;
    Table^[ord(TWasmOpcode.I32ClzOp)] := @_WASM_opcode_I32ClzOp;
    Table^[ord(TWasmOpcode.I32CtzOp)] := @_WASM_opcode_I32CtzOp;
    Table^[ord(TWasmOpcode.I32PopcntOp)] := @_WASM_opcode_I32PopcntOp;
    Table^[ord(TWasmOpcode.I32AddOp)] := @_WASM_opcode_I32AddOp;
    Table^[ord(TWasmOpcode.I32SubOp)] := @_WASM_opcode_I32SubOp;
    Table^[ord(TWasmOpcode.I32MulOp)] := @_WASM_opcode_I32MulOp;
    Table^[ord(TWasmOpcode.I32DivSOp)] := @_WASM_opcode_I32DivSOp;
    Table^[ord(TWasmOpcode.I32DivUOp)] := @_WASM_opcode_I32DivUOp;
    Table^[ord(TWasmOpcode.I32RemSOp)] := @_WASM_opcode_I32RemSOp;
    Table^[ord(TWasmOpcode.I32RemUOp)] := @_WASM_opcode_I32RemUOp;
    Table^[ord(TWasmOpcode.I32AndOp)] := @_WASM_opcode_I32AndOp;
    Table^[ord(TWasmOpcode.I32OrOp)] := @_WASM_opcode_I32OrOp;
    Table^[ord(TWasmOpcode.I32XorOp)] := @_WASM_opcode_I32XorOp;
    Table^[ord(TWasmOpcode.I32ShlOp)] := @_WASM_opcode_I32ShlOp;
    Table^[ord(TWasmOpcode.I32ShrSOp)] := @_WASM_opcode_I32ShrSOp;
    Table^[ord(TWasmOpcode.I32ShrUOp)] := @_WASM_opcode_I32ShrUOp;
    Table^[ord(TWasmOpcode.I32RotlOp)] := @_WASM_opcode_I32RotlOp;
    Table^[ord(TWasmOpcode.I32RotrOp)] := @_WASM_opcode_I32RotrOp;
    Table^[ord(TWasmOpcode.I64ClzOp)] := @_WASM_opcode_I64ClzOp;
    Table^[ord(TWasmOpcode.I64CtzOp)] := @_WASM_opcode_I64CtzOp;
    Table^[ord(TWasmOpcode.I64PopcntOp)] := @_WASM_opcode_I64PopcntOp;
    Table^[ord(TWasmOpcode.I64AddOp)] := @_WASM_opcode_I64AddOp;
    Table^[ord(TWasmOpcode.I64SubOp)] := @_WASM_opcode_I64SubOp;
    Table^[ord(TWasmOpcode.I64MulOp)] := @_WASM_opcode_I64MulOp;
    Table^[ord(TWasmOpcode.I64DivSOp)] := @_WASM_opcode_I64DivSOp;
    Table^[ord(TWasmOpcode.I64DivUOp)] := @_WASM_opcode_I64DivUOp;
    Table^[ord(TWasmOpcode.I64RemSOp)] := @_WASM_opcode_I64RemSOp;
    Table^[ord(TWasmOpcode.I64RemUOp)] := @_WASM_opcode_I64RemUOp;
    Table^[ord(TWasmOpcode.I64AndOp)] := @_WASM_opcode_I64AndOp;
    Table^[ord(TWasmOpcode.I64OrOp)] := @_WASM_opcode_I64OrOp;
    Table^[ord(TWasmOpcode.I64XorOp)] := @_WASM_opcode_I64XorOp;
    Table^[ord(TWasmOpcode.I64ShlOp)] := @_WASM_opcode_I64ShlOp;
    Table^[ord(TWasmOpcode.I64ShrSOp)] := @_WASM_opcode_I64ShrSOp;
    Table^[ord(TWasmOpcode.I64ShrUOp)] := @_WASM_opcode_I64ShrUOp;
    Table^[ord(TWasmOpcode.I64RotlOp)] := @_WASM_opcode_I64RotlOp;
    Table^[ord(TWasmOpcode.I64RotrOp)] := @_WASM_opcode_I64RotrOp;
end;

end.

