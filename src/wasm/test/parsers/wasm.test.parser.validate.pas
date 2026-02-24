unit wasm.test.parser.validate;

interface

procedure run;

implementation

uses
    wasm.types.builtin, lmemorymanager,
    wasm.types.context, wasm.types.sections,
    wasm.test.framework, wasm.parser.validate;

procedure run;
var
    ctx : PWASMProcessContext;
    errMsg : TWASMPChar;
    valid : TWASMBoolean;
begin
    test_begin('validate');

    { Test 1: Valid minimal module (no sections) }
    ctx := make_test_context(nil, 0);
    ctx^.ValidBinary := true;
    ctx^.Version := 1;
    valid := validate_module(ctx, errMsg);
    assert_true('minimal valid', valid);

    { Test 2: Invalid magic }
    ctx := make_test_context(nil, 0);
    ctx^.ValidBinary := false;
    ctx^.Version := 1;
    valid := validate_module(ctx, errMsg);
    assert_true('bad magic fails', not valid);

    { Test 3: Wrong version }
    ctx := make_test_context(nil, 0);
    ctx^.ValidBinary := true;
    ctx^.Version := 2;
    valid := validate_module(ctx, errMsg);
    assert_true('bad version fails', not valid);

    { Test 4: Function section without code section }
    ctx := make_test_context(nil, 0);
    ctx^.ValidBinary := true;
    ctx^.Version := 1;
    ctx^.Sections.FunctionSection := PWASMFunctionSection(kalloc(sizeof(TWASMFunctionSection)));
    ctx^.Sections.FunctionSection^.FunctionCount := 1;
    ctx^.Sections.CodeSection := nil;
    valid := validate_module(ctx, errMsg);
    assert_true('func without code fails', not valid);

    { Test 5: Matching function and code counts }
    ctx := make_test_context(nil, 0);
    ctx^.ValidBinary := true;
    ctx^.Version := 1;
    ctx^.Sections.FunctionSection := PWASMFunctionSection(kalloc(sizeof(TWASMFunctionSection)));
    ctx^.Sections.FunctionSection^.FunctionCount := 1;
    ctx^.Sections.FunctionSection^.Functions := PWASMFunction(kalloc(sizeof(TWASMFunction)));
    ctx^.Sections.FunctionSection^.Functions[0].Index := 0;
    ctx^.Sections.CodeSection := PWASMCodeSection(kalloc(sizeof(TWASMCodeSection)));
    ctx^.Sections.CodeSection^.CodeCount := 1;
    ctx^.Sections.TypeSection := PWASMTypeSection(kalloc(sizeof(TWASMTypeSection)));
    ctx^.Sections.TypeSection^.TypeCount := 1;
    valid := validate_module(ctx, errMsg);
    assert_true('matching counts valid', valid);

    { Test 6: Mismatched function/code counts }
    ctx := make_test_context(nil, 0);
    ctx^.ValidBinary := true;
    ctx^.Version := 1;
    ctx^.Sections.FunctionSection := PWASMFunctionSection(kalloc(sizeof(TWASMFunctionSection)));
    ctx^.Sections.FunctionSection^.FunctionCount := 2;
    ctx^.Sections.CodeSection := PWASMCodeSection(kalloc(sizeof(TWASMCodeSection)));
    ctx^.Sections.CodeSection^.CodeCount := 1;
    valid := validate_module(ctx, errMsg);
    assert_true('mismatched counts fails', not valid);

    test_end;
end;

end.
