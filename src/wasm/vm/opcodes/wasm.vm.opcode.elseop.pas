unit wasm.vm.opcode.elseop;

interface

uses wasm.types.context;

procedure _WASM_opcode_ElseOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.vm.control;

procedure _WASM_opcode_ElseOp(Context : PWASMProcessContext);
var
    cs, os: PWASMStack;
    saved_top: TWASMInt32;
    end_ip: TWASMUInt32;
    result_entry: TWASMStackEntry;
begin
    cs := Context^.ExecutionState.Control_Stack;
    os := Context^.ExecutionState.Operand_Stack;
    { Reached by falling through from if-true body }
    saved_top := cs^.Entries[cs^.Top - 2].i32Value;
    { Preserve result value if any }
    if os^.Top > TWASMUInt32(saved_top) then begin
        result_entry := os^.Entries[os^.Top - 1];
        os^.Top := TWASMUInt32(saved_top);
        os^.Entries[os^.Top] := result_entry;
        Inc(os^.Top);
    end else begin
        os^.Top := TWASMUInt32(saved_top);
    end;
    { Pop the IF frame }
    Dec(cs^.Top, 3);
    { Skip the else body to the matching end }
    Inc(Context^.ExecutionState.IP); { past else byte }
    end_ip := scan_forward(Context^.ExecutionState.Code,
                           Context^.ExecutionState.IP,
                           Context^.ExecutionState.Limit, false);
    Context^.ExecutionState.IP := end_ip + 1; { past end byte }
end;

end.
