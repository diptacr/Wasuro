unit wasm.vm.opcode.i64shrs;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64ShrSOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

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

end.
