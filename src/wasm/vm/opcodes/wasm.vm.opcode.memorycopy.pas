unit wasm.vm.opcode.memorycopy;

interface

uses wasm.types.context;

procedure _WASM_opcode_MemoryCopyOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack, wasm.types.heap;

{ memory.copy: [d, s, n] -> []
  Copy n bytes from memory offset s to memory offset d.
  Handles overlapping regions correctly. }
procedure _WASM_opcode_MemoryCopyOp(Context : PWASMProcessContext);
var
    n, s, d : TWASMInt32;
    i : TWASMUInt32;
    b : TWASMUInt8;
begin
    { Skip 2 memory index bytes (both must be 0x00) }
    Inc(Context^.ExecutionState.IP, 2);

    { Pop operands: n, s, d }
    n := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    s := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    d := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);

    if n = 0 then exit;

    if TWASMUInt32(d) <= TWASMUInt32(s) then begin
        { Forward copy }
        for i := 0 to TWASMUInt32(n) - 1 do begin
            if not wasm.types.heap.read_uint8(TWASMUInt32(s) + i, Context^.ExecutionState.Memory, @b) then begin
                Context^.ExecutionState.Running := false;
                exit;
            end;
            if not wasm.types.heap.write_uint8(TWASMUInt32(d) + i, Context^.ExecutionState.Memory, b) then begin
                Context^.ExecutionState.Running := false;
                exit;
            end;
        end;
    end else begin
        { Backward copy (overlapping, dst > src) }
        for i := TWASMUInt32(n) downto 1 do begin
            if not wasm.types.heap.read_uint8(TWASMUInt32(s) + i - 1, Context^.ExecutionState.Memory, @b) then begin
                Context^.ExecutionState.Running := false;
                exit;
            end;
            if not wasm.types.heap.write_uint8(TWASMUInt32(d) + i - 1, Context^.ExecutionState.Memory, b) then begin
                Context^.ExecutionState.Running := false;
                exit;
            end;
        end;
    end;
end;

end.
