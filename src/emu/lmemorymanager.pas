unit lmemorymanager;

{$mode objfpc}{$H+}

interface

uses
    types;

function kalloc(size : uint32) : void;
procedure kfree(area : void);

implementation

function kalloc(size: uint32): void;
begin
     kalloc:= void(GetMem(size));
end;

procedure kfree(area: void);
begin
     FreeMem(pointer(area));
end;

end.

