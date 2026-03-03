unit wasm.vm.opcodes.fc;

interface

uses
    wasm.types.builtin, wasm.types.context;

procedure init();
procedure _WASM_opcode_FCPrefix(Context : PWASMProcessContext);

implementation

uses
    wasm.vm.io, wasm.types.leb128, lmemorymanager,
    { Saturating truncation }
    wasm.vm.opcode.i32truncsatf32s, wasm.vm.opcode.i32truncsatf32u,
    wasm.vm.opcode.i32truncsatf64s, wasm.vm.opcode.i32truncsatf64u,
    wasm.vm.opcode.i64truncsatf32s, wasm.vm.opcode.i64truncsatf32u,
    wasm.vm.opcode.i64truncsatf64s, wasm.vm.opcode.i64truncsatf64u,
    { Bulk memory }
    wasm.vm.opcode.memoryinit, wasm.vm.opcode.datadrop,
    wasm.vm.opcode.memorycopy, wasm.vm.opcode.memoryfill,
    { Table operations }
    wasm.vm.opcode.tableinit, wasm.vm.opcode.elemdrop,
    wasm.vm.opcode.tablecopy, wasm.vm.opcode.tablegrow,
    wasm.vm.opcode.tablesize, wasm.vm.opcode.tablefill;

var
    FCJumpTable : PWASMFCOpcodeJumpTable;

procedure _WASM_opcode_FC_unimplemented(Context : PWASMProcessContext);
begin
    wasm.vm.io.writestringln('[wasm.vm] Unimplemented 0xFC sub-opcode');
    Context^.ExecutionState.Running := false;
end;

procedure init();
var i : TWASMUInt32;
begin
    {$IFDEF DEBUG_OUTPUT}
    wasm.vm.io.writestringln('[wasm.vm.opcodes.fc] Init FC Jump Table.');
    {$ENDIF}
    FCJumpTable := PWASMFCOpcodeJumpTable(kalloc(sizeof(TWASMFCOpcodeJumpTable)));

    { Default all to unimplemented }
    for i := 0 to 255 do
        FCJumpTable^[i] := @_WASM_opcode_FC_unimplemented;

    { Saturating truncation FC 00-07 }
    FCJumpTable^[$00] := @wasm.vm.opcode.i32truncsatf32s._WASM_opcode_I32TruncSatF32SOp;
    FCJumpTable^[$01] := @wasm.vm.opcode.i32truncsatf32u._WASM_opcode_I32TruncSatF32UOp;
    FCJumpTable^[$02] := @wasm.vm.opcode.i32truncsatf64s._WASM_opcode_I32TruncSatF64SOp;
    FCJumpTable^[$03] := @wasm.vm.opcode.i32truncsatf64u._WASM_opcode_I32TruncSatF64UOp;
    FCJumpTable^[$04] := @wasm.vm.opcode.i64truncsatf32s._WASM_opcode_I64TruncSatF32SOp;
    FCJumpTable^[$05] := @wasm.vm.opcode.i64truncsatf32u._WASM_opcode_I64TruncSatF32UOp;
    FCJumpTable^[$06] := @wasm.vm.opcode.i64truncsatf64s._WASM_opcode_I64TruncSatF64SOp;
    FCJumpTable^[$07] := @wasm.vm.opcode.i64truncsatf64u._WASM_opcode_I64TruncSatF64UOp;

    { Bulk memory FC 08-0B }
    FCJumpTable^[$08] := @wasm.vm.opcode.memoryinit._WASM_opcode_MemoryInitOp;
    FCJumpTable^[$09] := @wasm.vm.opcode.datadrop._WASM_opcode_DataDropOp;
    FCJumpTable^[$0A] := @wasm.vm.opcode.memorycopy._WASM_opcode_MemoryCopyOp;
    FCJumpTable^[$0B] := @wasm.vm.opcode.memoryfill._WASM_opcode_MemoryFillOp;

    { Table operations FC 0C-11 }
    FCJumpTable^[$0C] := @wasm.vm.opcode.tableinit._WASM_opcode_TableInitOp;
    FCJumpTable^[$0D] := @wasm.vm.opcode.elemdrop._WASM_opcode_ElemDropOp;
    FCJumpTable^[$0E] := @wasm.vm.opcode.tablecopy._WASM_opcode_TableCopyOp;
    FCJumpTable^[$0F] := @wasm.vm.opcode.tablegrow._WASM_opcode_TableGrowOp;
    FCJumpTable^[$10] := @wasm.vm.opcode.tablesize._WASM_opcode_TableSizeOp;
    FCJumpTable^[$11] := @wasm.vm.opcode.tablefill._WASM_opcode_TableFillOp;
end;

procedure _WASM_opcode_FCPrefix(Context : PWASMProcessContext);
var
    sub_opcode : TWASMUInt32;
    bytesRead : TWASMUInt8;
begin
    Inc(Context^.ExecutionState.IP); { skip $FC prefix byte }

    { Read sub-opcode as LEB128 }
    bytesRead := read_leb128_to_uint32(
        @Context^.ExecutionState.Code[Context^.ExecutionState.IP],
        TWASMPUInt8(Context^.ExecutionState.Code + Context^.ExecutionState.Limit),
        @sub_opcode);
    Inc(Context^.ExecutionState.IP, bytesRead);

    if sub_opcode > 255 then begin
        wasm.vm.io.writestringln('[wasm.vm] 0xFC sub-opcode out of range');
        Context^.ExecutionState.Running := false;
        exit;
    end;

    FCJumpTable^[sub_opcode](Context);
end;

end.
