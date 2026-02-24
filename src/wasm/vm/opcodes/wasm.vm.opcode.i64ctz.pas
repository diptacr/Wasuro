unit wasm.vm.opcode.i64ctz;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64CtzOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

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

end.
