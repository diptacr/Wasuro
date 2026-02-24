unit wasm.vm.control;

interface

uses
    wasm.types.builtin, wasm.types.values, wasm.types.stack, wasm.types.context;

{ Push a block/loop/if control frame (3 entries) onto the control stack.
  Layout (bottom to top): target_ip, saved_stack_top, frame_type }
procedure push_control_frame(cs: PWASMStack; frame_type: TWASMInt32;
                             target_ip: TWASMInt32; saved_stack_top: TWASMInt32);

{ Scan forward through bytecode starting at ip (inside a block at depth 1).
  If stop_at_else is true, returns the IP of the first else ($05) at depth 1.
  Otherwise returns the IP of the matching end ($0B) at depth 0.
  For valid WASM this always terminates. }
function scan_forward(code: TWASMPUInt8; ip: TWASMUInt32; limit: TWASMUInt32;
                      stop_at_else: TWASMBoolean): TWASMUInt32;

{ Execute a branch to the specified label depth. Handles stack unwinding
  and control frame removal. For loops, re-enters the loop body. }
procedure do_branch(Context: PWASMProcessContext; label_depth: TWASMUInt32);

implementation

uses
    leb128, wasm.types.constants;

procedure push_control_frame(cs: PWASMStack; frame_type: TWASMInt32;
                             target_ip: TWASMInt32; saved_stack_top: TWASMInt32);
begin
    wasm.types.stack.pushi32(cs, target_ip);
    wasm.types.stack.pushi32(cs, saved_stack_top);
    wasm.types.stack.pushi32(cs, frame_type);
end;

function scan_forward(code: TWASMPUInt8; ip: TWASMUInt32; limit: TWASMUInt32;
                      stop_at_else: TWASMBoolean): TWASMUInt32;
var
    depth: TWASMUInt32;
    op: TWASMUInt8;
    dummy32: TWASMUInt32;
    dummy64: TWASMUInt64;
    bytesRead: TWASMUInt8;
    count, i: TWASMUInt32;
begin
    depth := 1;
    while (ip < limit) and (depth > 0) do begin
        op := code[ip];
        Inc(ip); { past opcode }
        case op of
            $02, $03, $04: begin { block, loop, if: +1 depth, skip blocktype }
                Inc(depth);
                Inc(ip);
            end;
            $05: begin { else }
                if stop_at_else and (depth = 1) then begin
                    scan_forward := ip - 1;
                    exit;
                end;
            end;
            $0B: begin { end }
                Dec(depth);
                if depth = 0 then begin
                    scan_forward := ip - 1;
                    exit;
                end;
            end;
            $0C, $0D: begin { br, br_if: 1 LEB128 }
                bytesRead := read_leb128_to_uint32(@code[ip], @code[limit], @dummy32);
                Inc(ip, bytesRead);
            end;
            $0E: begin { br_table: count LEB128, then count+1 LEB128 labels }
                bytesRead := read_leb128_to_uint32(@code[ip], @code[limit], @count);
                Inc(ip, bytesRead);
                for i := 0 to count do begin
                    bytesRead := read_leb128_to_uint32(@code[ip], @code[limit], @dummy32);
                    Inc(ip, bytesRead);
                end;
            end;
            $10: begin { call: 1 LEB128 }
                bytesRead := read_leb128_to_uint32(@code[ip], @code[limit], @dummy32);
                Inc(ip, bytesRead);
            end;
            $11: begin { call_indirect: 1 LEB128 + 1 byte }
                bytesRead := read_leb128_to_uint32(@code[ip], @code[limit], @dummy32);
                Inc(ip, bytesRead);
                Inc(ip);
            end;
            $20, $21, $22, $23, $24: begin { local/global ops: 1 LEB128 }
                bytesRead := read_leb128_to_uint32(@code[ip], @code[limit], @dummy32);
                Inc(ip, bytesRead);
            end;
            $28, $29, $2A, $2B, $2C, $2D, $2E, $2F,
            $30, $31, $32, $33, $34, $35,
            $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E: begin { load/store: 2 LEB128 }
                bytesRead := read_leb128_to_uint32(@code[ip], @code[limit], @dummy32);
                Inc(ip, bytesRead);
                bytesRead := read_leb128_to_uint32(@code[ip], @code[limit], @dummy32);
                Inc(ip, bytesRead);
            end;
            $3F, $40: begin { memory.size, memory.grow: 1 byte }
                Inc(ip);
            end;
            $41: begin { i32.const: 1 signed LEB128 }
                bytesRead := read_leb128_to_uint32(@code[ip], @code[limit], @dummy32);
                Inc(ip, bytesRead);
            end;
            $42: begin { i64.const: 1 signed LEB128 }
                bytesRead := read_leb128_to_uint64(@code[ip], @code[limit], @dummy64);
                Inc(ip, bytesRead);
            end;
            $43: Inc(ip, 4); { f32.const: 4 bytes }
            $44: Inc(ip, 8); { f64.const: 8 bytes }
            { All other opcodes ($00,$01,$0F,$1A,$1B,$45..$C4): no immediates }
        end;
    end;
    { Fallback for malformed bytecode }
    scan_forward := ip;
end;

procedure do_branch(Context: PWASMProcessContext; label_depth: TWASMUInt32);
var
    cs, os: PWASMStack;
    pos, i: TWASMUInt32;
    ft: TWASMInt32;
    target_ip, saved_top, frame_type: TWASMInt32;
    result_entry: TWASMStackEntry;
begin
    cs := Context^.ExecutionState.Control_Stack;
    os := Context^.ExecutionState.Operand_Stack;

    { Walk back through control stack to find the target frame }
    pos := cs^.Top;
    for i := 0 to label_depth do begin
        Dec(pos); { frame_type entry (top of frame) }
        ft := cs^.Entries[pos].i32Value;
        if ft = CTRL_FRAME_CALL then
            Dec(pos, 3) { call frame = 4 entries total, already read 1 }
        else
            Dec(pos, 2); { block frame = 3 entries total, already read 1 }
    end;

    { pos is now at the base of the target frame }
    target_ip  := cs^.Entries[pos].i32Value;
    saved_top  := cs^.Entries[pos + 1].i32Value;
    frame_type := cs^.Entries[pos + 2].i32Value;

    if frame_type = CTRL_FRAME_LOOP then begin
        { Loop: restore operand stack, keep loop frame, jump to start }
        os^.Top := TWASMUInt32(saved_top);
        cs^.Top := pos + 3; { keep the loop frame, pop everything above }
    end else begin
        { Block/If: preserve return value if any, pop frame }
        if os^.Top > TWASMUInt32(saved_top) then begin
            result_entry := os^.Entries[os^.Top - 1];
            os^.Top := TWASMUInt32(saved_top);
            os^.Entries[os^.Top] := result_entry;
            Inc(os^.Top);
        end else begin
            os^.Top := TWASMUInt32(saved_top);
        end;
        cs^.Top := pos; { remove the target frame and everything above it }
    end;

    Context^.ExecutionState.IP := TWASMUInt32(target_ip);
end;

end.
