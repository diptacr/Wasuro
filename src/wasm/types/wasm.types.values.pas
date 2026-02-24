unit wasm.types.values;

interface

uses
    wasm.types.builtin,
    wasm.types.enums;

type
    TWASMStackEntry = record
        ValueType: TWasmValueType;
        case TWASMInt32 of
          0: (i32Value: TWASMInt32);
          1: (i64Value: TWASMInt64);
          2: (f32Value: TWASMFloat);
          3: (f64Value: TWASMDouble);
          4: (v128Value: uint128);
          5: (funcValue: TWASMUInt32);
          6: (extnValue: TWASMUInt32);
    end;
    PWASMStackEntry = ^TWASMStackEntry;

    TWASMValueEntry = record
        ValueType: TWasmValueType;
        case TWASMInt32 of
          0: (i32Value: TWASMInt32);
          1: (i64Value: TWASMInt64);
          2: (f32Value: TWASMFloat);
          3: (f64Value: TWASMDouble);
          4: (v128Value: uint128);
          5: (funcValue: TWASMUInt32);
          6: (extnValue: TWASMUInt32);
    end;
    PWASMValueEntry = ^TWASMValueEntry;

    TWASMStack = record
        Size: TWASMUInt32;
        Top: TWASMUInt32;
        Full: TWASMBoolean;
        Entries: PWASMStackEntry;
    end;
    PWASMStack = ^TWASMStack;

    PWASMParam = ^TWASMParam;
    TWASMParam = record
      ValueType : TWasmValueType;
    end;

    TWASMLocals = record
      LocalCount  : TWASMUInt32;
      TypeCount   : TWASMUInt32;
      Locals      : PWASMValueEntry;
    end;
    PWASMLocals = ^TWASMLocals;

implementation

end.
