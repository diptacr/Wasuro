unit wasm.types.leb128;

interface

uses
    wasm.types.builtin;

function read_leb128_to_uint64(buf : TWASMPUInt8; buf_end  : TWASMPUInt8; res  : TWASMPUInt64) : TWASMUInt8;
function read_leb128_to_uint32(buf : TWASMPUInt8;  buf_end : TWASMPUInt8; res : TWASMPUInt32)  : TWASMUInt8;

implementation

function read_leb128_to_uint64(buf: TWASMPUInt8; buf_end: TWASMPUInt8; res: TWASMPUInt64): TWASMUInt8;
var
   ptr : TWASMPUInt8;
   shift : TWASMUInt32;
   localResult : TWASMUInt64;
   currentByte : TWASMUInt8;

begin
     ptr:= buf;
     shift:= 0;
     localResult:= 0;
     while (true) do begin
           if (ptr >= buf_end) then begin
              read_leb128_to_uint64:= 0;
              exit;
           end;
           currentByte:= ptr^;
           inc(ptr);
           localResult:= localResult or TWASMUInt64(currentByte and $7F) SHL Shift;
           if ((currentByte AND $80) = 0) then break;
           Inc(Shift, 7);
     end;
     res^:= localResult;
     read_leb128_to_uint64:= TWASMUInt8(ptr - buf);
end;

function read_leb128_to_uint32(buf: TWASMPUInt8; buf_end: TWASMPUInt8; res: TWASMPUInt32): TWASMUInt8;
var
   ptr : TWASMPUInt8;
   shift : TWASMUInt32;
   localResult : TWASMUInt32;
   currentByte : TWASMUInt8;

begin
     ptr:= buf;
     shift:= 0;
     localResult:= 0;
     while (true) do begin
           if (ptr >= buf_end) then begin
              read_leb128_to_uint32:= 0;
              exit;
           end;
           currentByte:= ptr^;
           inc(ptr);
           localResult:= localResult or TWASMUInt64(currentByte and $7F) SHL Shift;
           if ((currentByte AND $80) = 0) then break;
           Inc(Shift, 7);
     end;
     res^:= localResult;
     read_leb128_to_uint32:= TWASMUInt8(ptr - buf);
end;

end.
