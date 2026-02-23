unit leb128;

interface

uses
    types;

function read_leb128_to_uint64(buf : puint8; buf_end  : puint8; res  : puint64) : uint8;
function read_leb128_to_uint32(buf : puint8;  buf_end : puint8; res : puint32)  : uint8;

implementation

function read_leb128_to_uint64(buf: puint8; buf_end: puint8; res: puint64): uint8;
var
   ptr : puint8;
   shift : uint32;
   localResult : uint64;
   currentByte : uint8;

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
           localResult:= localResult or uint64(currentByte and $7F) SHL Shift;
           if ((currentByte AND $80) = 0) then break;
           Inc(Shift, 7);
     end;
     res^:= localResult;
     read_leb128_to_uint64:= uint8(ptr - buf);
end;

function read_leb128_to_uint32(buf: puint8; buf_end: puint8; res: puint32): uint8;
var
   ptr : puint8;
   shift : uint32;
   localResult : uint32;
   currentByte : uint8;

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
           localResult:= localResult or uint64(currentByte and $7F) SHL Shift;
           if ((currentByte AND $80) = 0) then break;
           Inc(Shift, 7);
     end;
     res^:= localResult;
     read_leb128_to_uint32:= uint8(ptr - buf);
end;

end.

