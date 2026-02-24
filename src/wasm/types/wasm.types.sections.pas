unit wasm.types.sections;

interface

uses
    wasm.types.builtin,
    wasm.types.enums,
    wasm.types.values;

type
    TWASMImportDesc = record
      Kind       : TWASMUInt8;  { 0=func, 1=table, 2=memory, 3=global }
      TypeIndex  : TWASMUInt32; { For func: type index. For others: parsed limits/type }
      { Table: ElemType (1 byte), then limits }
      TableElemType : TWASMUInt8;
      { Memory/Table limits }
      HasMax     : TWASMBoolean;
      LimitsMin  : TWASMUInt32;
      LimitsMax  : TWASMUInt32;
      { Global: value type + mutability }
      GlobalValType : TWASMUInt8;
      GlobalMut     : TWASMBoolean;
    end;
    PWASMImportDesc = ^TWASMImportDesc;

    TWASMImportEntry = record
      ModuleNameLength : TWASMUInt32;
      ModuleName       : TWASMPChar;
      FieldNameLength  : TWASMUInt32;
      FieldName        : TWASMPChar;
      Desc             : TWASMImportDesc;
    end;
    PWASMImportEntry = ^TWASMImportEntry;

    TWASMImportSection = record
      ImportCount : TWASMUInt32;
      Entries     : PWASMImportEntry;
    end;
    PWASMImportSection = ^TWASMImportSection;

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

    { Table types }
    TWASMTableType = record
      ElementType : TWASMUInt8;
      HasMax      : TWASMBoolean;
      LimitsMin   : TWASMUInt32;
      LimitsMax   : TWASMUInt32;
    end;
    PWASMTableType = ^TWASMTableType;

    TWASMTableSection = record
      TableCount : TWASMUInt32;
      Tables     : PWASMTableType;
    end;
    PWASMTableSection = ^TWASMTableSection;

    TWASMTableInstance = record
      ElementType : TWASMUInt8;
      Size        : TWASMUInt32;
      MaxSize     : TWASMUInt32;
      HasMax      : TWASMBoolean;
      Elements    : TWASMPUInt32;
    end;
    PWASMTableInstance = ^TWASMTableInstance;

    TWASMTables = record
      TableCount : TWASMUInt32;
      Tables     : PWASMTableInstance;
    end;
    PWASMTables = ^TWASMTables;

    { Element segment types }
    TWASMElementSegment = record
      TableIndex  : TWASMUInt32;
      Offset      : TWASMUInt32;
      FuncCount   : TWASMUInt32;
      FuncIndices : TWASMPUInt32;
      Dropped     : TWASMBoolean;
    end;
    PWASMElementSegment = ^TWASMElementSegment;

    TWASMElementSection = record
      SegmentCount : TWASMUInt32;
      Segments     : PWASMElementSegment;
    end;
    PWASMElementSection = ^TWASMElementSection;

    { Data segment runtime storage (for bulk memory ops) }
    TWASMDataSegment = record
      Data    : TWASMPUInt8;
      Size    : TWASMUInt32;
      Dropped : TWASMBoolean;
    end;
    PWASMDataSegment = ^TWASMDataSegment;

    TWASMDataSegments = record
      SegmentCount : TWASMUInt32;
      Segments     : PWASMDataSegment;
    end;
    PWASMDataSegments = ^TWASMDataSegments;

    { Element segment runtime storage (for table ops) }
    TWASMElementSegments = record
      SegmentCount : TWASMUInt32;
      Segments     : PWASMElementSegment;
    end;
    PWASMElementSegments = ^TWASMElementSegments;

implementation

end.
