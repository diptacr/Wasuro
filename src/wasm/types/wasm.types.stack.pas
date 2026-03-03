unit wasm.types.stack;

interface

uses
    wasm.types.builtin, lmemorymanager, wasm.vm.io,
    wasm.types.enums, wasm.types.values;

const
    DEFAULT_STACK_SIZE = $100000;

function newStack(size : TWASMUInt32) : PWASMStack;
function newDefaultStack : PWASMStack;

procedure pushi32(stack : PWASMStack; value : TWASMInt32);
procedure pushi64(stack : PWASMStack; value : TWASMInt64);
procedure pushf32(stack : PWASMStack; value : TWASMFloat);
procedure pushf64(stack : PWASMStack; value : TWASMDouble);
procedure pushv128(stack : PWASMStack; value : uint128);
procedure pushfunc(stack : PWASMStack; value : TWASMUInt32);
procedure pushextn(stack : PWASMStack; value : TWASMUInt32);

function popi32(stack : PWASMStack) : TWASMInt32;
function popi64(stack : PWASMStack) : TWASMInt64;
function popf32(stack : PWASMStack) : TWASMFloat;
function popf64(stack : PWASMStack) : TWASMDouble;
function popv128(stack : PWASMStack) : uint128;
function popfunc(stack : PWASMStack) : TWASMUInt32;
function popextn(stack : PWASMStack) : TWASMUInt32;

procedure walk(stack : PWASMStack);

implementation

procedure safeIncrement(stack : PWASMStack); inline;
begin
    if(stack^.Top < stack^.Size) then begin
        inc(stack^.Top);
        if stack^.Top = stack^.Size then begin
            stack^.Full:= true;
        end;
    end else begin
        stack^.Full:= true;
    end;
end;

procedure safeDecrement(stack : PWASMStack); inline;
begin
    if(stack^.Top > 0) then begin
        dec(stack^.Top);
        stack^.Full:= false;
    end;
end;

function newStack(size: TWASMUInt32): PWASMStack;
begin
    newStack:= PWASMStack(kalloc(sizeof(TWASMStack)));
    newStack^.Entries:= PWASMStackEntry(kalloc(size * sizeof(TWASMStackEntry)));
    newStack^.Size:= size;
    newStack^.Top:= 0;
end;

function newDefaultStack: PWASMStack;
begin
    newDefaultStack:= newStack(DEFAULT_STACK_SIZE);
end;

procedure pushi32(stack: PWASMStack; value: TWASMInt32);
begin
    stack^.Entries[stack^.Top].ValueType:= vti32;
    stack^.Entries[stack^.Top].i32Value:= value;
    safeIncrement(stack);
end;

procedure pushi64(stack: PWASMStack; value: TWASMInt64);
begin
    stack^.Entries[stack^.Top].ValueType:= vti64;
    stack^.Entries[stack^.Top].i64Value:= value;
    safeIncrement(stack);
end;

procedure pushf32(stack: PWASMStack; value: TWASMFloat);
begin
    stack^.Entries[stack^.Top].ValueType:= vtf32;
    stack^.Entries[stack^.Top].f32Value:= value;
    safeIncrement(stack);
end;

procedure pushf64(stack: PWASMStack; value: TWASMDouble);
begin
    stack^.Entries[stack^.Top].ValueType:= vtf64;
    stack^.Entries[stack^.Top].f64Value:= value;
    safeIncrement(stack);
end;

procedure pushv128(stack: PWASMStack; value: uint128);
begin
    stack^.Entries[stack^.Top].ValueType:= vtv128;
    stack^.Entries[stack^.Top].v128Value:= value;
    safeIncrement(stack);
end;

procedure pushfunc(stack: PWASMStack; value: TWASMUInt32);
begin
    stack^.Entries[stack^.Top].ValueType:= vtfunc;
    stack^.Entries[stack^.Top].funcValue:= value;
    safeIncrement(stack);
end;

procedure pushextn(stack: PWASMStack; value: TWASMUInt32);
begin
    stack^.Entries[stack^.Top].ValueType:= vtextn;
    stack^.Entries[stack^.Top].extnValue:= value;
    safeIncrement(stack);
end;

function popi32(stack: PWASMStack): TWASMInt32;
begin
    safeDecrement(stack);
    popi32:= stack^.Entries[stack^.Top].i32Value;
end;

function popi64(stack: PWASMStack): TWASMInt64;
begin
    safeDecrement(stack);
    popi64:= stack^.Entries[stack^.Top].i64Value;
end;

function popf32(stack: PWASMStack): TWASMFloat;
begin
    safeDecrement(stack);
    popf32:= stack^.Entries[stack^.Top].f32Value;
end;

function popf64(stack: PWASMStack): TWASMDouble;
begin
    safeDecrement(stack);
    popf64:= stack^.Entries[stack^.Top].f64Value;
end;

function popv128(stack: PWASMStack): uint128;
begin
    safeDecrement(stack);
    popv128:= stack^.Entries[stack^.Top].v128Value;
end;

function popfunc(stack: PWASMStack): TWASMUInt32;
begin
    safeDecrement(stack);
    popfunc:= stack^.Entries[stack^.Top].funcValue;
end;

function popextn(stack: PWASMStack): TWASMUInt32;
begin
    safeDecrement(stack);
    popextn:= stack^.Entries[stack^.Top].extnValue;
end;

procedure walk(stack : PWASMStack);
{$IFDEF DEBUG_OUTPUT}
var
    i : TWASMUInt32;
{$ENDIF}

begin
    {$IFDEF DEBUG_OUTPUT}
    // Walk the stack
    for i:=stack^.Top-1 downto 0 do begin
        case stack^.Entries[i].ValueType of
            vti32:begin
                writeln('[wasm.types.stack][-',stack^.Top-i,'] i32: ', stack^.Entries[i].i32Value);
            end;
            vti64:begin
                writeln('[wasm.types.stack][-',stack^.Top-i,'] i64: ', stack^.Entries[i].i64Value);
            end;
            vtf32:begin
                writeln('[wasm.types.stack][-',stack^.Top-i,'] f32: ', stack^.Entries[i].f32Value);
            end;
            vtf64:begin
                writeln('[wasm.types.stack][-',stack^.Top-i,'] f64: ', stack^.Entries[i].f64Value);
            end;
            vtv128:begin
                writeln('[wasm.types.stack][-',stack^.Top-i,'] v128: ', stack^.Entries[i].v128Value.low, ' ', stack^.Entries[i].v128Value.high);
            end;
            vtfunc:begin
                writeln('[wasm.types.stack][-',stack^.Top-i,'] func: ', stack^.Entries[i].funcValue);
            end;
            vtextn:begin
                writeln('[wasm.types.stack][-',stack^.Top-i,'] extn: ', stack^.Entries[i].extnValue);
            end;
        end;
    end;
    {$ENDIF}
end;

end.
