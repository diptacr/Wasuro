unit wasm.types;

interface

uses
    wasm.types.builtin,
    wasm.types.heap;

const
     WASM_HDR_MAGIC = $6D736100;

type
    TWasmExportType = (
      etFunc = $00,
      etTable = $01,
      etMemory = $02,
      etGlobal = $03
    );

    TWasmValueType = (
      vtNone = $00,
      vti32  = $7F,
      vti64  = $7E,
      vtf32  = $7D,
      vtf64  = $7C,
      vtv128 = $7B,
      vtfunc = $70,
      vtextn = $6F
    );

    TWasmTypeType = (
      ttFunc = $60
    );

    TWasmBinarySectionId = (
      sidCustom   = $00,
      sidType     = $01,
      sidImport   = $02,
      sidFunction = $03,
      sidTable    = $04,
      sidMemory   = $05,
      sidGlobal   = $06,
      sidExport   = $07,
      sidStart    = $08,
      sidElement  = $09,
      sidCode     = $0A,
      sidData     = $0B
    );

    TWasmOpcode = (
      UnreachableOp = $00,
      NopOp = $01,
      BlockOp = $02,
      LoopOp = $03,
      IfOp = $04,
      ElseOp = $05,
      EndOp = $0B,
      BrOp = $0C,
      BrIfOp = $0D,
      BrTableOp = $0E,
      ReturnOp = $0F,
      CallOp = $10,
      CallIndirectOp = $11,
      DropOp = $1A,
      SelectOp = $1B,
      LocalGetOp = $20,
      LocalSetOp = $21,
      LocalTeeOp = $22,
      GlobalGetOp = $23,
      GlobalSetOp = $24,
      I32LoadOp = $28,
      I64LoadOp = $29,
      F32LoadOp = $2A,
      F64LoadOp = $2B,
      I32Load8SOp = $2C,
      I32Load8UOp = $2D,
      I32Load16SOp = $2E,
      I32Load16UOp = $2F,
      I64Load8SOp = $30,
      I64Load8UOp = $31,
      I64Load16SOp = $32,
      I64Load16UOp = $33,
      I64Load32SOp = $34,
      I64Load32UOp = $35,
      I32StoreOp = $36,
      I64StoreOp = $37,
      F32StoreOp = $38,
      F64StoreOp = $39,
      I32Store8Op = $3A,
      I32Store16Op = $3B,
      I64Store8Op = $3C,
      I64Store16Op = $3D,
      I64Store32Op = $3E,
      MemorySizeOp = $3F,
      MemoryGrowOp = $40,
      I32ConstOp = $41,
      I64ConstOp = $42,
      F32ConstOp = $43,
      F64ConstOp = $44,
      I32EqzOp = $45,
      I32EqOp = $46,
      I32NeOp = $47,
      I32LtSOp = $48,
      I32LtUOp = $49,
      I32GtSOp = $4A,
      I32GtUOp = $4B,
      I32LeSOp = $4C,
      I32LeUOp = $4D,
      I32GeSOp = $4E,
      I32GeUOp = $4F,
      I64EqzOp = $50,
      I64EqOp = $51,
      I64NeOp = $52,
      I64LtSOp = $53,
      I64LtUOp = $54,
      I64GtSOp = $55,
      I64GtUOp = $56,
      I64LeSOp = $57,
      I64LeUOp = $58,
      I64GeSOp = $59,
      I64GeUOp = $5A,
      F32EqOp = $5B,
      F32NeOp = $5C,
      F32LtOp = $5D,
      F32GtOp = $5E,
      F32LeOp = $5F,
      F32GeOp = $60,
      F64EqOp = $61,
      F64NeOp = $62,
      F64LtOp = $63,
      F64GtOp = $64,
      F64LeOp = $65,
      F64GeOp = $66,
      I32ClzOp = $67,
      I32CtzOp = $68,
      I32PopcntOp = $69,
      I32AddOp = $6A,
      I32SubOp = $6B,
      I32MulOp = $6C,
      I32DivSOp = $6D,
      I32DivUOp = $6E,
      I32RemSOp = $6F,
      I32RemUOp = $70,
      I32AndOp = $71,
      I32OrOp = $72,
      I32XorOp = $73,
      I32ShlOp = $74,
      I32ShrSOp = $75,
      I32ShrUOp = $76,
      I32RotlOp = $77,
      I32RotrOp = $78,
      I64ClzOp = $79,
      I64CtzOp = $7A,
      I64PopcntOp = $7B,
      I64AddOp = $7C,
      I64SubOp = $7D,
      I64MulOp = $7E,
      I64DivSOp = $7F,
      I64DivUOp = $80,
      I64RemSOp = $81,
      I64RemUOp = $82,
      I64AndOp = $83,
      I64OrOp = $84,
      I64XorOp = $85,
      I64ShlOp = $86,
      I64ShrSOp = $87,
      I64ShrUOp = $88,
      I64RotlOp = $89,
      I64RotrOp = $8A
    );

type
    uint128 = packed record
      low, high: TWASMUInt64;
    end;

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

    TWASMLocals = record
      LocalCount  : TWASMUInt32;
      TypeCount   : TWASMUInt32;
      Locals      : PWASMValueEntry;
    end;
    PWASMLocals = ^TWASMLocals;

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

    TWASMState = record
      Code   : TWASMPUInt8;
      Limit  : TWASMUInt32;
      Locals : PWASMLocals;
      Memory : PWasmHeap;
      Globals : PWASMGlobals;
      Control_Stack : PWASMStack;
      Operand_Stack : PWASMStack;
      IP : TWASMUInt32;
      Running : TWASMBoolean;
    end;
    PWASMState = ^TWASMState;

    TWASMSections = record
      TypeSection     : PWASMTypeSection;
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

function GetWasmValueTypeString(ValueType : TWasmValueType) : TWASMPChar;
function GetWasmTypeTypeString(TypeType : TWasmTypeType) : TWASMPChar;
function GetWasmBinarySectionIdString(SectionId : TWasmBinarySectionId) : TWASMPChar;
function GetWasmExportTypeString(ExportType : TWasmExportType) : TWASMPChar;

implementation

function GetWasmValueTypeString(ValueType : TWasmValueType) : TWASMPChar;
begin
    case ValueType of
      vtNone : GetWasmValueTypeString := 'None';
      vti32  : GetWasmValueTypeString := 'i32';
      vti64  : GetWasmValueTypeString := 'i64';
      vtf32  : GetWasmValueTypeString := 'f32';
      vtf64  : GetWasmValueTypeString := 'f64';
      vtv128 : GetWasmValueTypeString := 'v128';
      vtfunc : GetWasmValueTypeString := 'func';
      vtextn : GetWasmValueTypeString := 'extn';
      else GetWasmValueTypeString := 'Unknown';
    end; 
end;

function GetWasmTypeTypeString(TypeType : TWasmTypeType) : TWASMPChar;
begin
    case TypeType of
      ttFunc : GetWasmTypeTypeString := 'Func';
      else GetWasmTypeTypeString := 'Unknown';
    end; 
end;

function GetWasmBinarySectionIdString(SectionId : TWasmBinarySectionId) : TWASMPChar;
begin
    case SectionId of
      sidCustom   : GetWasmBinarySectionIdString := 'Custom';
      sidType     : GetWasmBinarySectionIdString := 'Type';
      sidImport   : GetWasmBinarySectionIdString := 'Import';
      sidFunction : GetWasmBinarySectionIdString := 'Function';
      sidTable    : GetWasmBinarySectionIdString := 'Table';
      sidMemory   : GetWasmBinarySectionIdString := 'Memory';
      sidGlobal   : GetWasmBinarySectionIdString := 'Global';
      sidExport   : GetWasmBinarySectionIdString := 'Export';
      sidStart    : GetWasmBinarySectionIdString := 'Start';
      sidElement  : GetWasmBinarySectionIdString := 'Element';
      sidCode     : GetWasmBinarySectionIdString := 'Code';
      sidData     : GetWasmBinarySectionIdString := 'Data';
      else GetWasmBinarySectionIdString := 'Unknown';
    end;
end;

function GetWasmExportTypeString(ExportType : TWasmExportType) : TWASMPChar;
begin
    case ExportType of
      etFunc   : GetWasmExportTypeString := 'Function';
      etTable  : GetWasmExportTypeString := 'Table';
      etMemory : GetWasmExportTypeString := 'Memory';
      etGlobal : GetWasmExportTypeString := 'Global';
      else GetWasmExportTypeString := 'Unknown';
    end;
end;

end.

