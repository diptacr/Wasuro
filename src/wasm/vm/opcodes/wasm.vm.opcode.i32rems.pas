unit wasm.vm.opcode.i32rems;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32RemSOp(Context : PWASMProcessContext);

implementation

uses wasm.vm.io, wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32RemSOp(Context : PWASMProcessContext);
var a, b : TWASMInt32;
begin
     Inc(Context^.ExecutionState.IP);
     b := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     a := wasm.types.stack.popi32(Context^.ExecutionState.Operand_Stack);
     if b = 0 then begin
        wasm.vm.io.writestringln('[wasm.vm.opcodes] Trap: i32.rem_s division by zero!');
        Context^.ExecutionState.Running := false;
     end else
        wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, a mod b);
end;

end.
