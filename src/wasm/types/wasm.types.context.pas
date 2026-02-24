unit wasm.types.context;

interface

uses
    wasm.types.builtin,
    wasm.types.enums,
    wasm.types.values,
    wasm.types.sections,
    wasm.types.heap;

type
    TWASMState = record
      Code            : TWASMPUInt8;
      Limit           : TWASMUInt32;
      Locals          : PWASMLocals;
      Memory          : PWasmHeap;
      Globals         : PWASMGlobals;
      Tables          : PWASMTables;
      DataSegments    : PWASMDataSegments;
      ElementSegments : PWASMElementSegments;
      Control_Stack   : PWASMStack;
      Operand_Stack   : PWASMStack;
      IP              : TWASMUInt32;
      Running         : TWASMBoolean;
    end;
    PWASMState = ^TWASMState;

    TWASMSections = record
      TypeSection     : PWASMTypeSection;
      ImportSection   : PWASMImportSection;
      FunctionSection : PWASMFunctionSection;
      ExportSection   : PWASMExportSection;
      CodeSection     : PWASMCodeSection;
      MemorySection   : PWASMMemorySection;
      StartIndex      : TWASMInt32;  { -1 = no start function }
    end;

    TWASMProcessContext = record
      ValidBinary       : TWASMBoolean;
      Version           : TWASMUInt32;
      ExecutionState    : TWASMState;
      Sections          : TWASMSections;
    end;
    PWASMProcessContext = ^TWASMProcessContext;

    FProcessWASMOpCode = procedure(Context : PWASMProcessContext);

    TWASMOpcodeJumpTable = array[0..255] of FProcessWASMOpCode;
    PWASMOpcodeJumpTable = ^TWASMOpcodeJumpTable;

    TWASMFCOpcodeJumpTable = array[0..255] of FProcessWASMOpCode;
    PWASMFCOpcodeJumpTable = ^TWASMFCOpcodeJumpTable;

implementation

end.
