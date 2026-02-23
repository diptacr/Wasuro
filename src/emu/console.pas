unit console;

interface

procedure clearWND(WND: uint32);
procedure clearWNDEx(WND: uint32; attributes: uint32);
procedure writecharWND(character: char; WND: uint32);
procedure writecharlnWND(character: char; WND: uint32);
procedure writecharexWND(character: char; attributes: uint32; WND: uint32);
procedure writecharlnexWND(character: char; attributes: uint32; WND: uint32);
procedure OutputWND(identifier: PChar; str: PChar; WND: uint32);
procedure OutputlnWND(identifier: PChar; str: PChar; WND: uint32);
procedure writestringWND(str: PChar; WND: uint32);
procedure writestringlnWND(str: PChar; WND: uint32);
procedure writestringexWND(str: PChar; attributes: uint32; WND: uint32);
procedure writestringlnexWND(str: PChar; attributes: uint32; WND: uint32);
procedure writeintWND(i: integer; WND: uint32);
procedure writeintlnWND(i: integer; WND: uint32);
procedure writeintexWND(i: integer; attributes: uint32; WND: uint32);
procedure writeintlnexWND(i: integer; attributes: uint32; WND: uint32);
procedure Output(identifier : PChar; str : PChar);
procedure Outputln(identifier : PChar; str : PChar);
procedure writestring(str : PChar);
procedure writestringln(str : PChar);
procedure writehexpair(b : uint8);

implementation

procedure writehexpair(b : uint8);
var
    bn : Array[0..1] of uint8;
    i  : uint8;

begin
    writestring('0x');
    bn[0]:= b SHR 4;
    bn[1]:= b AND $0F;
    for i:=0 to 1 do begin
        case bn[i] of
            0:writestring('0');
            1:writestring('1');
            2:writestring('2');
            3:writestring('3');
            4:writestring('4');
            5:writestring('5');
            6:writestring('6');
            7:writestring('7');
            8:writestring('8');
            9:writestring('9');
            10:writestring('A');
            11:writestring('B');
            12:writestring('C');
            13:writestring('D');
            14:writestring('E');
            15:writestring('F');
        end;
    end;
end;

procedure clearWND(WND: uint32);
begin

end;

procedure clearWNDEx(WND: uint32; attributes: uint32);
begin

end;

procedure writecharWND(character: char; WND: uint32);
begin
     Write(character);
end;

procedure writecharlnWND(character: char; WND: uint32);
begin
     Writeln(character);
end;

procedure writecharexWND(character: char; attributes: uint32; WND: uint32);
begin
     Write(character);
end;

procedure writecharlnexWND(character: char; attributes: uint32; WND: uint32);
begin
     Writeln(character);
end;

procedure OutputWND(identifier: PChar; str: PChar; WND: uint32);
begin
     write('[',identifier,'] ',str);
end;

procedure OutputlnWND(identifier: PChar; str: PChar; WND: uint32);
begin
     writeln('[',identifier,'] ',str);
end;

procedure writestringWND(str: PChar; WND: uint32);
begin
     write(str);
end;

procedure writestringlnWND(str: PChar; WND: uint32);
begin
     writeln(str);
end;

procedure writestringexWND(str: PChar; attributes: uint32; WND: uint32);
begin
     write(str);
end;

procedure writestringlnexWND(str: PChar; attributes: uint32; WND: uint32);
begin
     writeln(str);
end;

procedure writeintWND(i: integer; WND: uint32);
begin
     write(i);
end;

procedure writeintlnWND(i: integer; WND: uint32);
begin
     writeln(i);
end;

procedure writeintexWND(i: integer; attributes: uint32; WND: uint32);
begin
     write(i);
end;

procedure writeintlnexWND(i: integer; attributes: uint32; WND: uint32);
begin
     writeln(i);
end;

procedure writestring(str : PChar);
begin
     write(str);
end;

procedure writestringln(str : PChar);
begin
     writeln(str);
end;

procedure Output(identifier: PChar; str: PChar);
begin
     write('[',identifier,'] ',str);
end;

procedure Outputln(identifier: PChar; str: PChar);
begin
     writeln('[',identifier,'] ',str);
end;

end.

