unit wasm.vm.opcode.memoryfill;

interface

uses wasm.types.context;

procedure _WASM_opcode_MemoryFillOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack, wasm.types.heap;

{ memory.fill: [d, val, n] -> []
  Fill n bytes of memory starting at offset d with byte value val }
procedure _WASM_opcode_MemoryFillOp(Context : PWASMProcessContext);
var
    n, val, d : TWASMInt32;
    i : TWASMUInt32;
begin
    { Skip memory index byte (must be 0x00) }
    Inc(Context^.ExecutionState.IP);

    { Pop operands: n, val, d }
    n := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    val := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
    d := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);

    if n = 0 then exit;

    for i := 0 to TWASMUInt32(n) - 1 do begin
        if not wasm.types.heap.write_uint8(TWASMUInt32(d) + i, Context^.ExecutionState.Memory, TWASMUInt8(val and $FF)) then begin
            Context^.ExecutionState.Running := false;
            exit;
        end;
    end;
end;

end.
