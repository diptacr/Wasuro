unit wasm.vm.opcode.return;

interface

uses wasm.types.context;

procedure _WASM_opcode_ReturnOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.constants;

procedure _WASM_opcode_ReturnOp(Context : PWASMProcessContext);
var
    cs, os: PWASMStack;
    ft, saved_top, return_ip: TWASMInt32;
    result_entry: TWASMStackEntry;
begin
    cs := Context^.ExecutionState.Control_Stack;
    os := Context^.ExecutionState.Operand_Stack;
    if cs^.Top = 0 then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;
    { Walk backwards, popping block frames until we find a call frame }
    while cs^.Top > 0 do begin
        ft := cs^.Entries[cs^.Top - 1].i32Value;
        if ft = CTRL_FRAME_CALL then begin
            { Found call frame - restore caller state }
            saved_top := cs^.Entries[cs^.Top - 2].i32Value;
            return_ip := cs^.Entries[cs^.Top - 3].i32Value;
            { Preserve return value }
            if os^.Top > TWASMUInt32(saved_top) then begin
                result_entry := os^.Entries[os^.Top - 1];
                os^.Top := TWASMUInt32(saved_top);
                os^.Entries[os^.Top] := result_entry;
                Inc(os^.Top);
            end else begin
                os^.Top := TWASMUInt32(saved_top);
            end;
            { Restore locals }
            Context^.ExecutionState.Locals := PWASMLocals(cs^.Entries[cs^.Top - 4].i64Value);
            Dec(cs^.Top, 4);
            Context^.ExecutionState.IP := TWASMUInt32(return_ip);
            exit;
        end else begin
            { Pop block frame }
            Dec(cs^.Top, 3);
        end;
    end;
    { No call frame found - top level return, stop execution }
    Context^.ExecutionState.Running := false;
end;

end.
