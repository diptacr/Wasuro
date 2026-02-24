unit wasm.vm.opcode.i64popcnt;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64PopcntOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

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

end.
