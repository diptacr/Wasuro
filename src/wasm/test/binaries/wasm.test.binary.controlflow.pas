{ E2E test: exercises all control flow opcodes in one module.
  Tests: block, loop, if, else, end, br, br_if, br_table, call, return

  Equivalent WAT:
    (module
      (func $add (param i32 i32) (result i32)
        local.get 0
        local.get 1
        i32.add
      )
      (func (export "main") (result i32) (local i32 i32)
        ;; Step 1: block + br => local[0] = 10
        (block
          i32.const 10
          br 0
        )
        local.set 0

        ;; Step 2: if/else (true branch) => local[1] = 5
        i32.const 1
        (if
          (then i32.const 5)
          (else i32.const 0)
        )
        local.set 1

        ;; Step 3: call $add(10, 5) => local[0] = 15
        local.get 0
        local.get 1
        call $add
        local.set 0

        ;; Step 4: loop + br_if => accumulate 5+4+3+2+1 into local[0]
        ;;   15 + 5 + 4 + 3 + 2 + 1 = 30
        (loop
          local.get 0
          local.get 1
          i32.add
          local.set 0
          local.get 1
          i32.const 1
          i32.sub
          local.tee 1
          br_if 0
        )

        ;; Step 5: br_table (index 0 selects depth 0 => exits inner block)
        (block
          (block
            i32.const 0
            br_table 0 1   ;; count=1, label[0]=depth 0, default=depth 1
          )
        )

        ;; Return result = 30
        local.get 0
        return
      )
    )

  Binary layout:
    Header            8 bytes
    Type section     13 bytes  (2 types)
    Function section  5 bytes  (2 funcs)
    Export section   10 bytes  (export "main" = func 1)
    Code section     79 bytes  (2 bodies: 8 + 68 = 76 + 1 count + 2 header)
    Total           115 bytes
}
unit wasm.test.binary.controlflow;

interface

procedure run;

implementation

uses
    wasm.types.builtin, console, wasm.types.context, wasm.types.stack,
    wasm.parser, wasm.vm, wasm.test.framework;

const
  BINARY_SIZE = 115;
  BINARY : Array[$00..$72] of TWASMUInt8 = (
    { --- Header (8 bytes) --- }
    $00, $61, $73, $6D,       { magic }
    $01, $00, $00, $00,       { version 1 }

    { --- Type section id=1 len=11 (13 bytes) --- }
    $01, $0B, $02,            { section id=1, length=11, 2 types }
    $60, $02, $7F, $7F,       { type 0: func (i32 i32) }
    $01, $7F,                 {   -> (i32) }
    $60, $00,                 { type 1: func () }
    $01, $7F,                 {   -> (i32) }

    { --- Function section id=3 len=3 (5 bytes) --- }
    $03, $03, $02,            { section id=3, length=3, 2 funcs }
    $00,                      { func 0 -> type 0 }
    $01,                      { func 1 -> type 1 }

    { --- Export section id=7 len=8 (10 bytes) --- }
    $07, $08, $01,            { section id=7, length=8, 1 export }
    $04, $6D, $61, $69, $6E, { name len=4, "main" }
    $00, $01,                 { kind=func, index=1 }

    { --- Code section id=10 len=77 (79 bytes) --- }
    $0A, $4D, $02,            { section id=10, length=77, 2 bodies }

    { func 0 body: body_size=7, 0 locals, 6 code bytes }
    $07, $00,                 { body_size=7, 0 local entries }
    $20, $00,                 { local.get 0 }
    $20, $01,                 { local.get 1 }
    $6A,                      { i32.add }
    $0B,                      { end }

    { func 1 body: body_size=67, 1 local entry (2 x i32), 64 code bytes }
    $43, $01, $02, $7F,       { body_size=67, 1 entry: 2 x i32 }

    { Step 1: block + br => 10 on stack (9 bytes) }
    $02, $40,                 { block $40 }
    $41, $0A,                 { i32.const 10 }
    $0C, $00,                 { br 0 }
    $0B,                      { end }
    $21, $00,                 { local.set 0 }

    { Step 2: if/else => 5 on stack (12 bytes) }
    $41, $01,                 { i32.const 1 (condition=true) }
    $04, $40,                 { if $40 }
    $41, $05,                 { i32.const 5 }
    $05,                      { else }
    $41, $00,                 { i32.const 0 }
    $0B,                      { end }
    $21, $01,                 { local.set 1 }

    { Step 3: call add(10, 5) => 15 (8 bytes) }
    $20, $00,                 { local.get 0 }
    $20, $01,                 { local.get 1 }
    $10, $00,                 { call 0 }
    $21, $00,                 { local.set 0 }

    { Step 4: loop + br_if (19 bytes) }
    $03, $40,                 { loop $40 }
    $20, $00,                 { local.get 0 }
    $20, $01,                 { local.get 1 }
    $6A,                      { i32.add }
    $21, $00,                 { local.set 0 }
    $20, $01,                 { local.get 1 }
    $41, $01,                 { i32.const 1 }
    $6B,                      { i32.sub }
    $22, $01,                 { local.tee 1 }
    $0D, $00,                 { br_if 0 }
    $0B,                      { end }

    { Step 5: br_table (12 bytes) }
    $02, $40,                 { block $40 (outer) }
    $02, $40,                 { block $40 (inner) }
    $41, $00,                 { i32.const 0 (index) }
    $0E, $01, $00, $01,       { br_table count=1 [0] default=1 }
    $0B,                      { end (inner) }
    $0B,                      { end (outer) }

    { Return result (4 bytes) }
    $20, $00,                 { local.get 0 }
    $0F,                      { return }
    $0B                       { end }
  );

procedure run;
var
    ctx : PWASMProcessContext;
begin
    test_begin('binary.controlflow');

    ctx := wasm.parser.parse(@BINARY[0], TWASMPUInt8(@BINARY[0] + BINARY_SIZE));
    assert_true('valid binary', ctx^.ValidBinary);
    assert_u32('version=1', ctx^.Version, 1);

    { Start execution at func 1 (main) with its locals }
    ctx^.ExecutionState.IP := ctx^.Sections.CodeSection^.Entries[1].CodeIndex;
    ctx^.ExecutionState.Locals := @ctx^.Sections.CodeSection^.Entries[1].Locals;
    ctx^.ExecutionState.Running := true;
    while wasm.vm.tick(ctx) do;

    assert_bool('execution stopped', ctx^.ExecutionState.Running, false);
    assert_true('stack has result', ctx^.ExecutionState.Operand_Stack^.Top > 0);
    assert_i32('result=30', popi32(ctx^.ExecutionState.Operand_Stack), 30);

    test_end;
end;

end.
