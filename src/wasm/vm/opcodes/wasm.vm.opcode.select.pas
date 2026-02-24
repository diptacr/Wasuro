unit wasm.vm.opcode.select;

interface

uses wasm.types.context;

procedure _WASM_opcode_SelectOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_SelectOp(Context : PWASMProcessContext);
var
     cond : TWASMInt32;
     val2_idx, val1_idx : TWASMUInt32;
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

end.
