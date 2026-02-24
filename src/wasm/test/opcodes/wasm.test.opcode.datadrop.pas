unit wasm.test.opcode.datadrop;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.sections, wasm.types.context,
    wasm.vm, wasm.test.framework, lmemorymanager;

procedure run;
var
    { FC $09, data_idx=0 }
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
    segData : array[0..1] of TWASMUInt8;
begin
    test_begin('opcode.data.drop');

    code[0] := $FC; code[1] := $09; code[2] := $00;

    { Drop a data segment }
    segData[0] := $11; segData[1] := $22;
    ctx := make_test_context(@code[0], 3);
    ctx^.ExecutionState.DataSegments^.SegmentCount := 1;
    ctx^.ExecutionState.DataSegments^.Segments := PWASMDataSegment(kalloc(sizeof(TWASMDataSegment)));
    ctx^.ExecutionState.DataSegments^.Segments[0].Data := @segData[0];
    ctx^.ExecutionState.DataSegments^.Segments[0].Size := 2;
    ctx^.ExecutionState.DataSegments^.Segments[0].Dropped := false;
    wasm.vm.tick(ctx);
    assert_true('segment dropped', ctx^.ExecutionState.DataSegments^.Segments[0].Dropped);
    assert_true('still running', ctx^.ExecutionState.Running);

    { Drop invalid index traps }
    ctx := make_test_context(@code[0], 3);
    { SegmentCount = 0 (default), so data_idx=0 is out of range }
    wasm.vm.tick(ctx);
    assert_true('invalid_idx traps', not ctx^.ExecutionState.Running);

    test_end;
end;

end.
