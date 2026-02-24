unit wasm.vm.opcode.endop;

interface

uses wasm.types.context;

procedure _WASM_opcode_EndOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.values, wasm.types.constants;

procedure _WASM_opcode_EndOp(Context : PWASMProcessContext);
var
    cs, os: PWASMStack;
    saved_top, return_ip: TWASMInt32;
    result_entry: TWASMStackEntry;
begin
    cs := Context^.ExecutionState.Control_Stack;
    os := Context^.ExecutionState.Operand_Stack;

    { No control frame: end of top-level code }
    if cs^.Top = 0 then begin
        Context^.ExecutionState.Running := false;
        exit;
    end;

    { Read the top control frame }
    saved_top := cs^.Entries[cs^.Top - 2].i32Value;

    { Preserve block result value }
    if os^.Top > TWASMUInt32(saved_top) then begin
        result_entry := os^.Entries[os^.Top - 1];
        os^.Top := TWASMUInt32(saved_top);
        os^.Entries[os^.Top] := result_entry;
        Inc(os^.Top);
    end else begin
        os^.Top := TWASMUInt32(saved_top);
    end;

    { Pop the block frame }
    Dec(cs^.Top, 3);

    { Check if a call frame is now on top (function return) }
    if (cs^.Top >= 4) and (cs^.Entries[cs^.Top - 1].i32Value = CTRL_FRAME_CALL) then begin
        saved_top := cs^.Entries[cs^.Top - 2].i32Value;
        return_ip := cs^.Entries[cs^.Top - 3].i32Value;
        { Move return values to caller stack level }
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
        { Pop call frame }
        Dec(cs^.Top, 4);
        { Resume caller }
        Context^.ExecutionState.IP := TWASMUInt32(return_ip);
        exit;
    end;

    { Normal block/loop/if end: advance past end byte }
    Inc(Context^.ExecutionState.IP);
end;

end.
