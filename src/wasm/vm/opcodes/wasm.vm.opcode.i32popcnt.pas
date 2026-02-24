unit wasm.vm.opcode.i32popcnt;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32PopcntOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

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

end.
