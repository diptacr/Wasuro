unit wasm.vm.opcode.i32truncsatf32u;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32TruncSatF32UOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32TruncSatF32UOp(Context : PWASMProcessContext);
var a : TWASMFloat;
    bits : TWASMUInt32;
    r : TWASMUInt32;
begin
    a := wasm.types.stack.popf32(Context^.ExecutionState.Operand_Stack);
    bits := TWASMPUInt32(@a)^;
    if (((bits and $7F800000) = $7F800000) and ((bits and $007FFFFF) <> 0)) or (a < 0.0) then
        r := 0
    else if a >= 4294967296.0 then
        r := $FFFFFFFF
    else
        r := TWASMUInt32(Trunc(a));
    wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, TWASMInt32(r));
end;

end.
