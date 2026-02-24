unit wasm.types.enums;

interface

uses
    wasm.types.builtin;

type
    TWasmExportType = (
      etFunc    = $00,
      etTable   = $01,
      etMemory  = $02,
      etGlobal  = $03
    );

    TWasmImportDescKind = (
      idkFunc   = $00,
      idkTable  = $01,
      idkMemory = $02,
      idkGlobal = $03
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
      sidData     = $0B,
      sidDataCount = $0C
    );

    TWasmOpcode = (
      UnreachableOp       = $00,
      NopOp               = $01,
      BlockOp             = $02,
      LoopOp              = $03,
      IfOp                = $04,
      ElseOp              = $05,
      EndOp               = $0B,
      BrOp                = $0C,
      BrIfOp              = $0D,
      BrTableOp           = $0E,
      ReturnOp            = $0F,
      CallOp              = $10,
      CallIndirectOp      = $11,
      DropOp              = $1A,
      SelectOp            = $1B,
      TableGetOp          = $25,
      TableSetOp          = $26,
      LocalGetOp          = $20,
      LocalSetOp          = $21,
      LocalTeeOp          = $22,
      GlobalGetOp         = $23,
      GlobalSetOp         = $24,
      I32LoadOp           = $28,
      I64LoadOp           = $29,
      F32LoadOp           = $2A,
      F64LoadOp           = $2B,
      I32Load8SOp         = $2C,
      I32Load8UOp         = $2D,
      I32Load16SOp        = $2E,
      I32Load16UOp        = $2F,
      I64Load8SOp         = $30,
      I64Load8UOp         = $31,
      I64Load16SOp        = $32,
      I64Load16UOp        = $33,
      I64Load32SOp        = $34,
      I64Load32UOp        = $35,
      I32StoreOp          = $36,
      I64StoreOp          = $37,
      F32StoreOp          = $38,
      F64StoreOp          = $39,
      I32Store8Op         = $3A,
      I32Store16Op        = $3B,
      I64Store8Op         = $3C,
      I64Store16Op        = $3D,
      I64Store32Op        = $3E,
      MemorySizeOp        = $3F,
      MemoryGrowOp        = $40,
      I32ConstOp          = $41,
      I64ConstOp          = $42,
      F32ConstOp          = $43,
      F64ConstOp          = $44,
      I32EqzOp            = $45,
      I32EqOp             = $46,
      I32NeOp             = $47,
      I32LtSOp            = $48,
      I32LtUOp            = $49,
      I32GtSOp            = $4A,
      I32GtUOp            = $4B,
      I32LeSOp            = $4C,
      I32LeUOp            = $4D,
      I32GeSOp            = $4E,
      I32GeUOp            = $4F,
      I64EqzOp            = $50,
      I64EqOp             = $51,
      I64NeOp             = $52,
      I64LtSOp            = $53,
      I64LtUOp            = $54,
      I64GtSOp            = $55,
      I64GtUOp            = $56,
      I64LeSOp            = $57,
      I64LeUOp            = $58,
      I64GeSOp            = $59,
      I64GeUOp            = $5A,
      F32EqOp             = $5B,
      F32NeOp             = $5C,
      F32LtOp             = $5D,
      F32GtOp             = $5E,
      F32LeOp             = $5F,
      F32GeOp             = $60,
      F64EqOp             = $61,
      F64NeOp             = $62,
      F64LtOp             = $63,
      F64GtOp             = $64,
      F64LeOp             = $65,
      F64GeOp             = $66,
      I32ClzOp            = $67,
      I32CtzOp            = $68,
      I32PopcntOp         = $69,
      I32AddOp            = $6A,
      I32SubOp            = $6B,
      I32MulOp            = $6C,
      I32DivSOp           = $6D,
      I32DivUOp           = $6E,
      I32RemSOp           = $6F,
      I32RemUOp           = $70,
      I32AndOp            = $71,
      I32OrOp             = $72,
      I32XorOp            = $73,
      I32ShlOp            = $74,
      I32ShrSOp           = $75,
      I32ShrUOp           = $76,
      I32RotlOp           = $77,
      I32RotrOp           = $78,
      I64ClzOp            = $79,
      I64CtzOp            = $7A,
      I64PopcntOp         = $7B,
      I64AddOp            = $7C,
      I64SubOp            = $7D,
      I64MulOp            = $7E,
      I64DivSOp           = $7F,
      I64DivUOp           = $80,
      I64RemSOp           = $81,
      I64RemUOp           = $82,
      I64AndOp            = $83,
      I64OrOp             = $84,
      I64XorOp            = $85,
      I64ShlOp            = $86,
      I64ShrSOp           = $87,
      I64ShrUOp           = $88,
      I64RotlOp           = $89,
      I64RotrOp           = $8A,
      { f32 arithmetic }
      F32AbsOp            = $8B,
      F32NegOp            = $8C,
      F32CeilOp           = $8D,
      F32FloorOp          = $8E,
      F32TruncOp          = $8F,
      F32NearestOp        = $90,
      F32SqrtOp           = $91,
      F32AddOp            = $92,
      F32SubOp            = $93,
      F32MulOp            = $94,
      F32DivOp            = $95,
      F32MinOp            = $96,
      F32MaxOp            = $97,
      F32CopysignOp       = $98,
      { f64 arithmetic }
      F64AbsOp            = $99,
      F64NegOp            = $9A,
      F64CeilOp           = $9B,
      F64FloorOp          = $9C,
      F64TruncOp          = $9D,
      F64NearestOp        = $9E,
      F64SqrtOp           = $9F,
      F64AddOp            = $A0,
      F64SubOp            = $A1,
      F64MulOp            = $A2,
      F64DivOp            = $A3,
      F64MinOp            = $A4,
      F64MaxOp            = $A5,
      F64CopysignOp       = $A6,
      { Conversion instructions }
      I32WrapI64Op        = $A7,
      I32TruncF32SOp      = $A8,
      I32TruncF32UOp      = $A9,
      I32TruncF64SOp      = $AA,
      I32TruncF64UOp      = $AB,
      I64ExtendI32SOp     = $AC,
      I64ExtendI32UOp     = $AD,
      I64TruncF32SOp      = $AE,
      I64TruncF32UOp      = $AF,
      I64TruncF64SOp      = $B0,
      I64TruncF64UOp      = $B1,
      F32ConvertI32SOp    = $B2,
      F32ConvertI32UOp    = $B3,
      F32ConvertI64SOp    = $B4,
      F32ConvertI64UOp    = $B5,
      F32DemoteF64Op      = $B6,
      F64ConvertI32SOp    = $B7,
      F64ConvertI32UOp    = $B8,
      F64ConvertI64SOp    = $B9,
      F64ConvertI64UOp    = $BA,
      F64PromoteF32Op     = $BB,
      I32ReinterpretF32Op = $BC,
      I64ReinterpretF64Op = $BD,
      F32ReinterpretI32Op = $BE,
      F64ReinterpretI64Op = $BF,
      I32Extend8SOp       = $C0,
      I32Extend16SOp      = $C1,
      I64Extend8SOp       = $C2,
      I64Extend16SOp      = $C3,
      I64Extend32SOp      = $C4,
      { Typed select }
      SelectTypedOp       = $1C,
      { Multi-byte prefix }
      FCPrefixOp          = $FC
    );

type
    uint128 = packed record
      low, high: TWASMUInt64;
    end;

function GetWasmValueTypeString(ValueType : TWasmValueType) : TWASMPChar;
function GetWasmTypeTypeString(TypeType : TWasmTypeType) : TWASMPChar;
function GetWasmBinarySectionIdString(SectionId : TWasmBinarySectionId) : TWASMPChar;
function GetWasmExportTypeString(ExportType : TWasmExportType) : TWASMPChar;
function GetWasmImportDescKindString(Kind : TWasmImportDescKind) : TWASMPChar;

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

function GetWasmImportDescKindString(Kind : TWasmImportDescKind) : TWASMPChar;
begin
    case Kind of
      idkFunc   : GetWasmImportDescKindString := 'Function';
      idkTable  : GetWasmImportDescKindString := 'Table';
      idkMemory : GetWasmImportDescKindString := 'Memory';
      idkGlobal : GetWasmImportDescKindString := 'Global';
      else GetWasmImportDescKindString := 'Unknown';
    end;
end;

end.
