unit wasm.parser.validate;

interface

uses wasm.types.builtin, wasm.types.context;

{ Validates a parsed WASM module for structural consistency.
  Returns true if valid, false otherwise.
  Sets errorMsg to a description of the first error found. }
function validate_module(ctx : PWASMProcessContext; var errorMsg : TWASMPChar) : TWASMBoolean;

implementation

uses console;

function validate_module(ctx : PWASMProcessContext; var errorMsg : TWASMPChar) : TWASMBoolean;
var i : TWASMUInt32;
begin
    validate_module := true;

    { Check 1: Binary must be valid (magic number was correct) }
    if not ctx^.ValidBinary then begin
        errorMsg := 'Invalid WASM binary: bad magic number';
        validate_module := false;
        exit;
    end;

    { Check 2: Version must be 1 (MVP) }
    if ctx^.Version <> 1 then begin
        errorMsg := 'Unsupported WASM version (expected 1)';
        validate_module := false;
        exit;
    end;

    { Check 3: If function section exists, code section must exist and counts must match }
    if (ctx^.Sections.FunctionSection <> nil) then begin
        if (ctx^.Sections.CodeSection = nil) then begin
            errorMsg := 'Function section present but code section missing';
            validate_module := false;
            exit;
        end;
        if ctx^.Sections.FunctionSection^.FunctionCount <> ctx^.Sections.CodeSection^.CodeCount then begin
            errorMsg := 'Function count does not match code count';
            validate_module := false;
            exit;
        end;
    end;

    { Check 4: If code section exists, function section must exist }
    if (ctx^.Sections.CodeSection <> nil) then begin
        if (ctx^.Sections.FunctionSection = nil) then begin
            errorMsg := 'Code section present but function section missing';
            validate_module := false;
            exit;
        end;
    end;

    { Check 5: Function type indices must be within range of type section }
    if (ctx^.Sections.FunctionSection <> nil) and (ctx^.Sections.TypeSection <> nil) then begin
        for i := 0 to ctx^.Sections.FunctionSection^.FunctionCount - 1 do begin
            if ctx^.Sections.FunctionSection^.Functions[i].Index >= ctx^.Sections.TypeSection^.TypeCount then begin
                errorMsg := 'Function type index out of range';
                validate_module := false;
                exit;
            end;
        end;
    end;

    { Check 6: Start function index must be within range }
    if ctx^.Sections.StartIndex >= 0 then begin
        if (ctx^.Sections.FunctionSection = nil) then begin
            errorMsg := 'Start function specified but no function section';
            validate_module := false;
            exit;
        end;
        if TWASMUInt32(ctx^.Sections.StartIndex) >= ctx^.Sections.FunctionSection^.FunctionCount then begin
            errorMsg := 'Start function index out of range';
            validate_module := false;
            exit;
        end;
    end;

    errorMsg := nil;
end;

end.
