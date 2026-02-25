unit wasm.types.context;

interface

uses
    wasm.types.builtin,
    wasm.types.enums,
    wasm.types.values,
    wasm.types.sections,
    wasm.types.heap;

type
    { Forward declaration for resolved imports }
    PWASMProcessContext = ^TWASMProcessContext;

    TWASMHostFunc = procedure(Context : PWASMProcessContext);

    { ---- WASI OS-facing hook prototypes ---- }
    { Clean native-typed callbacks — no WASM knowledge required }

    TWASIFdWriteHook = function(fd: TWASMUInt32;
                                buf: TWASMPUInt8;
                                len: TWASMUInt32): TWASMUInt32;

    TWASIFdReadHook = function(fd: TWASMUInt32;
                               buf: TWASMPUInt8;
                               len: TWASMUInt32): TWASMUInt32;

    TWASIFdCloseHook = function(fd: TWASMUInt32): TWASMUInt32;

    TWASIFdSeekHook = function(fd: TWASMUInt32;
                               offset: TWASMInt64;
                               whence: TWASMUInt32;
                               var newoffset: TWASMUInt64): TWASMUInt32;

    TWASIProcExitHook = procedure(code: TWASMUInt32);

    TWASIClockTimeGetHook = function(clock_id: TWASMUInt32;
                                     precision: TWASMUInt64;
                                     var time: TWASMUInt64): TWASMUInt32;

    TWASIClockResGetHook = function(clock_id: TWASMUInt32;
                                    var resolution: TWASMUInt64): TWASMUInt32;

    TWASIRandomGetHook = function(buf: TWASMPUInt8;
                                  len: TWASMUInt32): TWASMUInt32;

    TWASIArgsSizesGetHook = function(var count: TWASMUInt32;
                                     var buf_size: TWASMUInt32): TWASMUInt32;

    TWASIArgsGetHook = function(argv: TWASMPUInt32;
                                argv_buf: TWASMPUInt8): TWASMUInt32;

    TWASIEnvironSizesGetHook = function(var count: TWASMUInt32;
                                        var buf_size: TWASMUInt32): TWASMUInt32;

    TWASIEnvironGetHook = function(environ: TWASMPUInt32;
                                   environ_buf: TWASMPUInt8): TWASMUInt32;

    { WASI hook table — all registered OS hooks. nil = not implemented. }
    TWASIHookTable = record
        OnFdWrite         : TWASIFdWriteHook;
        OnFdRead          : TWASIFdReadHook;
        OnFdClose         : TWASIFdCloseHook;
        OnFdSeek          : TWASIFdSeekHook;
        OnProcExit        : TWASIProcExitHook;
        OnClockTimeGet    : TWASIClockTimeGetHook;
        OnClockResGet     : TWASIClockResGetHook;
        OnRandomGet       : TWASIRandomGetHook;
        OnArgsSizesGet    : TWASIArgsSizesGetHook;
        OnArgsGet         : TWASIArgsGetHook;
        OnEnvironSizesGet : TWASIEnvironSizesGetHook;
        OnEnvironGet      : TWASIEnvironGetHook;
    end;
    PWASIHookTable = ^TWASIHookTable;

    { ---- Host function registry (custom hooks) ---- }
    { Dynamically allocated, grows as needed — no fixed limit }

    TWASMHostFuncEntry = record
      ModuleName  : TWASMPChar;
      FieldName   : TWASMPChar;
      Callback    : TWASMHostFunc;
    end;
    PWASMHostFuncEntry = ^TWASMHostFuncEntry;

    TWASMHostFuncRegistry = record
      Count    : TWASMUInt32;
      Capacity : TWASMUInt32;
      Entries  : PWASMHostFuncEntry;
    end;

    { ---- Resolved imports ---- }

    TWASMResolvedImport = record
      IsResolved : TWASMBoolean;
      Callback   : TWASMHostFunc;
      ModuleName : TWASMPChar;   { kept for trap diagnostics }
      FieldName  : TWASMPChar;   { kept for trap diagnostics }
    end;
    PWASMResolvedImport = ^TWASMResolvedImport;

    TWASMResolvedImports = record
      Count   : TWASMUInt32;
      Imports : PWASMResolvedImport;
    end;
    PWASMResolvedImports = ^TWASMResolvedImports;

    { ---- Execution state ---- }

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

    { ---- Process context ---- }

    TWASMProcessContext = record
      ValidBinary       : TWASMBoolean;
      Version           : TWASMUInt32;
      ExitCode          : TWASMUInt32;
      ExecutionState    : TWASMState;
      Sections          : TWASMSections;
      ResolvedImports   : TWASMResolvedImports;
      WASIHooks         : TWASIHookTable;
      HostFuncRegistry  : TWASMHostFuncRegistry;
    end;

    FProcessWASMOpCode = procedure(Context : PWASMProcessContext);

    TWASMOpcodeJumpTable = array[0..255] of FProcessWASMOpCode;
    PWASMOpcodeJumpTable = ^TWASMOpcodeJumpTable;

    TWASMFCOpcodeJumpTable = array[0..255] of FProcessWASMOpCode;
    PWASMFCOpcodeJumpTable = ^TWASMFCOpcodeJumpTable;

implementation

end.
