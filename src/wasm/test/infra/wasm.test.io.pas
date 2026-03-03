unit wasm.test.io;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.vm.io, wasm.test.framework;

{ ---- Capture hook for testing ---------------------------------------- }

const
    CAPTURE_BUF_SIZE = 256;

var
    CaptureBuf : array[0..CAPTURE_BUF_SIZE - 1] of TWASMChar;
    CapturePos : TWASMUInt32;
    SavedHook  : TIOWriteCharHook;

procedure capture_reset;
begin
    CapturePos := 0;
end;

procedure capture_writechar(ch : TWASMChar);
begin
    if CapturePos < CAPTURE_BUF_SIZE then begin
        CaptureBuf[CapturePos] := ch;
        Inc(CapturePos);
    end;
end;

procedure capture_begin;
begin
    SavedHook := wasm.vm.io.io_get_writechar;
    wasm.vm.io.io_set_writechar(@capture_writechar);
    capture_reset;
end;

procedure capture_end;
begin
    wasm.vm.io.io_set_writechar(SavedHook);
end;

function capture_matches(expected : TWASMPChar) : TWASMBoolean;
var
    i : TWASMUInt32;
begin
    i := 0;
    while (i < CapturePos) and (expected[i] <> #0) do begin
        if CaptureBuf[i] <> expected[i] then begin
            capture_matches := false;
            exit;
        end;
        Inc(i);
    end;
    capture_matches := (i = CapturePos) and (expected[i] = #0);
end;

{ ---- Test cases ------------------------------------------------------ }

procedure test_default_hook_no_crash;
begin
    { Before any hook is set, calling writestring should not crash }
    SavedHook := wasm.vm.io.io_get_writechar;
    wasm.vm.io.io_set_writechar(nil);
    wasm.vm.io.writestring('should not crash');
    wasm.vm.io.io_set_writechar(SavedHook);
    assert_true('default hook no crash', true);
end;

procedure test_writechar_hook;
begin
    capture_begin;
    wasm.vm.io.writechar('A');
    capture_end;
    assert_true('writechar hook receives ch', (CapturePos = 1) and (CaptureBuf[0] = 'A'));
end;

procedure test_writestring;
begin
    capture_begin;
    wasm.vm.io.writestring('Hi');
    capture_end;
    assert_true('writestring "Hi"', capture_matches('Hi'));
end;

procedure test_writestringln;
begin
    capture_begin;
    wasm.vm.io.writestringln('Ok');
    capture_end;
    { Should be 'Ok' followed by LF (#10) }
    assert_true('writestringln length', CapturePos = 3);
    assert_true('writestringln [0]', CaptureBuf[0] = 'O');
    assert_true('writestringln [1]', CaptureBuf[1] = 'k');
    assert_true('writestringln [2]=LF', CaptureBuf[2] = #10);
end;

procedure test_writeint_positive;
begin
    capture_begin;
    wasm.vm.io.writeintWND(42, 0);
    capture_end;
    assert_true('writeint 42', capture_matches('42'));
end;

procedure test_writeint_zero;
begin
    capture_begin;
    wasm.vm.io.writeintWND(0, 0);
    capture_end;
    assert_true('writeint 0', capture_matches('0'));
end;

procedure test_writeint_negative;
begin
    capture_begin;
    wasm.vm.io.writeintWND(-7, 0);
    capture_end;
    assert_true('writeint -7', capture_matches('-7'));
end;

procedure test_writeintln;
begin
    capture_begin;
    wasm.vm.io.writeintlnWND(5, 0);
    capture_end;
    { '5' + LF }
    assert_true('writeintln len', CapturePos = 2);
    assert_true('writeintln [0]', CaptureBuf[0] = '5');
    assert_true('writeintln [1]=LF', CaptureBuf[1] = #10);
end;

procedure test_writehexpair;
begin
    capture_begin;
    wasm.vm.io.writehexpair($AB);
    capture_end;
    assert_true('writehexpair $AB', capture_matches('0xAB'));
end;

procedure test_writehexpair_zero;
begin
    capture_begin;
    wasm.vm.io.writehexpair($00);
    capture_end;
    assert_true('writehexpair $00', capture_matches('0x00'));
end;

procedure test_writeint_large;
begin
    capture_begin;
    wasm.vm.io.writeintWND(12345, 0);
    capture_end;
    assert_true('writeint 12345', capture_matches('12345'));
end;

{ ---- Runner ---------------------------------------------------------- }

procedure run;
begin
    test_begin('wasm.vm.io');

    test_default_hook_no_crash;
    test_writechar_hook;
    test_writestring;
    test_writestringln;
    test_writeint_positive;
    test_writeint_zero;
    test_writeint_negative;
    test_writeintln;
    test_writehexpair;
    test_writehexpair_zero;
    test_writeint_large;
end;

end.
