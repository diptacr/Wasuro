unit wasm.vm.opcode.i32const;

interface

uses wasm.types.context;

procedure _WASM_opcode_I32ConstOp(Context : PWASMProcessContext);

implementation

uses console, wasm.types.leb128, wasm.types.builtin, wasm.types.stack;

procedure _WASM_opcode_I32ConstOp(Context : PWASMProcessContext);
var
     bytesRead, value : TWASMInt32;

begin
     {$IFDEF DEBUG_OUTPUT}
     console.writestringln('[wasm.vm.opcodes.i32constop] I32ConstOp');
     {$ENDIF}
     Inc(Context^.ExecutionState.IP);
     bytesRead := read_leb128_to_uint32(@Context^.ExecutionState.Code[Context^.ExecutionState.IP], TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit), @Value);
     Inc(Context^.ExecutionState.IP, bytesRead);
     if Context^.ExecutionState.Operand_Stack^.Full then begin
            console.writestringln('[wasm.vm.opcodes.i32constop] I32ConstOp: Stack Overflow!');
            Context^.ExecutionState.Running := false;
     end else
          wasm.types.stack.pushi32(Context^.ExecutionState.Operand_Stack, Value);
end;

end.
