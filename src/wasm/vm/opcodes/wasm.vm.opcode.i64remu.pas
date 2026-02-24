unit wasm.vm.opcode.i64remu;

interface

uses wasm.types.context;

procedure _WASM_opcode_I64RemUOp(Context : PWASMProcessContext);

implementation

uses console, wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I64RemUOp(Context : PWASMProcessContext);
var a, b : TWASMInt64;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi64(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        console.writestringln('[wasm.vm.opcodes] Trap: i64.rem_u division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi64(Context^.ExecutionState.Operand_Stack, TWASMInt64(TWASMUInt64(a) mod TWASMUInt64(b)));
end;

end.
