unit wasm.vm.opcode.i32shrs;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32ShrSOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

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

end.
