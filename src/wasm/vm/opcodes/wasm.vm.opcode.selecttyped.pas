unit wasm.vm.opcode.selecttyped;

interface

uses wasm.types.context;

procedure _WASM_opcode_SelectTypedOp(Context : PWASMProcessContext);

implementation

uses leb128, wasm.types.builtin, wasm.types.stack;

{ select t* : like select, but preceded by a type vector immediate.
  Binary encoding: 0x1C vec(valtype)
  The type vector always has exactly 1 element in MVP.
  We read and skip the vector count + type bytes, then do the same
  select logic as the untyped variant. }

procedure _WASM_opcode_SelectTypedOp(Context : PWASMProcessContext);
var
     cond : TWASMInt32;
     val2_idx, val1_idx : TWASMUInt32;
     vecCount : TWASMUInt32;
     bytesRead : TWASMUInt8;
     i : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);

     { Read the type vector count (LEB128) }
     bytesRead := read_leb128_to_uint32(
         @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
         TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
         @vecCount);
     Inc(Context^.ExecutionState.IP, bytesRead);

     { Skip over each valtype byte in the vector }
     for i := 1 to vecCount do
         Inc(Context^.ExecutionState.IP);

     { Now do the same select logic as the untyped select }
     cond := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     val2_idx := Context^.ExecutionState.Operand_Stack^.Top - 1;
     val1_idx := Context^.ExecutionState.Operand_Stack^.Top - 2;
     Dec(Context^.ExecutionState.Operand_Stack^.Top, 2);
     if cond <> 0 then begin
        Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top] := Context^.ExecutionState.Operand_Stack^.Entries[val1_idx];
     end else begin
        Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top] := Context^.ExecutionState.Operand_Stack^.Entries[val2_idx];
     end;
     Inc(Context^.ExecutionState.Operand_Stack^.Top);
end;

end.
