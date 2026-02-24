unit wasm.test.opcode.elemdrop;

interface

procedure run;

implementation

uses
    wasm.types.builtin, wasm.types.sections, wasm.types.context,
    wasm.vm, wasm.test.framework, lmemorymanager;

procedure run;
var
    { FC $0D, elem_idx=0 }
    code : array[0..2] of TWASMUInt8;
    ctx : PWASMProcessContext;
begin
    test_begin('opcode.elem.drop');

    code[0] := $FC; code[1] := $0D; code[2] := $00;

    { Drop an element segment }
    ctx := make_test_context(@code[0], 3);
    ctx^.ExecutionState.ElementSegments^.SegmentCount := 1;
    ctx^.ExecutionState.ElementSegments^.Segments := PWASMElementSegment(kalloc(sizeof(TWASMElementSegment)));
    ctx^.ExecutionState.ElementSegments^.Segments[0].FuncCount := 2;
    ctx^.ExecutionState.ElementSegments^.Segments[0].FuncIndices := TWASMPUInt32(kalloc(2 * sizeof(TWASMUInt32)));
    ctx^.ExecutionState.ElementSegments^.Segments[0].Dropped := false;
    wasm.vm.tick(ctx);
    assert_true('segment dropped', ctx^.ExecutionState.ElementSegments^.Segments[0].Dropped);
    assert_true('still running', ctx^.ExecutionState.Running);

    { Drop invalid index traps }
    ctx := make_test_context(@code[0], 3);
    { SegmentCount = 0 (default), so elem_idx=0 is out of range }
    wasm.vm.tick(ctx);
    assert_true('invalid_idx traps', not ctx^.ExecutionState.Running);

    test_end;
end;

end.
