unit wasm.vm.opcode.block;

interface

uses wasm.types.context;

procedure _WASM_opcode_BlockOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.constants, wasm.vm.control;

procedure _WASM_opcode_BlockOp(Context : PWASMProcessContext);
var
    end_ip: TWASMUInt32;
begin
    Inc(Context^.ExecutionState.IP); { past opcode $02 }
    Inc(Context^.ExecutionState.IP); { past blocktype byte }
    { Find the matching end byte }
    end_ip := scan_forward(Context^.ExecutionState.Code,
                           Context^.ExecutionState.IP,
                           Context^.ExecutionState.Limit, false);
    { Push block frame: br target = past the end byte }
    push_control_frame(Context^.ExecutionState.Control_Stack,
                       CTRL_FRAME_BLOCK,
                       TWASMInt32(end_ip + 1),
                       TWASMInt32(Context^.ExecutionState.Operand_Stack^.Top));
end;

end.
