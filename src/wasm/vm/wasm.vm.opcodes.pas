unit wasm.vm.opcodes;

interface

uses
    console, leb128, lmemorymanager, wasm.types.builtin,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context,
    wasm.types.heap, wasm.types.stack, wasm.types.constants, wasm.vm.control;

procedure initializeOpcodeJumpTable(Table : PWASMOpcodeJumpTable);

implementation

procedure _WASM_opcode_UnreachableOp(Context : PWASMProcessContext);
begin
     console.writestringln('[wasm.vm.opcodes] Trap: unreachable executed!');
     Context^.ExecutionState.Running := false;
end;

procedure _WASM_opcode_NopOp(Context : PWASMProcessContext);
begin
     Inc(Context^.ExecutionState.IP);
end;

{ ===== Control Flow Opcodes ===== }

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

procedure _WASM_opcode_IfOp(Context : PWASMProcessContext);
var
    cond: TWASMInt32;
    end_ip, target_pos: TWASMUInt32;
begin
    Inc(Context^.ExecutionState.IP); { past opcode $04 }
    Inc(Context^.ExecutionState.IP); { past blocktype byte }
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

procedure _WASM_opcode_BrOp(Context : PWASMProcessContext);
var
    label_depth: TWASMUInt32;
    bytesRead: TWASMUInt8;
begin
    Inc(Context^.ExecutionState.IP); { past opcode $0C }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @label_depth);
    { do_branch sets IP; no need to advance past immediate }
    do_branch(Context, label_depth);
end;

procedure _WASM_opcode_BrIfOp(Context : PWASMProcessContext);
var
    label_depth: TWASMUInt32;
    bytesRead: TWASMUInt8;
    cond: TWASMInt32;
begin
    Inc(Context^.ExecutionState.IP); { past opcode $0D }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @label_depth);
    Inc(Context^.ExecutionState.IP, bytesRead); { past label depth }
    cond := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    if cond <> 0 then
        do_branch(Context, label_depth);
    { else: continue at current IP }
end;

procedure _WASM_opcode_BrTableOp(Context : PWASMProcessContext);
var
    count, idx, selected, dummy: TWASMUInt32;
    skip_count, i: TWASMUInt32;
    bytesRead: TWASMUInt8;
begin
    Inc(Context^.ExecutionState.IP); { past opcode $0E }
    { Read label count }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @count);
    Inc(Context^.ExecutionState.IP, bytesRead);
    { Pop index from operand stack }
    idx := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
    { Determine how many labels to skip to reach our target }
    if idx >= count then
        skip_count := count
    else
        skip_count := idx;
    { Skip labels we don't need }
    for i := 1 to skip_count do begin
        bytesRead := read_leb128_to_uint32(
            @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
            @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
            @dummy);
        Inc(Context^.ExecutionState.IP, bytesRead);
    end;
    { Read the selected label (or default if idx >= count) }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @selected);
    { Branch to selected depth }
    do_branch(Context, selected);
end;

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

procedure _WASM_opcode_CallOp(Context : PWASMProcessContext);
var
    func_idx, type_idx: TWASMUInt32;
    bytesRead: TWASMUInt8;
    func_type: PWASMType;
    code_entry: PWASMCodeEntry;
    param_count, decl_count, total_count: TWASMUInt32;
    new_locals: PWASMLocals;
    i, j: TWASMUInt32;
    return_ip, saved_top: TWASMUInt32;
    cs, os: PWASMStack;
begin
    cs := Context^.ExecutionState.Control_Stack;
    os := Context^.ExecutionState.Operand_Stack;

    Inc(Context^.ExecutionState.IP); { past opcode $10 }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        @Context^.ExecutionState.Code[Context^.ExecutionState.Limit],
        @func_idx);
    Inc(Context^.ExecutionState.IP, bytesRead);
    return_ip := Context^.ExecutionState.IP; { instruction after call }

    { Look up function metadata }
    type_idx   := Context^.Sections.FunctionSection^.Functions[func_idx].Index;
    func_type  := @Context^.Sections.TypeSection^.Types[type_idx];
    code_entry := @Context^.Sections.CodeSection^.Entries[func_idx];

    param_count := func_type^.ParamCount;
    decl_count  := code_entry^.Locals.LocalCount;
    total_count := param_count + decl_count;

    { Allocate new locals }
    new_locals := PWASMLocals(kalloc(sizeof(TWASMLocals)));
    new_locals^.LocalCount := total_count;
    new_locals^.TypeCount  := total_count;
    if total_count > 0 then
        new_locals^.Locals := PWASMValueEntry(kalloc(sizeof(TWASMValueEntry) * total_count))
    else
        new_locals^.Locals := nil;

    { Pop parameters from operand stack (reverse order into locals) }
    if param_count > 0 then begin
        for i := param_count downto 1 do begin
            j := i - 1;
            new_locals^.Locals[j].ValueType := func_type^.ParamTypes[j].ValueType;
            case func_type^.ParamTypes[j].ValueType of
                vti32: new_locals^.Locals[j].i32Value := wasm.types.stack.popi32(os);
                vti64: new_locals^.Locals[j].i64Value := wasm.types.stack.popi64(os);
                vtf32: new_locals^.Locals[j].f32Value := wasm.types.stack.popf32(os);
                vtf64: new_locals^.Locals[j].f64Value := wasm.types.stack.popf64(os);
            end;
        end;
    end;

    { Initialize declared locals to zero }
    if decl_count > 0 then begin
        for i := param_count to total_count - 1 do begin
            j := i - param_count;
            new_locals^.Locals[i].ValueType := code_entry^.Locals.Locals[j].ValueType;
            new_locals^.Locals[i].i64Value := 0;
        end;
    end;

    saved_top := os^.Top; { stack depth after popping args }

    { Push call frame (4 entries): saved_locals_ptr, return_ip, saved_top, marker }
    wasm.types.stack.pushi64(cs, TWASMInt64(Context^.ExecutionState.Locals));
    wasm.types.stack.pushi32(cs, TWASMInt32(return_ip));
    wasm.types.stack.pushi32(cs, TWASMInt32(saved_top));
    wasm.types.stack.pushi32(cs, CTRL_FRAME_CALL);

    { Push implicit function block frame }
    push_control_frame(cs, CTRL_FRAME_BLOCK,
                       TWASMInt32(code_entry^.CodeIndex + code_entry^.CodeLength),
                       TWASMInt32(os^.Top));

    { Switch to callee }
    Context^.ExecutionState.IP     := code_entry^.CodeIndex;
    Context^.ExecutionState.Locals := new_locals;
end;

procedure _WASM_opcode_CallIndirectOp(Context : PWASMProcessContext);
begin
    console.writestringln('[wasm.vm.opcodes] Trap: call_indirect requires table support!');
    Context^.ExecutionState.Running := false;
end;

procedure _WASM_opcode_DropOp(Context : PWASMProcessContext);
begin
     Inc(Context^.ExecutionState.IP);
     if Context^.ExecutionState.Operand_Stack^.Top > 0 then
        Dec(Context^.ExecutionState.Operand_Stack^.Top)
     else begin
        console.writestringln('[wasm.vm.opcodes.dropop] Stack underflow!');
        Context^.ExecutionState.Running := false;
     end;
end;

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

procedure _WASM_opcode_LocalGetOp(Context : PWASMProcessContext);
var idx : TWASMUInt32; bytesRead : TWASMUInt8; entry : PWASMValueEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Locals^.Locals[idx];
     case entry^.ValueType of
        vti32: wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, entry^.i32Value);
        vti64: wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, entry^.i64Value);
        vtf32: wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, entry^.f32Value);
        vtf64: wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, entry^.f64Value);
     else begin
        console.writestringln('[wasm.vm.opcodes.localget] Unknown local type!');
        Context^.ExecutionState.Running := false;
     end;
     end;
end;

procedure _WASM_opcode_LocalSetOp(Context : PWASMProcessContext);
var idx : TWASMUInt32; bytesRead : TWASMUInt8; entry : PWASMValueEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Locals^.Locals[idx];
     case entry^.ValueType of
        vti32: entry^.i32Value := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
        vti64: entry^.i64Value := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
        vtf32: entry^.f32Value := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
        vtf64: entry^.f64Value := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     else begin
        console.writestringln('[wasm.vm.opcodes.localset] Unknown local type!');
        Context^.ExecutionState.Running := false;
     end;
     end;
end;

procedure _WASM_opcode_LocalTeeOp(Context : PWASMProcessContext);
var idx : TWASMUInt32; bytesRead : TWASMUInt8; entry : PWASMValueEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Locals^.Locals[idx];
     { tee = set local but keep value on stack (peek then set) }
     case entry^.ValueType of
        vti32: entry^.i32Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].i32Value;
        vti64: entry^.i64Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].i64Value;
        vtf32: entry^.f32Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].f32Value;
        vtf64: entry^.f64Value := Context^.ExecutionState.Operand_Stack^.Entries[Context^.ExecutionState.Operand_Stack^.Top - 1].f64Value;
     else begin
        console.writestringln('[wasm.vm.opcodes.localtee] Unknown local type!');
        Context^.ExecutionState.Running := false;
     end;
     end;
end;

procedure _WASM_opcode_GlobalGetOp(Context : PWASMProcessContext);
var idx : TWASMUInt32; bytesRead : TWASMUInt8; entry : PWASMGlobalEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Globals^.Globals[idx];
     case entry^.ValueType of
        vti32: wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, entry^.Value.i32Value);
        vti64: wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, entry^.Value.i64Value);
        vtf32: wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, entry^.Value.f32Value);
        vtf64: wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, entry^.Value.f64Value);
     else begin
        console.writestringln('[wasm.vm.opcodes.globalget] Unknown global type!');
        Context^.ExecutionState.Running := false;
     end;
     end;
end;

procedure _WASM_opcode_GlobalSetOp(Context : PWASMProcessContext);
var idx : TWASMUInt32; bytesRead : TWASMUInt8; entry : PWASMGlobalEntry;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @idx);
     Inc(Context^.ExecutionState.IP, bytesRead);
     entry := @Context^.ExecutionState.Globals^.Globals[idx];
     if not entry^.Mutable then begin
        console.writestringln('[wasm.vm.opcodes.globalset] Trap: attempt to set immutable global!');
        Context^.ExecutionState.Running := false;
     end else begin
        case entry^.ValueType of
           vti32: entry^.Value.i32Value := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
           vti64: entry^.Value.i64Value := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
           vtf32: entry^.Value.f32Value := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
           vtf64: entry^.Value.f64Value := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
        else begin
           console.writestringln('[wasm.vm.opcodes.globalset] Unknown global type!');
           Context^.ExecutionState.Running := false;
        end;
        end;
     end;
end;

procedure _WASM_opcode_I32LoadOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint32(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.load out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(result_val));
end;

procedure _WASM_opcode_I64LoadOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint64(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(result_val));
end;

procedure _WASM_opcode_F32LoadOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint32(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: f32.load out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, TWASMPFloat(@result_val)^);
end;

procedure _WASM_opcode_F64LoadOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint64(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: f64.load out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, TWASMPDouble(@result_val)^);
end;

procedure _WASM_opcode_I32Load8SOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt8;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint8(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.load8_s out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(TWASMSInt8(result_val)));
end;

procedure _WASM_opcode_I32Load8UOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt8;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint8(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.load8_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(result_val));
end;

procedure _WASM_opcode_I32Load16SOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt16;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint16(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.load16_s out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(TWASMSInt16(result_val)));
end;

procedure _WASM_opcode_I32Load16UOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt16;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint16(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.load16_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(result_val));
end;

procedure _WASM_opcode_I64Load8SOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt8;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint8(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load8_s out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMSInt8(result_val)));
end;

procedure _WASM_opcode_I64Load8UOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt8;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint8(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load8_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(result_val));
end;

procedure _WASM_opcode_I64Load16SOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt16;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint16(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load16_s out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMSInt16(result_val)));
end;

procedure _WASM_opcode_I64Load16UOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt16;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint16(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load16_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(result_val));
end;

procedure _WASM_opcode_I64Load32SOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint32(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load32_s out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMInt32(result_val)));
end;

procedure _WASM_opcode_I64Load32UOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; result_val : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.read_uint32(addr, Context^.ExecutionState.Memory, @result_val) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.load32_u out of bounds!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(result_val));
end;

procedure _WASM_opcode_I32StoreOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint32(addr, Context^.ExecutionState.Memory, TWASMUInt32(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.store out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I64StoreOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint64(addr, Context^.ExecutionState.Memory, TWASMUInt64(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.store out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_F32StoreOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint32(addr, Context^.ExecutionState.Memory, TWASMPUInt32(@val)^) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: f32.store out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_F64StoreOp(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint64(addr, Context^.ExecutionState.Memory, TWASMPUInt64(@val)^) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: f64.store out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I32Store8Op(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint8(addr, Context^.ExecutionState.Memory, TWASMUInt8(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.store8 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I32Store16Op(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint16(addr, Context^.ExecutionState.Memory, TWASMUInt16(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.store16 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I64Store8Op(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint8(addr, Context^.ExecutionState.Memory, TWASMUInt8(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.store8 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I64Store16Op(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint16(addr, Context^.ExecutionState.Memory, TWASMUInt16(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.store16 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_I64Store32Op(Context : PWASMProcessContext);
var align_val, offset_val : TWASMUInt32; bytesRead : TWASMUInt8; addr : TWASMUInt32; val : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @align_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @offset_val);
     Inc(Context^.ExecutionState.IP, bytesRead);
     val := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     addr := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack)) + offset_val;
     if not wasm.types.heap.write_uint32(addr, Context^.ExecutionState.Memory, TWASMUInt32(val)) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.store32 out of bounds!');
        Context^.ExecutionState.Running := false;
     end;
end;

procedure _WASM_opcode_MemorySizeOp(Context : PWASMProcessContext);
var reserved : TWASMUInt32; bytesRead : TWASMUInt8;
begin
     Inc(Context^.ExecutionState.IP);
     { memory index immediate (reserved, must be 0) }
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @reserved);
     Inc(Context^.ExecutionState.IP, bytesRead);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(Context^.ExecutionState.Memory^.PageCount));
end;

procedure _WASM_opcode_MemoryGrowOp(Context : PWASMProcessContext);
var reserved : TWASMUInt32; bytesRead : TWASMUInt8; pages_to_grow, old_size : TWASMUInt32; i : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     { memory index immediate (reserved, must be 0) }
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @reserved);
     Inc(Context^.ExecutionState.IP, bytesRead);
     pages_to_grow := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     old_size := Context^.ExecutionState.Memory^.PageCount;
     if pages_to_grow > 0 then begin
        for i := 0 to pages_to_grow - 1 do begin
           if not wasm.types.heap.expand_heap(Context^.ExecutionState.Memory) then begin
              wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, -1);
              exit;
           end;
        end;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(old_size));
end;

procedure _WASM_opcode_I32ConstOp(Context : PWASMProcessContext);
var
     bytesRead, value : TWASMInt32;

begin
     console.writestringln('[wasm.vm.opcodes.i32constop] I32ConstOp');
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @Value);
     Inc(Context^.ExecutionState.IP, bytesRead);
     if Context^.ExecutionState.Operand_Stack^.Full then begin
            console.writestringln('[wasm.vm.opcodes.i32constop] I32ConstOp: Stack Overflow!');
            Context^.ExecutionState.Running := false;
     end else
          wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, Value);
end;

procedure _WASM_opcode_I64ConstOp(Context : PWASMProcessContext);
var
     bytesRead : TWASMUInt8;
     value : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint64(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @value);
     Inc(Context^.ExecutionState.IP, bytesRead);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(value));
end;

procedure _WASM_opcode_F32ConstOp(Context : PWASMProcessContext);
var
     value : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     value := TWASMPFloat(@Context^.ExecutionState.Code[Context^.ExecutionState.IP])^;
     Inc(Context^.ExecutionState.IP, 4);
     wasm.types.stack.pushf32(Context^.ExecutionState.Operand_Stack, value);
end;

procedure _WASM_opcode_F64ConstOp(Context : PWASMProcessContext);
var
     value : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     value := TWASMPDouble(@Context^.ExecutionState.Code[Context^.ExecutionState.IP])^;
     Inc(Context^.ExecutionState.IP, 8);
     wasm.types.stack.pushf64(Context^.ExecutionState.Operand_Stack, value);
end;

procedure _WASM_opcode_I32EqzOp(Context : PWASMProcessContext);
var a : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a = 0 then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32EqOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a = b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32NeOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a <> b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32LtSOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a < b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32LtUOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if TWASMUInt32(a) < TWASMUInt32(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32GtSOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a > b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32GtUOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if TWASMUInt32(a) > TWASMUInt32(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32LeSOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a <= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32LeUOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if TWASMUInt32(a) <= TWASMUInt32(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32GeSOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if a >= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32GeUOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if TWASMUInt32(a) >= TWASMUInt32(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64EqzOp(Context : PWASMProcessContext);
var a : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a = 0 then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64EqOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a = b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64NeOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a <> b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64LtSOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a < b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64LtUOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if TWASMUInt64(a) < TWASMUInt64(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64GtSOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a > b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64GtUOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if TWASMUInt64(a) > TWASMUInt64(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64LeSOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a <= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64LeUOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if TWASMUInt64(a) <= TWASMUInt64(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64GeSOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if a >= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I64GeUOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if TWASMUInt64(a) >= TWASMUInt64(b) then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32EqOp(Context : PWASMProcessContext);
var a, b : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a = b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32NeOp(Context : PWASMProcessContext);
var a, b : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a <> b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32LtOp(Context : PWASMProcessContext);
var a, b : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a < b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32GtOp(Context : PWASMProcessContext);
var a, b : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a > b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32LeOp(Context : PWASMProcessContext);
var a, b : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a <= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F32GeOp(Context : PWASMProcessContext);
var a, b : TWASMFloat;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
     if a >= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64EqOp(Context : PWASMProcessContext);
var a, b : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a = b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64NeOp(Context : PWASMProcessContext);
var a, b : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a <> b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64LtOp(Context : PWASMProcessContext);
var a, b : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a < b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64GtOp(Context : PWASMProcessContext);
var a, b : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a > b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64LeOp(Context : PWASMProcessContext);
var a, b : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a <= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_F64GeOp(Context : PWASMProcessContext);
var a, b : TWASMDouble;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
     if a >= b then
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 1)
     else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, 0);
end;

procedure _WASM_opcode_I32ClzOp(Context : PWASMProcessContext);
var a : TWASMUInt32; count : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     if a = 0 then count := 32
     else begin
        count := 0;
        while (a and $80000000) = 0 do begin
           Inc(count);
           a := a shl 1;
        end;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I32CtzOp(Context : PWASMProcessContext);
var a : TWASMUInt32; count : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     if a = 0 then count := 32
     else begin
        count := 0;
        while (a and 1) = 0 do begin
           Inc(count);
           a := a shr 1;
        end;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I32PopcntOp(Context : PWASMProcessContext);
var a : TWASMUInt32; count : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     count := 0;
     while a <> 0 do begin
        Inc(count, TWASMInt32(a and 1));
        a := a shr 1;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I32AddOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a + b);
end;

procedure _WASM_opcode_I32SubOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a - b);
end;

procedure _WASM_opcode_I32MulOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a * b);
end;

procedure _WASM_opcode_I32DivSOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.div_s division by zero!');
        Context^.ExecutionState.Running := false;
     end else if (a = TWASMInt32($80000000)) and (b = -1) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.div_s overflow!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a div b);
end;

procedure _WASM_opcode_I32DivUOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.div_u division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(TWASMUInt32(a) div TWASMUInt32(b)));
end;

procedure _WASM_opcode_I32RemSOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.rem_s division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a mod b);
end;

procedure _WASM_opcode_I32RemUOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i32.rem_u division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(TWASMUInt32(a) mod TWASMUInt32(b)));
end;

procedure _WASM_opcode_I32AndOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a and b);
end;

procedure _WASM_opcode_I32OrOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a or b);
end;

procedure _WASM_opcode_I32XorOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a xor b);
end;

procedure _WASM_opcode_I32ShlOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(TWASMUInt32(a) shl (TWASMUInt32(b) and 31)));
end;

procedure _WASM_opcode_I32ShrSOp(Context : PWASMProcessContext);
var a, b : TWASMInt32; shift : TWASMUInt32; res : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     shift := TWASMUInt32(b) and 31;
     res := TWASMUInt32(a) shr shift;
     if (a < 0) and (shift > 0) then
        res := res or (TWASMUInt32($FFFFFFFF) shl (32 - shift));
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(res));
end;

procedure _WASM_opcode_I32ShrUOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(TWASMUInt32(a) shr (TWASMUInt32(b) and 31)));
end;

procedure _WASM_opcode_I32RotlOp(Context : PWASMProcessContext);
var a : TWASMUInt32; b : TWASMUInt32; k : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     a := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     k := b and 31;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32((a shl k) or (a shr (32 - k))));
end;

procedure _WASM_opcode_I32RotrOp(Context : PWASMProcessContext);
var a : TWASMUInt32; b : TWASMUInt32; k : TWASMUInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     a := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     k := b and 31;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32((a shr k) or (a shl (32 - k))));
end;

procedure _WASM_opcode_I64ClzOp(Context : PWASMProcessContext);
var a : TWASMUInt64; count : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := TWASMUInt64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     if a = 0 then count := 64
     else begin
        count := 0;
        while (a and TWASMUInt64($8000000000000000)) = 0 do begin
           Inc(count);
           a := a shl 1;
        end;
     end;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I64CtzOp(Context : PWASMProcessContext);
var a : TWASMUInt64; count : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := TWASMUInt64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     if a = 0 then count := 64
     else begin
        count := 0;
        while (a and 1) = 0 do begin
           Inc(count);
           a := a shr 1;
        end;
     end;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I64PopcntOp(Context : PWASMProcessContext);
var a : TWASMUInt64; count : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     a := TWASMUInt64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     count := 0;
     while a <> 0 do begin
        Inc(count, TWASMInt64(a and 1));
        a := a shr 1;
     end;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, count);
end;

procedure _WASM_opcode_I64AddOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a + b);
end;

procedure _WASM_opcode_I64SubOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a - b);
end;

procedure _WASM_opcode_I64MulOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a * b);
end;

procedure _WASM_opcode_I64DivSOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.div_s division by zero!');
        Context^.ExecutionState.Running := false;
     end else if (a = TWASMInt64($8000000000000000)) and (b = -1) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.div_s overflow!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a div b);
end;

procedure _WASM_opcode_I64DivUOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.div_u division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMUInt64(a) div TWASMUInt64(b)));
end;

procedure _WASM_opcode_I64RemSOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.rem_s division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a mod b);
end;

procedure _WASM_opcode_I64RemUOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.rem_u division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMUInt64(a) mod TWASMUInt64(b)));
end;

procedure _WASM_opcode_I64AndOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a and b);
end;

procedure _WASM_opcode_I64OrOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a or b);
end;

procedure _WASM_opcode_I64XorOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a xor b);
end;

procedure _WASM_opcode_I64ShlOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMUInt64(a) shl (TWASMUInt64(b) and 63)));
end;

procedure _WASM_opcode_I64ShrSOp(Context : PWASMProcessContext);
var a, b : TWASMInt64; shift : TWASMUInt64; res : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     shift := TWASMUInt64(b) and 63;
     res := TWASMUInt64(a) shr shift;
     if (a < 0) and (shift > 0) then
        res := res or (TWASMUInt64($FFFFFFFFFFFFFFFF) shl (64 - shift));
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(res));
end;

procedure _WASM_opcode_I64ShrUOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMUInt64(a) shr (TWASMUInt64(b) and 63)));
end;

procedure _WASM_opcode_I64RotlOp(Context : PWASMProcessContext);
var a, b, k : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := TWASMUInt64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     a := TWASMUInt64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     k := b and 63;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64((a shl k) or (a shr (64 - k))));
end;

procedure _WASM_opcode_I64RotrOp(Context : PWASMProcessContext);
var a, b, k : TWASMUInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := TWASMUInt64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     a := TWASMUInt64(wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack));
     k := b and 63;
     wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64((a shr k) or (a shl (64 - k))));
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

