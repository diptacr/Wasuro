unit wasm.test.opcode.callindirect;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.enums, wasm.types.values, wasm.types.sections, wasm.types.context, wasm.types.stack,
    wasm.vm, wasm.test.framework;

procedure setup_table(ctx: PWASMProcessContext; size: TWASMUInt32);
var
    i: TWASMUInt32;
begin
    ctx^.ExecutionState.Tables^.TableCount := 1;
    ctx^.ExecutionState.Tables^.Tables := PWASMTableInstance(kalloc(sizeof(TWASMTableInstance)));
    ctx^.ExecutionState.Tables^.Tables[0].ElementType := $70;
    ctx^.ExecutionState.Tables^.Tables[0].Size := size;
    ctx^.ExecutionState.Tables^.Tables[0].MaxSize := size;
    ctx^.ExecutionState.Tables^.Tables[0].HasMax := true;
    ctx^.ExecutionState.Tables^.Tables[0].Elements := TWASMPUInt32(kalloc(sizeof(TWASMUInt32) * size));
    for i := 0 to size - 1 do
        ctx^.ExecutionState.Tables^.Tables[0].Elements[i] := $FFFFFFFF;
end;

procedure setup_call_context(ctx: PWASMProcessContext;
                             flatCode: TWASMPUInt8; flatLen: TWASMUInt32;
                             numFuncs: TWASMUInt32);
begin
    ctx^.ExecutionState.Code  := flatCode;
    ctx^.ExecutionState.Limit := flatLen;
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
    flatCode: array[0..31] of TWASMUInt8;
    ctx: PWASMProcessContext;
    types: array[0..1] of TWASMType;
    params: array[0..1] of TWASMParam;
    returns: array[0..0] of TWASMParam;
begin
    test_begin('opcode.call_indirect');

    { Test 1: call_indirect calls function from table
      func 0 (callee): i32.const 42, end
      func 1 (caller): i32.const 0 (table elem idx), call_indirect type=0 table=0, end
      Table[0] = func 0 }
    flatCode[0] := $41; flatCode[1] := $2A; flatCode[2] := $0B; { func 0: i32.const 42, end }
    flatCode[3] := $41; flatCode[4] := $00;                      { i32.const 0 (table element index) }
    flatCode[5] := $11; flatCode[6] := $00; flatCode[7] := $00;  { call_indirect type=0 table=0 }
    flatCode[8] := $0B;                                           { end }

    ctx := make_test_context(@flatCode[0], 9);
    setup_call_context(ctx, @flatCode[0], 9, 2);
    setup_table(ctx, 4);
    ctx^.ExecutionState.Tables^.Tables[0].Elements[0] := 0; { table[0] = func 0 }

    { Type 0: () -> i32 }
    types[0]._type := $60;
    types[0].ParamCount := 0;
    types[0].ParamTypes := nil;
    types[0].ReturnCount := 1;
    returns[0].ValueType := vti32;
    types[0].ReturnTypes := @returns[0];
    { Type 1: () -> i32 (same signature for caller) }
    types[1]._type := $60;
    types[1].ParamCount := 0;
    types[1].ParamTypes := nil;
    types[1].ReturnCount := 1;
    types[1].ReturnTypes := @returns[0];

    ctx^.Sections.TypeSection^.TypeCount := 2;
    ctx^.Sections.TypeSection^.Types := @types[0];
    ctx^.Sections.FunctionSection^.Functions[0].Index := 0; { func 0 has type 0 }
    ctx^.Sections.FunctionSection^.Functions[1].Index := 1; { func 1 has type 1 }

    ctx^.Sections.CodeSection^.Entries[0].CodeIndex  := 0;
    ctx^.Sections.CodeSection^.Entries[0].CodeLength := 3;
    ctx^.Sections.CodeSection^.Entries[0].Locals.LocalCount := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.TypeCount  := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.Locals     := nil;

    ctx^.Sections.CodeSection^.Entries[1].CodeIndex  := 3;
    ctx^.Sections.CodeSection^.Entries[1].CodeLength := 6;
    ctx^.Sections.CodeSection^.Entries[1].Locals.LocalCount := 0;
    ctx^.Sections.CodeSection^.Entries[1].Locals.TypeCount  := 0;
    ctx^.Sections.CodeSection^.Entries[1].Locals.Locals     := nil;

    ctx^.ExecutionState.IP := 3; { start at func 1 (caller) }
    while wasm.vm.tick(ctx) do;
    assert_i32('call_indirect calls func',
               wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 42);

    { Test 2: call_indirect with parameters
      func 0 (add): local.get 0, local.get 1, i32.add, end
      func 1 (caller): i32.const 10, i32.const 20, i32.const 0 (elem idx),
                        call_indirect type=0 table=0, end
      Table[0] = func 0 }
    flatCode[0]  := $20; flatCode[1]  := $00;  { local.get 0 }
    flatCode[2]  := $20; flatCode[3]  := $01;  { local.get 1 }
    flatCode[4]  := $6A;                        { i32.add }
    flatCode[5]  := $0B;                        { end }
    flatCode[6]  := $41; flatCode[7]  := $0A;  { i32.const 10 }
    flatCode[8]  := $41; flatCode[9]  := $14;  { i32.const 20 }
    flatCode[10] := $41; flatCode[11] := $00;  { i32.const 0 (table elem idx) }
    flatCode[12] := $11; flatCode[13] := $00; flatCode[14] := $00; { call_indirect type=0 table=0 }
    flatCode[15] := $0B;                        { end }

    ctx := make_test_context(@flatCode[0], 16);
    setup_call_context(ctx, @flatCode[0], 16, 2);
    setup_table(ctx, 4);
    ctx^.ExecutionState.Tables^.Tables[0].Elements[0] := 0;

    params[0].ValueType := vti32;
    params[1].ValueType := vti32;
    types[0]._type := $60;
    types[0].ParamCount := 2;
    types[0].ParamTypes := @params[0];
    types[0].ReturnCount := 1;
    returns[0].ValueType := vti32;
    types[0].ReturnTypes := @returns[0];
    types[1]._type := $60;
    types[1].ParamCount := 0;
    types[1].ParamTypes := nil;
    types[1].ReturnCount := 1;
    types[1].ReturnTypes := @returns[0];

    ctx^.Sections.TypeSection^.TypeCount := 2;
    ctx^.Sections.TypeSection^.Types := @types[0];
    ctx^.Sections.FunctionSection^.Functions[0].Index := 0;
    ctx^.Sections.FunctionSection^.Functions[1].Index := 1;

    ctx^.Sections.CodeSection^.Entries[0].CodeIndex  := 0;
    ctx^.Sections.CodeSection^.Entries[0].CodeLength := 6;
    ctx^.Sections.CodeSection^.Entries[0].Locals.LocalCount := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.TypeCount  := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.Locals     := nil;

    ctx^.Sections.CodeSection^.Entries[1].CodeIndex  := 6;
    ctx^.Sections.CodeSection^.Entries[1].CodeLength := 10;
    ctx^.Sections.CodeSection^.Entries[1].Locals.LocalCount := 0;
    ctx^.Sections.CodeSection^.Entries[1].Locals.TypeCount  := 0;
    ctx^.Sections.CodeSection^.Entries[1].Locals.Locals     := nil;

    ctx^.ExecutionState.IP := 6;
    while wasm.vm.tick(ctx) do;
    assert_i32('call_indirect with params',
               wasm.types.stack.popi32(ctx^.ExecutionState.Operand_Stack), 30);

    { Test 3: call_indirect traps on uninitialized table element }
    flatCode[0] := $41; flatCode[1] := $02;  { i32.const 2 (uninit element) }
    flatCode[2] := $11; flatCode[3] := $00; flatCode[4] := $00; { call_indirect }
    flatCode[5] := $0B;

    ctx := make_test_context(@flatCode[0], 6);
    setup_call_context(ctx, @flatCode[0], 6, 1);
    setup_table(ctx, 4);
    { table[2] is $FFFFFFFF = uninitialized }

    types[0]._type := $60;
    types[0].ParamCount := 0;
    types[0].ParamTypes := nil;
    types[0].ReturnCount := 0;
    types[0].ReturnTypes := nil;
    ctx^.Sections.TypeSection^.TypeCount := 1;
    ctx^.Sections.TypeSection^.Types := @types[0];
    ctx^.Sections.FunctionSection^.Functions[0].Index := 0;
    ctx^.Sections.CodeSection^.Entries[0].CodeIndex  := 0;
    ctx^.Sections.CodeSection^.Entries[0].CodeLength := 6;
    ctx^.Sections.CodeSection^.Entries[0].Locals.LocalCount := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.TypeCount  := 0;
    ctx^.Sections.CodeSection^.Entries[0].Locals.Locals     := nil;

    ctx^.ExecutionState.IP := 0;
    while wasm.vm.tick(ctx) do;
    assert_true('call_indirect uninit traps', ctx^.ExecutionState.Running = false);

    test_end;
end;

end.
