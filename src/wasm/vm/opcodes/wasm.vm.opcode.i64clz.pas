unit wasm.vm.opcode.i64clz;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64ClzOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

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

end.
