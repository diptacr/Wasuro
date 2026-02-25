unit wasm.vm.opcode.ifop;

interface

uses wasm.types.context;

procedure _WASM_opcode_IfOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack, wasm.types.constants, wasm.vm.control, wasm.types.leb128;

procedure _WASM_opcode_IfOp(Context : PWASMProcessContext);
var
    cond: TWASMInt32;
    end_ip, target_pos: TWASMUInt32;
    dummy: TWASMUInt32;
    bytesRead: TWASMUInt8;
begin
    Inc(Context^.ExecutionState.IP); { past opcode $04 }
    { Skip blocktype (s33 LEB128) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @dummy);
    Inc(Context^.ExecutionState.IP, bytesRead);
    cond := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    if cond <> 0 then begin
        { Condition true: enter if-true body }
        end_ip := scan_forward(Context^.ExecutionState.Code,
                               Context^.ExecutionState.IP,
                               Context^.ExecutionState.Limit, false);
        push_control_frame(Context^.ExecutionState.Control_Stack,
                           CTRL_FRAME_IF,
                           TWASMInt32(end_ip + 1),
                           TWASMInt32(Context^.ExecutionState.Operand_Stack^.Top));
    end else begin
        { Condition false: find else or end }
        target_pos := scan_forward(Context^.ExecutionState.Code,
                                   Context^.ExecutionState.IP,
                                   Context^.ExecutionState.Limit, true);
        if Context^.ExecutionState.Code[target_pos] = $05 then begin
            { Has else body: find end after the else, push frame, enter else }
            end_ip := scan_forward(Context^.ExecutionState.Code,
                                   target_pos + 1,
                                   Context^.ExecutionState.Limit, false);
            push_control_frame(Context^.ExecutionState.Control_Stack,
                               CTRL_FRAME_IF,
                               TWASMInt32(end_ip + 1),
                               TWASMInt32(Context^.ExecutionState.Operand_Stack^.Top));
            Context^.ExecutionState.IP := target_pos + 1;
        end else begin
            { No else: skip entire if construct }
            Context^.ExecutionState.IP := target_pos + 1;
        end;
    end;
end;

end.
