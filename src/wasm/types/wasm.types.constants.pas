unit wasm.types.constants;

interface

uses
    wasm.types.builtin;

const
    { The magic number at the start of a WASM binary file (0x00 0x61 0x73 0x6D) }
     WASM_HDR_MAGIC = $6D736100;

const
    { Control frame type markers used on the control stack.
      Block frames use 3 entries: target_ip, saved_stack_top, frame_type.
      Call frames use 4 entries: saved_locals_ptr (i64), return_ip, saved_stack_top, frame_type. }
    CTRL_FRAME_BLOCK : TWASMInt32 = 0;
    CTRL_FRAME_LOOP  : TWASMInt32 = 1;
    CTRL_FRAME_IF    : TWASMInt32 = 2;
    CTRL_FRAME_CALL  : TWASMInt32 = 3;

implementation

end.
