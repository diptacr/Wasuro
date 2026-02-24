unit wasm.test.opcode.call;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context, wasm.types.stack,
    wasm.vm, wasm.test.framework;

{ Helper: set up sections needed for call tests.
  Creates a module with the given flat code buffer and code entries. }
procedure setup_call_context(ctx: PWASMProcessContext;
                             flatCode: TWASMPUInt8; flatLen: TWASMUInt32;
                             numFuncs: TWASMUInt32);
begin
    ctx^.ExecutionState.Code  := flatCode;
    ctx^.ExecutionState.Limit := flatLen;

    { Allocate sections }
    ctx^.Sections.TypeSection     := PWASMTypeSection(kalloc(sizeof(TWASMTypeSection)));
    ctx^.Sections.FunctionSection := PWASMFunctionSection(kalloc(sizeof(TWASMFunctionSection)));
    ctx^.Sections.CodeSection     := PWASMCodeSection(kalloc(sizeof(TWASMCodeSection)));

    ctx^.Sections.TypeSection^.TypeCount         := 0;
    ctx^.Sections.FunctionSection^.FunctionCount := numFuncs;
    ctx^.Sections.FunctionSection^.Functions     := PWASMFunction(kalloc(sizeof(TWASMFunction) * numFuncs));
    ctx^.Sections.CodeSection^.CodeCount         := numFuncs;
    ctx^.Sections.CodeSection^.Entries           := PWASMCodeEntry(kalloc(sizeof(TWASMCodeEntry) * numFuncs));
end;

procedure run;
var
    flatCode : array[0..31] of TWASMUInt8;
    ctx : PWASMProcessContext;
    types : array[0..1] of TWASMType;
    params : array[0..1] of TWASMParam;
    returns : array[0..0] of TWASMParam;
begin
    test_begin('opcode.call');

    { ------------------------------------------------------------------ }
    { Test 1: simple call - callee returns constant 42                   }
    {   func 0 (callee): i32.const 42  end   -> 3 bytes at offset 0     }
    {   func 1 (caller): call 0  end          -> 3 bytes at offset 3     }
    { ------------------------------------------------------------------ }
    flatCode[0] := $41; { i32.const }
    flatCode[1] := $2A; { 42 }
    flatCode[2] := $0B; { end }
    flatCode[3] := $10; { call }
    flatCode[4] := $00; { func index 0 }
    flatCode[5] := $0B; { end }

    ctx := make_test_context(@flatCode[0], 6);
    setup_call_context(ctx, @flatCode[0], 6, 2);

    { Type 0: () -> i32 }
    types[0]._type       := $60;
    types[0].ParamCount  := 0;
    types[0].ParamTypes  := nil;
    types[0].ReturnCount := 1;
    returns[0].ValueType := vti32;
    types[0].ReturnTypes := @returns[0];

    { Type 1: () -> i32 }
    types[1]._type       := $60;
    types[1].ParamCount  := 0;
    types[1].ParamTypes  := nil;
    types[1].ReturnCount := 1;
    types[1].ReturnTypes := @returns[0];

    ctx^.Sections.TypeSection^.TypeCount := 2;
    ctx^.Sections.TypeSection^.Types     := @types[0];

    { Function 0 -> type 0, Function 1 -> type 1 }
    ctx^.Sections.FunctionSection^.Functions[0].Index := 0;
    ctx^.Sections.FunctionSection^.Functions[1].Index := 1;

    { Code entry 0: callee at offset 0, length 3, no locals }
    ctx^.Sections.CodeSection^.Entries[0].CodeIndex  := 0;
    ctx^.Sections.CodeSection^.Entries[0].CodeLength := 3;
    ctx^.Sections.CodeSection^.Entries[0].Code       := @flatCode[0];
    ctx^.Sections.CodeSection^.Entries[0].Locals.LocalCount := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.TypeCount  := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.Locals     := nil;

    { Code entry 1: caller at offset 3, length 3, no locals }
    ctx^.Sections.CodeSection^.Entries[1].CodeIndex  := 3;
    ctx^.Sections.CodeSection^.Entries[1].CodeLength := 3;
    ctx^.Sections.CodeSection^.Entries[1].Code       := @flatCode[3];
    ctx^.Sections.CodeSection^.Entries[1].Locals.LocalCount := 0;
    ctx^.Sections.CodeSection^.Entries[1].Locals.TypeCount  := 0;
    ctx^.Sections.CodeSection^.Entries[1].Locals.Locals     := nil;

    { Start execution at function 1 (caller) }
    ctx^.ExecutionState.IP := 3;
    while wasm.vm.tick(ctx) do;
    assert_i32('call returns constant',
               wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { ------------------------------------------------------------------ }
    { Test 2: call with parameters - callee adds two i32 args            }
    {   func 0 (add): local.get 0  local.get 1  i32.add  end  (6 bytes) }
    {   func 1 (caller): i32.const 10  i32.const 20  call 0  end (7 b)  }
    { ------------------------------------------------------------------ }
    { func 0: local.get 0, local.get 1, i32.add, end }
    flatCode[0]  := $20; { local.get 0 }
    flatCode[1]  := $00;
    flatCode[2]  := $20; { local.get 1 }
    flatCode[3]  := $01;
    flatCode[4]  := $6A; { i32.add }
    flatCode[5]  := $0B; { end }
    { func 1: i32.const 10, i32.const 20, call 0, end }
    flatCode[6]  := $41; { i32.const 10 }
    flatCode[7]  := $0A;
    flatCode[8]  := $41; { i32.const 20 }
    flatCode[9]  := $14;
    flatCode[10] := $10; { call 0 }
    flatCode[11] := $00;
    flatCode[12] := $0B; { end }

    ctx := make_test_context(@flatCode[0], 13);
    setup_call_context(ctx, @flatCode[0], 13, 2);

    { Type 0: (i32, i32) -> i32 }
    params[0].ValueType := vti32;
    params[1].ValueType := vti32;
    types[0]._type       := $60;
    types[0].ParamCount  := 2;
    types[0].ParamTypes  := @params[0];
    types[0].ReturnCount := 1;
    returns[0].ValueType := vti32;
    types[0].ReturnTypes := @returns[0];

    { Type 1: () -> i32 }
    types[1]._type       := $60;
    types[1].ParamCount  := 0;
    types[1].ParamTypes  := nil;
    types[1].ReturnCount := 1;
    types[1].ReturnTypes := @returns[0];

    ctx^.Sections.TypeSection^.TypeCount := 2;
    ctx^.Sections.TypeSection^.Types     := @types[0];

    ctx^.Sections.FunctionSection^.Functions[0].Index := 0;
    ctx^.Sections.FunctionSection^.Functions[1].Index := 1;

    ctx^.Sections.CodeSection^.Entries[0].CodeIndex  := 0;
    ctx^.Sections.CodeSection^.Entries[0].CodeLength := 6;
    ctx^.Sections.CodeSection^.Entries[0].Code       := @flatCode[0];
    ctx^.Sections.CodeSection^.Entries[0].Locals.LocalCount := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.TypeCount  := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.Locals     := nil;

    ctx^.Sections.CodeSection^.Entries[1].CodeIndex  := 6;
    ctx^.Sections.CodeSection^.Entries[1].CodeLength := 7;
    ctx^.Sections.CodeSection^.Entries[1].Code       := @flatCode[6];
    ctx^.Sections.CodeSection^.Entries[1].Locals.LocalCount := 0;
    ctx^.Sections.CodeSection^.Entries[1].Locals.TypeCount  := 0;
    ctx^.Sections.CodeSection^.Entries[1].Locals.Locals     := nil;

    ctx^.ExecutionState.IP := 6;
    while wasm.vm.tick(ctx) do;
    assert_i32('call with params adds correctly',
               wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 30);

    test_end;
end;

end.
