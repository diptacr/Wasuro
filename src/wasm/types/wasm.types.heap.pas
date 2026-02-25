unit wasm.types.heap;

interface

uses
    wasm.types.builtin, lmemorymanager, wasm.types.leb128;

const
    PAGE_SIZE = $10000; // 64k

type
    PWasmPage = TWASMPUInt8;

    PWasmPages = ^PWasmPage;

    PWasmHeap = ^TWasmHeap;
    TWasmHeap = record
        Memory    : PWasmPages;
        PageCount : TWASMUInt32;
    end;

function new_heap() : PWasmHeap;
function expand_heap(Heap : PWasmHeap) : TWASMBoolean;

function read_uint8(location : TWASMUInt32; heap : PWasmHeap; ret : TWASMPUInt8) : TWASMBoolean;
function read_uint16(location : TWASMUInt32; heap : PWasmHeap; ret : TWASMPUInt16) : TWASMBoolean;
function read_uint32(location : TWASMUInt32; heap : PWasmHeap; ret : TWASMPUInt32) : TWASMBoolean;
function read_uint64(location : TWASMUInt32; heap : PWasmHeap; ret : TWASMPUInt64) : TWASMBoolean;
function read_leb_uint32(location : TWASMUInt32; heap : PWasmHeap; ret : TWASMPUInt32) : TWASMBoolean;

function write_uint8(location : TWASMUInt32; heap : PWasmHeap; value : TWASMUInt8) : TWASMBoolean;
function write_uint16(location : TWASMUInt32; heap : PWasmHeap; value : TWASMUInt16) : TWASMBoolean;
function write_uint32(location : TWASMUInt32; heap : PWasmHeap; value : TWASMUInt32) : TWASMBoolean;
function write_uint64(location : TWASMUInt32; heap : PWasmHeap; value : TWASMUInt64) : TWASMBoolean;

{ Get a native pointer to a location in linear memory.
  Only valid if the range [location..location+len-1] lies within a single page.
  Returns nil if out of bounds. }
function get_ptr(location : TWASMUInt32; heap : PWasmHeap) : TWASMPUInt8;

implementation

function get_page_index(location : TWASMUInt32) : TWASMUInt32;
begin
    get_page_index:= location div PAGE_SIZE;
end;

function get_page_offset(location : TWASMUInt32) : TWASMUInt32;
begin
    get_page_offset:= location mod PAGE_SIZE;
end;

function new_heap() : PWasmHeap;
var
    Heap : PWasmHeap;

begin
     Heap:= PWasmHeap(kalloc(sizeof(TWasmHeap)));
     Heap^.PageCount:= 1;
     Heap^.Memory:= PWasmPages(Kalloc(sizeof(PWasmPage) * Heap^.PageCount));
     Heap^.Memory[0]:= PWasmPage(Kalloc(PAGE_SIZE));
     new_heap:= Heap;
end;

function expand_heap(Heap : PWasmHeap) : TWASMBoolean;
var
    NewMemory : PWasmPages;
    i : TWASMUInt32;

begin
    NewMemory:= PWasmPages(Kalloc(sizeof(PWasmPage) * (Heap^.PageCount + 1)));
    for i:=0 to Heap^.PageCount-1 do begin
        NewMemory[i]:= Heap^.Memory[i];
    end;
    NewMemory[Heap^.PageCount]:= PWasmPage(Kalloc(PAGE_SIZE));
    kfree(TWASMVoid(Heap^.Memory));
    Heap^.Memory:= NewMemory;
    inc(Heap^.PageCount);
    expand_heap:= true;
end;

function address_voids_bounds(location : TWASMUInt32; length : TWASMUInt32; heap : PWasmHeap) : TWASMBoolean;
begin
    if (location >= heap^.PageCount * PAGE_SIZE) or ((location + (length - 1)) >= heap^.PageCount * PAGE_SIZE) then begin
        address_voids_bounds:= true;
    end else begin
        address_voids_bounds:= false;
    end;
end;

function address_crosses_bounds(location : TWASMUInt32; length : TWASMUInt32) : TWASMBoolean;
begin
    if get_page_index(location) <> get_page_index(location + (length - 1)) then begin
        address_crosses_bounds:= true;
    end else begin
        address_crosses_bounds:= false;
    end;
end;

function safe_read_across_bounds(location : TWASMUInt32; length : TWASMUInt32; heap : PWasmHeap) : PWasmPage;
var
    Page1Offset : TWASMUInt32;
    Page1Page : TWASMUInt32;
    Page1BytesToRead : TWASMUInt32;

    Page2Page : TWASMUInt32;
    Page2BytesToRead : TWASMUInt32;

    res : PWasmPage;
    i : TWASMUInt32;

begin
      res:= PWasmPage(kalloc(length));
      
      Page1Offset:= get_page_offset(location);
      Page1Page:= get_page_index(location);
      Page1BytesToRead:= PAGE_SIZE - Page1Offset;
      
      Page2Page:= get_page_index(location + length);
      Page2BytesToRead:= length - Page1BytesToRead;

      for i:=0 to Page1BytesToRead-1 do begin
          res[i]:= heap^.Memory[Page1Page][Page1Offset + i];
      end;
      for i:=0 to Page2BytesToRead-1 do begin
          res[Page1BytesToRead + i]:= heap^.Memory[Page2Page][i];
      end;

      safe_read_across_bounds:= res;
end;

function safe_write_across_bounds(location : TWASMUInt32; length : TWASMUInt32; heap : PWasmHeap; value : PWasmPage) : TWASMBoolean;
var
    Page1Offset : TWASMUInt32;
    Page1Page : TWASMUInt32;
    Page1BytesToWrite : TWASMUInt32;

    Page2Page : TWASMUInt32;
    Page2BytesToWrite : TWASMUInt32;

    i : TWASMUInt32;

begin
    Page1Offset:= get_page_offset(location);
    Page1Page:= get_page_index(location);
    Page1BytesToWrite:= PAGE_SIZE - Page1Offset;
    
    Page2Page:= get_page_index(location + length);
    Page2BytesToWrite:= length - Page1BytesToWrite;

    for i:=0 to Page1BytesToWrite-1 do begin
        heap^.Memory[Page1Page][Page1Offset + i]:= value[i];
    end;
    for i:=0 to Page2BytesToWrite-1 do begin
        heap^.Memory[Page2Page][i]:= value[Page1BytesToWrite + i];
    end;

    safe_write_across_bounds:= true;
end;


function read_uint8(location : TWASMUInt32; heap : PWasmHeap; ret : TWASMPUInt8) : TWASMBoolean;
var
    PageIndex : TWASMUInt32;
    PageOffset : TWASMUInt32;

begin
    if address_voids_bounds(location, sizeof(TWASMUInt8), heap) then begin
        read_uint8:= false;
    end else begin
        PageIndex:= get_page_index(location);
        PageOffset:= get_page_offset(location);
        ret^:= heap^.Memory[PageIndex][PageOffset];
        read_uint8:= true;
    end;
end;

function read_uint16(location : TWASMUInt32; heap : PWasmHeap; ret : TWASMPUInt16) : TWASMBoolean;
var
    PageIndex : TWASMUInt32;
    PageOffset : TWASMUInt32;
    Pos : TWASMPUInt16;

begin
    if address_voids_bounds(location, sizeof(TWASMUInt16), heap) then begin
        read_uint16:= false;
    end else begin
        if address_crosses_bounds(location, sizeof(TWASMUInt16)) then begin
            Pos:= TWASMPUInt16(safe_read_across_bounds(location, sizeof(TWASMUInt16), heap));
            ret^:= Pos^;
            kfree(TWASMVoid(Pos));
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= TWASMPUInt16(heap^.Memory[PageIndex] + PageOffset);
            ret^:= Pos^;
        end;
        read_uint16:= true;
    end;
end;

function read_uint32(location : TWASMUInt32; heap : PWasmHeap; ret : TWASMPUInt32) : TWASMBoolean;
var
    PageIndex : TWASMUInt32;
    PageOffset : TWASMUInt32;
    Pos : TWASMPUInt32;

begin
    if address_voids_bounds(location, sizeof(TWASMUInt32), heap) then begin
        read_uint32:= false;
    end else begin
        if address_crosses_bounds(location, sizeof(TWASMUInt32)) then begin
            Pos:= TWASMPUInt32(safe_read_across_bounds(location, sizeof(TWASMUInt32), heap));
            ret^:= Pos^;
            kfree(TWASMVoid(Pos));
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= TWASMPUInt32(heap^.Memory[PageIndex] + pageOffset);
            ret^:= Pos^;
        end;
        read_uint32:= true;
    end;
end;

function read_uint64(location : TWASMUInt32; heap : PWasmHeap; ret : TWASMPUInt64) : TWASMBoolean;
var
    PageIndex : TWASMUInt32;
    PageOffset : TWASMUInt32;
    Pos : TWASMPUInt64;

begin
    if address_voids_bounds(location, sizeof(TWASMUInt64), heap) then begin
        read_uint64:= false;
    end else begin
        if address_crosses_bounds(location, sizeof(TWASMUInt64)) then begin
            Pos:= TWASMPUInt64(safe_read_across_bounds(location, sizeof(TWASMUInt64), heap));
            ret^:= Pos^;
            kfree(TWASMVoid(Pos));
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= TWASMPUInt64(heap^.Memory[PageIndex] + PageOffset);
            ret^:= Pos^;
        end;
        read_uint64:= true;
    end; 
end;

function read_leb_uint32(location : TWASMUInt32; heap : PWasmHeap; ret : TWASMPUInt32) : TWASMBoolean;
var
    PageIndex : TWASMUInt32;
    PageOffset : TWASMUInt32;
    Pos : TWASMPUInt8;
    bytesRead : TWASMUInt8;

begin
    if address_voids_bounds(location, 5, heap) then begin
      read_leb_uint32:= false;
    end else begin
      if address_crosses_bounds(location, 5) then begin
        Pos:= safe_read_across_bounds(location, 5, heap);
        bytesRead:= read_leb128_to_uint32(pos, TWASMPUInt8(pos+5), ret);
        kfree(TWASMVoid(Pos));
      end else begin
        pageIndex:= get_page_index(location);
        pageOffset:= get_page_offset(location);
        Pos:= TWASMPUInt8(heap^.Memory[PageIndex] + PageOffset);
        bytesRead:= read_leb128_to_uint32(pos, TWASMPUInt8(pos+5), ret);
      end;
      if bytesRead > 0 then
          read_leb_uint32:= true
        else
          read_leb_uint32:= false;
    end;
end;

function write_uint8(location : TWASMUInt32; heap : PWasmHeap; value : TWASMUInt8) : TWASMBoolean;
var
    PageIndex : TWASMUInt32;
    PageOffset : TWASMUInt32;
    Pos : TWASMPUInt8;

begin
    if address_voids_bounds(location, 1, heap) then begin
        write_uint8:= false;
    end else begin
        PageIndex:= get_page_index(location);
        pageOffset:= get_page_offset(location);
        Pos:= TWASMPUInt8(heap^.Memory[PageIndex] + PageOffset);
        Pos^:= value;
        write_uint8:= true;    
    end;
end;

function write_uint16(location : TWASMUInt32; heap : PWasmHeap; value : TWASMUInt16) : TWASMBoolean;
var
    PageIndex : TWASMUInt32;
    PageOffset : TWASMUInt32;
    Pos : TWASMPUInt16;

begin
    if address_voids_bounds(location, SizeOf(TWASMUInt16), heap) then begin
        write_uint16:= false;
    end else begin
        if address_crosses_bounds(location, SizeOf(TWASMUInt16)) then begin
            Pos:= TWASMPUInt16(kalloc(sizeof(TWASMUInt16)));
            Pos^:= value;
            if(safe_write_across_bounds(location, sizeof(TWASMUInt16), heap, PWasmPage(Pos))) then begin
              write_uint16:= true;
            end else begin
              write_uint16:= false;
            end;
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= TWASMPUInt16(heap^.Memory[PageIndex] + PageOffset);
            Pos^:= value;
            write_uint16:= true;
        end;
    end;
end;

function write_uint32(location : TWASMUInt32; heap : PWasmHeap; value : TWASMUInt32) : TWASMBoolean;
var
    PageIndex : TWASMUInt32;
    PageOffset : TWASMUInt32;
    Pos : TWASMPUInt32;

begin
    if address_voids_bounds(location, SizeOf(TWASMUInt32), heap) then begin
        write_uint32:= false;
    end else begin
        if address_crosses_bounds(location, SizeOf(TWASMUInt32)) then begin
            Pos:= TWASMPUInt32(kalloc(sizeof(TWASMUInt32)));
            Pos^:= value;
            if(safe_write_across_bounds(location, sizeof(TWASMUInt32), heap, PWasmPage(Pos))) then begin
              write_uint32:= true;
            end else begin
              write_uint32:= false;
            end;
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= TWASMPUInt32(heap^.Memory[PageIndex] + PageOffset);
            Pos^:= value;
            write_uint32:= true;
        end;
    end;
end;

function write_uint64(location : TWASMUInt32; heap : PWasmHeap; value : TWASMUInt64) : TWASMBoolean;
var
    PageIndex : TWASMUInt32;
    PageOffset : TWASMUInt32;
    Pos : TWASMPUInt64;

begin
    if address_voids_bounds(location, SizeOf(TWASMUInt64), heap) then begin
        write_uint64:= false;
    end else begin
        if address_crosses_bounds(location, SizeOf(TWASMUInt64)) then begin
            Pos:= TWASMPUInt64(kalloc(sizeof(TWASMUInt64)));
            Pos^:= value;
            if(safe_write_across_bounds(location, sizeof(TWASMUInt64), heap, PWasmPage(Pos))) then begin
              write_uint64:= true;
            end else begin
              write_uint64:= false;
            end;
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= TWASMPUInt64(heap^.Memory[PageIndex] + PageOffset);
            Pos^:= value;
            write_uint64:= true;
        end;
    end;
end;

function get_ptr(location : TWASMUInt32; heap : PWasmHeap) : TWASMPUInt8;
var
    pageIndex, pageOffset : TWASMUInt32;
begin
    if location >= heap^.PageCount * PAGE_SIZE then begin
        get_ptr := nil;
        exit;
    end;
    pageIndex  := get_page_index(location);
    pageOffset := get_page_offset(location);
    get_ptr := TWASMPUInt8(heap^.Memory[pageIndex] + pageOffset);
end;


end.
