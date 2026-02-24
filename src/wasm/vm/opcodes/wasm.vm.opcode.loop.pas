unit wasm.vm.opcode.loop;

interface

uses wasm.types.context;

procedure _WASM_opcode_LoopOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.constants, wasm.vm.control;

procedure _WASM_opcode_LoopOp(Context : PWASMProcessContext);
var
    loop_start: TWASMUInt32;
begin
    Inc(Context^.ExecutionState.IP); { past opcode $03 }
    Inc(Context^.ExecutionState.IP); { past blocktype byte }
    loop_start := Context^.ExecutionState.IP; { first instruction of loop body }
    { Push loop frame: br target = loop start (re-enter loop) }
    push_control_frame(Context^.ExecutionState.Control_Stack,
                       CTRL_FRAME_LOOP,
                       TWASMInt32(loop_start),
                       TWASMInt32(Context^.ExecutionState.Operand_Stack^.Top));
end;

end.
