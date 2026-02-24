unit wasm.test.opcode.loop;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.enums, wasm.types.context, wasm.types.stack, wasm.vm, wasm.test.framework;

procedure run;
var
    code : array[0..31] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.loop');

    { Test 1: loop that executes body once then exits via end }
    { loop $40 nop end }
    code[0] := $03; { loop }
    code[1] := $40; { blocktype $40 }
    code[2] := $01; { nop }
    code[3] := $0B; { end }
    ctx := make_test_context(@code[0], 4);
    while wasm.vm.tick(ctx) do;
    assert_true('loop single pass completes', ctx^.ExecutionState.Running = false);

    { Test 2: loop that counts down from 3 to 0 using br_if }
    { Local 0 starts at 3; loop: decrement, br_if 0 if nonzero; end }
    { i32.const 3  local.set 0  loop $40
        local.get 0  i32.const 1  i32.sub  local.tee 0  br_if 0
      end }
    code[0]  := $41; { i32.const 3 }
    code[1]  := $03;
    code[2]  := $21; { local.set 0 }
    code[3]  := $00;
    code[4]  := $03; { loop }
    code[5]  := $40; { blocktype $40 }
    code[6]  := $20; { local.get 0 }
    code[7]  := $00;
    code[8]  := $41; { i32.const 1 }
    code[9]  := $01;
    code[10] := $6B; { i32.sub }
    code[11] := $22; { local.tee 0 }
    code[12] := $00;
    code[13] := $0D; { br_if 0 }
    code[14] := $00;
    code[15] := $0B; { end loop }
    ctx := make_test_context(@code[0], 16);
    setup_test_locals(ctx, 1, vti32);
    while wasm.vm.tick(ctx) do;
    assert_i32('loop countdown final local', ctx^.ExecutionState.Locals^.Locals[0].i32Value, 0);

    { Test 3: loop with accumulator - sum 1+2+3 = 6 }
    { local 0 = counter (starts 3), local 1 = accumulator }
    { i32.const 3  local.set 0
      loop $40
        local.get 1  local.get 0  i32.add  local.set 1
        local.get 0  i32.const 1  i32.sub  local.tee 0
        br_if 0
      end }
    code[0]  := $41; { i32.const 3 }
    code[1]  := $03;
    code[2]  := $21; { local.set 0 }
    code[3]  := $00;
    code[4]  := $03; { loop }
    code[5]  := $40; { blocktype $40 }
    code[6]  := $20; { local.get 1 (accum) }
    code[7]  := $01;
    code[8]  := $20; { local.get 0 (counter) }
    code[9]  := $00;
    code[10] := $6A; { i32.add }
    code[11] := $21; { local.set 1 }
    code[12] := $01;
    code[13] := $20; { local.get 0 }
    code[14] := $00;
    code[15] := $41; { i32.const 1 }
    code[16] := $01;
    code[17] := $6B; { i32.sub }
    code[18] := $22; { local.tee 0 }
    code[19] := $00;
    code[20] := $0D; { br_if 0 }
    code[21] := $00;
    code[22] := $0B; { end loop }
    ctx := make_test_context(@code[0], 23);
    setup_test_locals(ctx, 2, vti32);
    while wasm.vm.tick(ctx) do;
    assert_i32('loop accumulator result', ctx^.ExecutionState.Locals^.Locals[1].i32Value, 6);

    test_end;
end;

end.
