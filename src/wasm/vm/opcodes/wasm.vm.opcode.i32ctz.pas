unit wasm.vm.opcode.i32ctz;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32CtzOp(Context : PWASMProcessContext);

implementation

uses wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32CtzOp(Context : PWASMProcessContext);
var a : TWASMUInt32; count : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     a := TWASMUInt32(wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack));
     if a = 0 then count := 32
     else begin
        count := 0;
        while (a and 1) = 0 do begin
           Inc(count);
           a := a shr 1;
        end;
     end;
     wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, count);
end;

end.
