unit wasm.types.heap;

interface

uses
    types, lmemorymanager, leb128;

const
    PAGE_SIZE = $10000; // 64k

type
    PWasmPage = puint8;

    PWasmPages = ^PWasmPage;

    PWasmHeap = ^TWasmHeap;
    TWasmHeap = record
        Memory    : PWasmPages;
        PageCount : uint32;
    end;

function new_heap() : PWasmHeap;
function expand_heap(Heap : PWasmHeap) : boolean;

function read_uint8(location : uint32; heap : PWasmHeap; ret : puint8) : boolean;
function read_uint16(location : uint32; heap : PWasmHeap; ret : puint16) : boolean;
function read_uint32(location : uint32; heap : PWasmHeap; ret : puint32) : boolean;
function read_uint64(location : uint32; heap : PWasmHeap; ret : puint64) : boolean;
function read_leb_uint32(location : uint32; heap : PWasmHeap; ret : puint32) : boolean;

function write_uint8(location : uint32; heap : PWasmHeap; value : uint8) : boolean;
function write_uint16(location : uint32; heap : PWasmHeap; value : uint16) : boolean;
function write_uint32(location : uint32; heap : PWasmHeap; value : uint32) : boolean;
function write_uint64(location : uint32; heap : PWasmHeap; value : uint64) : boolean;

implementation

function get_page_index(location : uint32) : uint32;
begin
    get_page_index:= location div PAGE_SIZE;
end;

function get_page_offset(location : uint32) : uint32;
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

function expand_heap(Heap : PWasmHeap) : boolean;
var
    NewMemory : PWasmPages;
    i : uint32;

begin
    NewMemory:= PWasmPages(Kalloc(sizeof(PWasmPage) * (Heap^.PageCount + 1)));
    for i:=0 to Heap^.PageCount-1 do begin
        NewMemory[i]:= Heap^.Memory[i];
    end;
    NewMemory[Heap^.PageCount]:= PWasmPage(Kalloc(PAGE_SIZE));
    kfree(void(Heap^.Memory));
    Heap^.Memory:= NewMemory;
    inc(Heap^.PageCount);
    expand_heap:= true;
end;

function address_voids_bounds(location : uint32; length : uint32; heap : PWasmHeap) : boolean;
begin
    if (location >= heap^.PageCount * PAGE_SIZE) or ((location + (length - 1)) >= heap^.PageCount * PAGE_SIZE) then begin
        address_voids_bounds:= true;
    end else begin
        address_voids_bounds:= false;
    end;
end;

function address_crosses_bounds(location : uint32; length : uint32) : boolean;
begin
    if get_page_index(location) <> get_page_index(location + (length - 1)) then begin
        address_crosses_bounds:= true;
    end else begin
        address_crosses_bounds:= false;
    end;
end;

function safe_read_across_bounds(location : uint32; length : uint32; heap : PWasmHeap) : PWasmPage;
var
    Page1Offset : uint32;
    Page1Page : uint32;
    Page1BytesToRead : uint32;

    Page2Page : uint32;
    Page2BytesToRead : uint32;

    res : PWasmPage;
    i : uint32;

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

function safe_write_across_bounds(location : uint32; length : uint32; heap : PWasmHeap; value : PWasmPage) : boolean;
var
    Page1Offset : uint32;
    Page1Page : uint32;
    Page1BytesToWrite : uint32;

    Page2Page : uint32;
    Page2BytesToWrite : uint32;

    i : uint32;

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


function read_uint8(location : uint32; heap : PWasmHeap; ret : puint8) : boolean;
var
    PageIndex : uint32;
    PageOffset : uint32;

begin
    if address_voids_bounds(location, sizeof(uint8), heap) then begin
        read_uint8:= false;
    end else begin
        PageIndex:= get_page_index(location);
        PageOffset:= get_page_offset(location);
        ret^:= heap^.Memory[PageIndex][PageOffset];
        read_uint8:= true;
    end;
end;

function read_uint16(location : uint32; heap : PWasmHeap; ret : puint16) : boolean;
var
    PageIndex : uint32;
    PageOffset : uint32;
    Pos : PuInt16;

begin
    if address_voids_bounds(location, sizeof(uint16), heap) then begin
        read_uint16:= false;
    end else begin
        if address_crosses_bounds(location, sizeof(uint16)) then begin
            Pos:= puint16(safe_read_across_bounds(location, sizeof(uint16), heap));
            ret^:= Pos^;
            kfree(void(Pos));
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= puint16(heap^.Memory[PageIndex] + PageOffset);
            ret^:= Pos^;
        end;
        read_uint16:= true;
    end;
end;

function read_uint32(location : uint32; heap : PWasmHeap; ret : puint32) : boolean;
var
    PageIndex : uint32;
    PageOffset : uint32;
    Pos : PuInt32;

begin
    if address_voids_bounds(location, sizeof(uint32), heap) then begin
        read_uint32:= false;
    end else begin
        if address_crosses_bounds(location, sizeof(uint32)) then begin
            Pos:= puint32(safe_read_across_bounds(location, sizeof(uint32), heap));
            ret^:= Pos^;
            kfree(void(Pos));
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= puint32(heap^.Memory[PageIndex] + pageOffset);
            ret^:= Pos^;
        end;
        read_uint32:= true;
    end;
end;

function read_uint64(location : uint32; heap : PWasmHeap; ret : puint64) : boolean;
var
    PageIndex : uint32;
    PageOffset : uint32;
    Pos : PuInt64;

begin
    if address_voids_bounds(location, sizeof(uint64), heap) then begin
        read_uint64:= false;
    end else begin
        if address_crosses_bounds(location, sizeof(uint64)) then begin
            Pos:= puint64(safe_read_across_bounds(location, sizeof(uint64), heap));
            ret^:= Pos^;
            kfree(void(Pos));
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= puint64(heap^.Memory[PageIndex] + PageOffset);
            ret^:= Pos^;
        end;
        read_uint64:= true;
    end; 
end;

function read_leb_uint32(location : uint32; heap : PWasmHeap; ret : puint32) : boolean;
var
    PageIndex : uint32;
    PageOffset : uint32;
    Pos : PuInt8;
    bytesRead : uint8;

begin
    if address_voids_bounds(location, 5, heap) then begin
      read_leb_uint32:= false;
    end else begin
      if address_crosses_bounds(location, 5) then begin
        Pos:= safe_read_across_bounds(location, 5, heap);
        bytesRead:= read_leb128_to_uint32(pos, puint8(pos+5), ret);
        kfree(void(Pos));
      end else begin
        pageIndex:= get_page_index(location);
        pageOffset:= get_page_offset(location);
        Pos:= puint8(heap^.Memory[PageIndex] + PageOffset);
        bytesRead:= read_leb128_to_uint32(pos, puint8(pos+5), ret);
      end;
      if bytesRead > 0 then
          read_leb_uint32:= true
        else
          read_leb_uint32:= false;
    end;
end;

function write_uint8(location : uint32; heap : PWasmHeap; value : uint8) : boolean;
var
    PageIndex : uint32;
    PageOffset : uint32;
    Pos : PuInt8;

begin
    if address_voids_bounds(location, 1, heap) then begin
        write_uint8:= false;
    end else begin
        PageIndex:= get_page_index(location);
        pageOffset:= get_page_offset(location);
        Pos:= puint8(heap^.Memory[PageIndex] + PageOffset);
        Pos^:= value;
        write_uint8:= true;    
    end;
end;

function write_uint16(location : uint32; heap : PWasmHeap; value : uint16) : boolean;
var
    PageIndex : uint32;
    PageOffset : uint32;
    Pos : PuInt16;

begin
    if address_voids_bounds(location, SizeOf(uint16), heap) then begin
        write_uint16:= false;
    end else begin
        if address_crosses_bounds(location, SizeOf(uint16)) then begin
            Pos:= puint16(kalloc(sizeof(uint16)));
            Pos^:= value;
            if(safe_write_across_bounds(location, sizeof(uint16), heap, PWasmPage(Pos))) then begin
              write_uint16:= true;
            end else begin
              write_uint16:= false;
            end;
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= puint16(heap^.Memory[PageIndex] + PageOffset);
            Pos^:= value;
            write_uint16:= true;
        end;
    end;
end;

function write_uint32(location : uint32; heap : PWasmHeap; value : uint32) : boolean;
var
    PageIndex : uint32;
    PageOffset : uint32;
    Pos : PuInt32;

begin
    if address_voids_bounds(location, SizeOf(uint32), heap) then begin
        write_uint32:= false;
    end else begin
        if address_crosses_bounds(location, SizeOf(uint32)) then begin
            Pos:= puint32(kalloc(sizeof(uint32)));
            Pos^:= value;
            if(safe_write_across_bounds(location, sizeof(uint32), heap, PWasmPage(Pos))) then begin
              write_uint32:= true;
            end else begin
              write_uint32:= false;
            end;
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= puint32(heap^.Memory[PageIndex] + PageOffset);
            Pos^:= value;
            write_uint32:= true;
        end;
    end;
end;

function write_uint64(location : uint32; heap : PWasmHeap; value : uint64) : boolean;
var
    PageIndex : uint32;
    PageOffset : uint32;
    Pos : PuInt64;

begin
    if address_voids_bounds(location, SizeOf(uint64), heap) then begin
        write_uint64:= false;
    end else begin
        if address_crosses_bounds(location, SizeOf(uint64)) then begin
            Pos:= puint64(kalloc(sizeof(uint64)));
            Pos^:= value;
            if(safe_write_across_bounds(location, sizeof(uint64), heap, PWasmPage(Pos))) then begin
              write_uint64:= true;
            end else begin
              write_uint64:= false;
            end;
        end else begin
            pageIndex:= get_page_index(location);
            pageOffset:= get_page_offset(location);
            Pos:= puint64(heap^.Memory[PageIndex] + PageOffset);
            Pos^:= value;
            write_uint64:= true;
        end;
    end;
end;


end.
