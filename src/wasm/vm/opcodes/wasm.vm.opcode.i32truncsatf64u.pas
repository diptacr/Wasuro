unit wasm.vm.opcode.i32truncsatf64u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32TruncSatF64UOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32TruncSatF64UOp(Context : PWASMProcessContext);
var a : TWASMDouble;
    bits : TWASMUInt64;
    r : TWASMUInt32;
begin
    a := wasm.types.stack.popf64(Context^.ExecutionState.Operand_Stack);
    bits := TWASMPUInt64(@a)^;
    if (((bits and $7FF0000000000000) = $7FF0000000000000) and ((bits and $000FFFFFFFFFFFFF) <> 0)) or (a < 0.0) then
        r := 0
    else if a >= 4294967296.0 then
        r := $FFFFFFFF
    else
        r := TWASMUInt32(Trunc(a));
    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(r));
end;

end.
