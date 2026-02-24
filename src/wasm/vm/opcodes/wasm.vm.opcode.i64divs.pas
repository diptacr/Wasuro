unit wasm.vm.opcode.i64divs;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64DivSOp(Context : PWASMProcessContext);

implementation

uses console, wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64DivSOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.div_s division by zero!');
        Context^.ExecutionState.Running := false;
     end else if (a = TWASMInt64($8000000000000000)) and (b = -1) then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.div_s overflow!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, a div b);
end;

end.
