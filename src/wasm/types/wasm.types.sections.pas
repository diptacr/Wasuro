unit wasm.types.sections;

interface

uses
    wasm.types.builtin,
    wasm.types.enums,
    wasm.types.values;

type
    TWASMExportEntry = record
      NameLength: TWASMUInt32;
      Name: TWASMPChar;
      ExportType: TWasmExportType;
      FunctionIndex: TWASMUInt32;
    end;
    PWASMExportEntry = ^TWASMExportEntry;

    TWASMExportSection = record
      ExportCount: TWASMUInt32;
      Entries: PWASMExportEntry;
    end;
    PWASMExportSection = ^TWASMExportSection;

    PWASMType = ^TWASMType;
    TWASMType = record
      _type        : TWASMUInt8;
      ParamCount   : TWASMUInt32;
      ParamTypes   : PWASMParam;
      ReturnCount  : TWASMUInt32;
      ReturnTypes  : PWASMParam;
    end;

    TWASMTypeSection = record
      TypeCount     : TWASMUInt32;
      Types         : PWASMType;
    end;
    PWASMTypeSection = ^TWASMTypeSection;

    PWASMFunction = ^TWASMFunction;
    TWASMFunction = record
      Index : TWASMUInt32;
    end;

    PWASMFunctionSection = ^TWASMFunctionSection;
    TWASMFunctionSection = record
      FunctionCount : TWASMUInt32;
      Functions : PWASMFunction;
    end;

    TWASMCodeEntry = record
      SectionLength : TWASMUInt32;
      CodeLength    : TWASMUInt32;
      Code          : TWASMPUInt8;
      CodeIndex     : TWASMUInt32;
      Locals        : TWASMLocals;
    end;
    PWASMCodeEntry = ^TWASMCodeEntry;

    TWASMCodeSection = record
      CodeCount : TWASMUInt32;
      Entries   : PWASMCodeEntry;
    end;
    PWASMCodeSection = ^TWASMCodeSection;

    TWASMGlobalEntry = record
      ValueType : TWasmValueType;
      Mutable   : TWASMBoolean;
      Value     : TWASMValueEntry;
    end;
    PWASMGlobalEntry = ^TWASMGlobalEntry;

    TWASMGlobals = record
      GlobalCount : TWASMUInt32;
      Globals     : PWASMGlobalEntry;
    end;
    PWASMGlobals = ^TWASMGlobals;

    TWASMMemoryLimits = record
      HasMax   : TWASMBoolean;
      InitialPages : TWASMUInt32;
      MaxPages     : TWASMUInt32;
    end;
    PWASMMemoryLimits = ^TWASMMemoryLimits;

    TWASMMemorySection = record
      MemoryCount : TWASMUInt32;
      Memories    : PWASMMemoryLimits;
    end;
    PWASMMemorySection = ^TWASMMemorySection;

implementation

end.
