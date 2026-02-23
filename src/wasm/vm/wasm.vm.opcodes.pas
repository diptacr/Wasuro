unit wasm.vm.opcodes;

interface

uses
    console, leb128,
    wasm.types, wasm.types.heap, wasm.types.stack;

procedure initializeOpcodeJumpTable(Table : PWASMOpcodeJumpTable);

implementation

procedure _WASM_opcode_UnreachableOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] UnreachableOp not implemented!');
end;

procedure _WASM_opcode_NopOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] NopOp not implemented!');
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
     console.writestringln('[wasm.vm.opcodes] DropOp not implemented!');
end;

procedure _WASM_opcode_SelectOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] SelectOp not implemented!');
end;

procedure _WASM_opcode_LocalGetOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] LocalGetOp not implemented!');
end;

procedure _WASM_opcode_LocalSetOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] LocalSetOp not implemented!');
end;

procedure _WASM_opcode_LocalTeeOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] LocalTeeOp not implemented!');
end;

procedure _WASM_opcode_GlobalGetOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] GlobalGetOp not implemented!');
end;

procedure _WASM_opcode_GlobalSetOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] GlobalSetOp not implemented!');
end;

procedure _WASM_opcode_I32LoadOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32LoadOp not implemented!');
end;

procedure _WASM_opcode_I64LoadOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64LoadOp not implemented!');
end;

procedure _WASM_opcode_F32LoadOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F32LoadOp not implemented!');
end;

procedure _WASM_opcode_F64LoadOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F64LoadOp not implemented!');
end;

procedure _WASM_opcode_I32Load8SOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32Load8SOp not implemented!');
end;

procedure _WASM_opcode_I32Load8UOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32Load8UOp not implemented!');
end;

procedure _WASM_opcode_I32Load16SOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32Load16SOp not implemented!');
end;

procedure _WASM_opcode_I32Load16UOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32Load16UOp not implemented!');
end;

procedure _WASM_opcode_I64Load8SOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64Load8SOp not implemented!');
end;

procedure _WASM_opcode_I64Load8UOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64Load8UOp not implemented!');
end;

procedure _WASM_opcode_I64Load16SOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64Load16SOp not implemented!');
end;

procedure _WASM_opcode_I64Load16UOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64Load16UOp not implemented!');
end;

procedure _WASM_opcode_I64Load32SOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64Load32SOp not implemented!');
end;

procedure _WASM_opcode_I64Load32UOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64Load32UOp not implemented!');
end;

procedure _WASM_opcode_I32StoreOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32StoreOp not implemented!');
end;

procedure _WASM_opcode_I64StoreOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64StoreOp not implemented!');
end;

procedure _WASM_opcode_F32StoreOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F32StoreOp not implemented!');
end;

procedure _WASM_opcode_F64StoreOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F64StoreOp not implemented!');
end;

procedure _WASM_opcode_I32Store8Op(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32Store8Op not implemented!');
end;

procedure _WASM_opcode_I32Store16Op(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32Store16Op not implemented!');
end;

procedure _WASM_opcode_I64Store8Op(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64Store8Op not implemented!');
end;

procedure _WASM_opcode_I64Store16Op(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64Store16Op not implemented!');
end;

procedure _WASM_opcode_I64Store32Op(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64Store32Op not implemented!');
end;

procedure _WASM_opcode_MemorySizeOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] MemorySizeOp not implemented!');
end;

procedure _WASM_opcode_MemoryGrowOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] MemoryGrowOp not implemented!');
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
begin
     console.writestringln('[wasm.vm.opcodes] I64ConstOp not implemented!');
end;

procedure _WASM_opcode_F32ConstOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F32ConstOp not implemented!');
end;

procedure _WASM_opcode_F64ConstOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F64ConstOp not implemented!');
end;

procedure _WASM_opcode_I32EqzOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32EqzOp not implemented!');
end;

procedure _WASM_opcode_I32EqOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32EqOp not implemented!');
end;

procedure _WASM_opcode_I32NeOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32NeOp not implemented!');
end;

procedure _WASM_opcode_I32LtSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32LtSOp not implemented!');
end;

procedure _WASM_opcode_I32LtUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32LtUOp not implemented!');
end;

procedure _WASM_opcode_I32GtSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32GtSOp not implemented!');
end;

procedure _WASM_opcode_I32GtUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32GtUOp not implemented!');
end;

procedure _WASM_opcode_I32LeSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32LeSOp not implemented!');
end;

procedure _WASM_opcode_I32LeUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32LeUOp not implemented!');
end;

procedure _WASM_opcode_I32GeSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32GeSOp not implemented!');
end;

procedure _WASM_opcode_I32GeUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32GeUOp not implemented!');
end;

procedure _WASM_opcode_I64EqzOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64EqzOp not implemented!');
end;

procedure _WASM_opcode_I64EqOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64EqOp not implemented!');
end;

procedure _WASM_opcode_I64NeOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64NeOp not implemented!');
end;

procedure _WASM_opcode_I64LtSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64LtSOp not implemented!');
end;

procedure _WASM_opcode_I64LtUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64LtUOp not implemented!');
end;

procedure _WASM_opcode_I64GtSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64GtSOp not implemented!');
end;

procedure _WASM_opcode_I64GtUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64GtUOp not implemented!');
end;

procedure _WASM_opcode_I64LeSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64LeSOp not implemented!');
end;

procedure _WASM_opcode_I64LeUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64LeUOp not implemented!');
end;

procedure _WASM_opcode_I64GeSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64GeSOp not implemented!');
end;

procedure _WASM_opcode_I64GeUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64GeUOp not implemented!');
end;

procedure _WASM_opcode_F32EqOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F32EqOp not implemented!');
end;

procedure _WASM_opcode_F32NeOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F32NeOp not implemented!');
end;

procedure _WASM_opcode_F32LtOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F32LtOp not implemented!');
end;

procedure _WASM_opcode_F32GtOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F32GtOp not implemented!');
end;

procedure _WASM_opcode_F32LeOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F32LeOp not implemented!');
end;

procedure _WASM_opcode_F32GeOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F32GeOp not implemented!');
end;

procedure _WASM_opcode_F64EqOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F64EqOp not implemented!');
end;

procedure _WASM_opcode_F64NeOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F64NeOp not implemented!');
end;

procedure _WASM_opcode_F64LtOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F64LtOp not implemented!');
end;

procedure _WASM_opcode_F64GtOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F64GtOp not implemented!');
end;

procedure _WASM_opcode_F64LeOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F64LeOp not implemented!');
end;

procedure _WASM_opcode_F64GeOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] F64GeOp not implemented!');
end;

procedure _WASM_opcode_I32ClzOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32ClzOp not implemented!');
end;

procedure _WASM_opcode_I32CtzOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32CtzOp not implemented!');
end;

procedure _WASM_opcode_I32PopcntOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32PopcntOp not implemented!');
end;

procedure _WASM_opcode_I32AddOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32AddOp not implemented!');
end;

procedure _WASM_opcode_I32SubOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32SubOp not implemented!');
end;

procedure _WASM_opcode_I32MulOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32MulOp not implemented!');
end;

procedure _WASM_opcode_I32DivSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32DivSOp not implemented!');
end;

procedure _WASM_opcode_I32DivUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32DivUOp not implemented!');
end;

procedure _WASM_opcode_I32RemSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32RemSOp not implemented!');
end;

procedure _WASM_opcode_I32RemUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32RemUOp not implemented!');
end;

procedure _WASM_opcode_I32AndOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32AndOp not implemented!');
end;

procedure _WASM_opcode_I32OrOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32OrOp not implemented!');
end;

procedure _WASM_opcode_I32XorOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32XorOp not implemented!');
end;

procedure _WASM_opcode_I32ShlOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32ShlOp not implemented!');
end;

procedure _WASM_opcode_I32ShrSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32ShrSOp not implemented!');
end;

procedure _WASM_opcode_I32ShrUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32ShrUOp not implemented!');
end;

procedure _WASM_opcode_I32RotlOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32RotlOp not implemented!');
end;

procedure _WASM_opcode_I32RotrOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I32RotrOp not implemented!');
end;

procedure _WASM_opcode_I64ClzOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64ClzOp not implemented!');
end;

procedure _WASM_opcode_I64CtzOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64CtzOp not implemented!');
end;

procedure _WASM_opcode_I64PopcntOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64PopcntOp not implemented!');
end;

procedure _WASM_opcode_I64AddOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64AddOp not implemented!');
end;

procedure _WASM_opcode_I64SubOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64SubOp not implemented!');
end;

procedure _WASM_opcode_I64MulOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64MulOp not implemented!');
end;

procedure _WASM_opcode_I64DivSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64DivSOp not implemented!');
end;

procedure _WASM_opcode_I64DivUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64DivUOp not implemented!');
end;

procedure _WASM_opcode_I64RemSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64RemSOp not implemented!');
end;

procedure _WASM_opcode_I64RemUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64RemUOp not implemented!');
end;

procedure _WASM_opcode_I64AndOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64AndOp not implemented!');
end;

procedure _WASM_opcode_I64OrOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64OrOp not implemented!');
end;

procedure _WASM_opcode_I64XorOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64XorOp not implemented!');
end;

procedure _WASM_opcode_I64ShlOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64ShlOp not implemented!');
end;

procedure _WASM_opcode_I64ShrSOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64ShrSOp not implemented!');
end;

procedure _WASM_opcode_I64ShrUOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64ShrUOp not implemented!');
end;

procedure _WASM_opcode_I64RotlOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64RotlOp not implemented!');
end;

procedure _WASM_opcode_I64RotrOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] I64RotrOp not implemented!');
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

