unit wasm.vm.opcodes;

interface

uses
    console, wasm.types.builtin, wasm.types.enums, wasm.types.context;

procedure initializeOpcodeJumpTable(Table : PWASMOpcodeJumpTable);

implementation

uses
    { Control flow }
    wasm.vm.opcode.unreachable, wasm.vm.opcode.nop,
    wasm.vm.opcode.block, wasm.vm.opcode.loop,
    wasm.vm.opcode.ifop, wasm.vm.opcode.elseop, wasm.vm.opcode.endop,
    wasm.vm.opcode.br, wasm.vm.opcode.brif, wasm.vm.opcode.brtable,
    wasm.vm.opcode.return, wasm.vm.opcode.call, wasm.vm.opcode.callindirect,
    { Parametric }
    wasm.vm.opcode.drop, wasm.vm.opcode.select,
    { Variable }
    wasm.vm.opcode.localget, wasm.vm.opcode.localset, wasm.vm.opcode.localtee,
    wasm.vm.opcode.globalget, wasm.vm.opcode.globalset,
    { Memory loads }
    wasm.vm.opcode.i32load, wasm.vm.opcode.i64load,
    wasm.vm.opcode.f32load, wasm.vm.opcode.f64load,
    wasm.vm.opcode.i32load8s, wasm.vm.opcode.i32load8u,
    wasm.vm.opcode.i32load16s, wasm.vm.opcode.i32load16u,
    wasm.vm.opcode.i64load8s, wasm.vm.opcode.i64load8u,
    wasm.vm.opcode.i64load16s, wasm.vm.opcode.i64load16u,
    wasm.vm.opcode.i64load32s, wasm.vm.opcode.i64load32u,
    { Memory stores }
    wasm.vm.opcode.i32store, wasm.vm.opcode.i64store,
    wasm.vm.opcode.f32store, wasm.vm.opcode.f64store,
    wasm.vm.opcode.i32store8, wasm.vm.opcode.i32store16,
    wasm.vm.opcode.i64store8, wasm.vm.opcode.i64store16, wasm.vm.opcode.i64store32,
    { Memory management }
    wasm.vm.opcode.memorysize, wasm.vm.opcode.memorygrow,
    { Constants }
    wasm.vm.opcode.i32const, wasm.vm.opcode.i64const,
    wasm.vm.opcode.f32const, wasm.vm.opcode.f64const,
    { i32 comparison }
    wasm.vm.opcode.i32eqz, wasm.vm.opcode.i32eq, wasm.vm.opcode.i32ne,
    wasm.vm.opcode.i32lts, wasm.vm.opcode.i32ltu,
    wasm.vm.opcode.i32gts, wasm.vm.opcode.i32gtu,
    wasm.vm.opcode.i32les, wasm.vm.opcode.i32leu,
    wasm.vm.opcode.i32ges, wasm.vm.opcode.i32geu,
    { i64 comparison }
    wasm.vm.opcode.i64eqz, wasm.vm.opcode.i64eq, wasm.vm.opcode.i64ne,
    wasm.vm.opcode.i64lts, wasm.vm.opcode.i64ltu,
    wasm.vm.opcode.i64gts, wasm.vm.opcode.i64gtu,
    wasm.vm.opcode.i64les, wasm.vm.opcode.i64leu,
    wasm.vm.opcode.i64ges, wasm.vm.opcode.i64geu,
    { f32 comparison }
    wasm.vm.opcode.f32eq, wasm.vm.opcode.f32ne,
    wasm.vm.opcode.f32lt, wasm.vm.opcode.f32gt,
    wasm.vm.opcode.f32le, wasm.vm.opcode.f32ge,
    { f64 comparison }
    wasm.vm.opcode.f64eq, wasm.vm.opcode.f64ne,
    wasm.vm.opcode.f64lt, wasm.vm.opcode.f64gt,
    wasm.vm.opcode.f64le, wasm.vm.opcode.f64ge,
    { i32 arithmetic }
    wasm.vm.opcode.i32clz, wasm.vm.opcode.i32ctz, wasm.vm.opcode.i32popcnt,
    wasm.vm.opcode.i32add, wasm.vm.opcode.i32sub, wasm.vm.opcode.i32mul,
    wasm.vm.opcode.i32divs, wasm.vm.opcode.i32divu,
    wasm.vm.opcode.i32rems, wasm.vm.opcode.i32remu,
    wasm.vm.opcode.i32and, wasm.vm.opcode.i32or, wasm.vm.opcode.i32xor,
    wasm.vm.opcode.i32shl, wasm.vm.opcode.i32shrs, wasm.vm.opcode.i32shru,
    wasm.vm.opcode.i32rotl, wasm.vm.opcode.i32rotr,
    { i64 arithmetic }
    wasm.vm.opcode.i64clz, wasm.vm.opcode.i64ctz, wasm.vm.opcode.i64popcnt,
    wasm.vm.opcode.i64add, wasm.vm.opcode.i64sub, wasm.vm.opcode.i64mul,
    wasm.vm.opcode.i64divs, wasm.vm.opcode.i64divu,
    wasm.vm.opcode.i64rems, wasm.vm.opcode.i64remu,
    wasm.vm.opcode.i64and, wasm.vm.opcode.i64or, wasm.vm.opcode.i64xor,
    wasm.vm.opcode.i64shl, wasm.vm.opcode.i64shrs, wasm.vm.opcode.i64shru,
    wasm.vm.opcode.i64rotl, wasm.vm.opcode.i64rotr;

procedure initializeOpcodeJumpTable(Table: PWASMOpcodeJumpTable);
begin
    console.writestringln('[wasm.vm.opcodes] Init Opcode Jump Table.');
    if (Table = nil) then exit;
    Table^[ord(TWasmOpcode.UnreachableOp)]  := @wasm.vm.opcode.unreachable._WASM_opcode_UnreachableOp;
    Table^[ord(TWasmOpcode.NopOp)]          := @wasm.vm.opcode.nop._WASM_opcode_NopOp;
    Table^[ord(TWasmOpcode.BlockOp)]        := @wasm.vm.opcode.block._WASM_opcode_BlockOp;
    Table^[ord(TWasmOpcode.LoopOp)]         := @wasm.vm.opcode.loop._WASM_opcode_LoopOp;
    Table^[ord(TWasmOpcode.IfOp)]           := @wasm.vm.opcode.ifop._WASM_opcode_IfOp;
    Table^[ord(TWasmOpcode.ElseOp)]         := @wasm.vm.opcode.elseop._WASM_opcode_ElseOp;
    Table^[ord(TWasmOpcode.EndOp)]          := @wasm.vm.opcode.endop._WASM_opcode_EndOp;
    Table^[ord(TWasmOpcode.BrOp)]           := @wasm.vm.opcode.br._WASM_opcode_BrOp;
    Table^[ord(TWasmOpcode.BrIfOp)]         := @wasm.vm.opcode.brif._WASM_opcode_BrIfOp;
    Table^[ord(TWasmOpcode.BrTableOp)]      := @wasm.vm.opcode.brtable._WASM_opcode_BrTableOp;
    Table^[ord(TWasmOpcode.ReturnOp)]       := @wasm.vm.opcode.return._WASM_opcode_ReturnOp;
    Table^[ord(TWasmOpcode.CallOp)]         := @wasm.vm.opcode.call._WASM_opcode_CallOp;
    Table^[ord(TWasmOpcode.CallIndirectOp)] := @wasm.vm.opcode.callindirect._WASM_opcode_CallIndirectOp;
    Table^[ord(TWasmOpcode.DropOp)]         := @wasm.vm.opcode.drop._WASM_opcode_DropOp;
    Table^[ord(TWasmOpcode.SelectOp)]       := @wasm.vm.opcode.select._WASM_opcode_SelectOp;
    Table^[ord(TWasmOpcode.LocalGetOp)]     := @wasm.vm.opcode.localget._WASM_opcode_LocalGetOp;
    Table^[ord(TWasmOpcode.LocalSetOp)]     := @wasm.vm.opcode.localset._WASM_opcode_LocalSetOp;
    Table^[ord(TWasmOpcode.LocalTeeOp)]     := @wasm.vm.opcode.localtee._WASM_opcode_LocalTeeOp;
    Table^[ord(TWasmOpcode.GlobalGetOp)]    := @wasm.vm.opcode.globalget._WASM_opcode_GlobalGetOp;
    Table^[ord(TWasmOpcode.GlobalSetOp)]    := @wasm.vm.opcode.globalset._WASM_opcode_GlobalSetOp;
    Table^[ord(TWasmOpcode.I32LoadOp)]      := @wasm.vm.opcode.i32load._WASM_opcode_I32LoadOp;
    Table^[ord(TWasmOpcode.I64LoadOp)]      := @wasm.vm.opcode.i64load._WASM_opcode_I64LoadOp;
    Table^[ord(TWasmOpcode.F32LoadOp)]      := @wasm.vm.opcode.f32load._WASM_opcode_F32LoadOp;
    Table^[ord(TWasmOpcode.F64LoadOp)]      := @wasm.vm.opcode.f64load._WASM_opcode_F64LoadOp;
    Table^[ord(TWasmOpcode.I32Load8SOp)]    := @wasm.vm.opcode.i32load8s._WASM_opcode_I32Load8SOp;
    Table^[ord(TWasmOpcode.I32Load8UOp)]    := @wasm.vm.opcode.i32load8u._WASM_opcode_I32Load8UOp;
    Table^[ord(TWasmOpcode.I32Load16SOp)]   := @wasm.vm.opcode.i32load16s._WASM_opcode_I32Load16SOp;
    Table^[ord(TWasmOpcode.I32Load16UOp)]   := @wasm.vm.opcode.i32load16u._WASM_opcode_I32Load16UOp;
    Table^[ord(TWasmOpcode.I64Load8SOp)]    := @wasm.vm.opcode.i64load8s._WASM_opcode_I64Load8SOp;
    Table^[ord(TWasmOpcode.I64Load8UOp)]    := @wasm.vm.opcode.i64load8u._WASM_opcode_I64Load8UOp;
    Table^[ord(TWasmOpcode.I64Load16SOp)]   := @wasm.vm.opcode.i64load16s._WASM_opcode_I64Load16SOp;
    Table^[ord(TWasmOpcode.I64Load16UOp)]   := @wasm.vm.opcode.i64load16u._WASM_opcode_I64Load16UOp;
    Table^[ord(TWasmOpcode.I64Load32SOp)]   := @wasm.vm.opcode.i64load32s._WASM_opcode_I64Load32SOp;
    Table^[ord(TWasmOpcode.I64Load32UOp)]   := @wasm.vm.opcode.i64load32u._WASM_opcode_I64Load32UOp;
    Table^[ord(TWasmOpcode.I32StoreOp)]     := @wasm.vm.opcode.i32store._WASM_opcode_I32StoreOp;
    Table^[ord(TWasmOpcode.I64StoreOp)]     := @wasm.vm.opcode.i64store._WASM_opcode_I64StoreOp;
    Table^[ord(TWasmOpcode.F32StoreOp)]     := @wasm.vm.opcode.f32store._WASM_opcode_F32StoreOp;
    Table^[ord(TWasmOpcode.F64StoreOp)]     := @wasm.vm.opcode.f64store._WASM_opcode_F64StoreOp;
    Table^[ord(TWasmOpcode.I32Store8Op)]    := @wasm.vm.opcode.i32store8._WASM_opcode_I32Store8Op;
    Table^[ord(TWasmOpcode.I32Store16Op)]   := @wasm.vm.opcode.i32store16._WASM_opcode_I32Store16Op;
    Table^[ord(TWasmOpcode.I64Store8Op)]    := @wasm.vm.opcode.i64store8._WASM_opcode_I64Store8Op;
    Table^[ord(TWasmOpcode.I64Store16Op)]   := @wasm.vm.opcode.i64store16._WASM_opcode_I64Store16Op;
    Table^[ord(TWasmOpcode.I64Store32Op)]   := @wasm.vm.opcode.i64store32._WASM_opcode_I64Store32Op;
    Table^[ord(TWasmOpcode.MemorySizeOp)]   := @wasm.vm.opcode.memorysize._WASM_opcode_MemorySizeOp;
    Table^[ord(TWasmOpcode.MemoryGrowOp)]   := @wasm.vm.opcode.memorygrow._WASM_opcode_MemoryGrowOp;
    Table^[ord(TWasmOpcode.I32ConstOp)]     := @wasm.vm.opcode.i32const._WASM_opcode_I32ConstOp;
    Table^[ord(TWasmOpcode.I64ConstOp)]     := @wasm.vm.opcode.i64const._WASM_opcode_I64ConstOp;
    Table^[ord(TWasmOpcode.F32ConstOp)]     := @wasm.vm.opcode.f32const._WASM_opcode_F32ConstOp;
    Table^[ord(TWasmOpcode.F64ConstOp)]     := @wasm.vm.opcode.f64const._WASM_opcode_F64ConstOp;
    Table^[ord(TWasmOpcode.I32EqzOp)]       := @wasm.vm.opcode.i32eqz._WASM_opcode_I32EqzOp;
    Table^[ord(TWasmOpcode.I32EqOp)]        := @wasm.vm.opcode.i32eq._WASM_opcode_I32EqOp;
    Table^[ord(TWasmOpcode.I32NeOp)]        := @wasm.vm.opcode.i32ne._WASM_opcode_I32NeOp;
    Table^[ord(TWasmOpcode.I32LtSOp)]       := @wasm.vm.opcode.i32lts._WASM_opcode_I32LtSOp;
    Table^[ord(TWasmOpcode.I32LtUOp)]       := @wasm.vm.opcode.i32ltu._WASM_opcode_I32LtUOp;
    Table^[ord(TWasmOpcode.I32GtSOp)]       := @wasm.vm.opcode.i32gts._WASM_opcode_I32GtSOp;
    Table^[ord(TWasmOpcode.I32GtUOp)]       := @wasm.vm.opcode.i32gtu._WASM_opcode_I32GtUOp;
    Table^[ord(TWasmOpcode.I32LeSOp)]       := @wasm.vm.opcode.i32les._WASM_opcode_I32LeSOp;
    Table^[ord(TWasmOpcode.I32LeUOp)]       := @wasm.vm.opcode.i32leu._WASM_opcode_I32LeUOp;
    Table^[ord(TWasmOpcode.I32GeSOp)]       := @wasm.vm.opcode.i32ges._WASM_opcode_I32GeSOp;
    Table^[ord(TWasmOpcode.I32GeUOp)]       := @wasm.vm.opcode.i32geu._WASM_opcode_I32GeUOp;
    Table^[ord(TWasmOpcode.I64EqzOp)]       := @wasm.vm.opcode.i64eqz._WASM_opcode_I64EqzOp;
    Table^[ord(TWasmOpcode.I64EqOp)]        := @wasm.vm.opcode.i64eq._WASM_opcode_I64EqOp;
    Table^[ord(TWasmOpcode.I64NeOp)]        := @wasm.vm.opcode.i64ne._WASM_opcode_I64NeOp;
    Table^[ord(TWasmOpcode.I64LtSOp)]       := @wasm.vm.opcode.i64lts._WASM_opcode_I64LtSOp;
    Table^[ord(TWasmOpcode.I64LtUOp)]       := @wasm.vm.opcode.i64ltu._WASM_opcode_I64LtUOp;
    Table^[ord(TWasmOpcode.I64GtSOp)]       := @wasm.vm.opcode.i64gts._WASM_opcode_I64GtSOp;
    Table^[ord(TWasmOpcode.I64GtUOp)]       := @wasm.vm.opcode.i64gtu._WASM_opcode_I64GtUOp;
    Table^[ord(TWasmOpcode.I64LeSOp)]       := @wasm.vm.opcode.i64les._WASM_opcode_I64LeSOp;
    Table^[ord(TWasmOpcode.I64LeUOp)]       := @wasm.vm.opcode.i64leu._WASM_opcode_I64LeUOp;
    Table^[ord(TWasmOpcode.I64GeSOp)]       := @wasm.vm.opcode.i64ges._WASM_opcode_I64GeSOp;
    Table^[ord(TWasmOpcode.I64GeUOp)]       := @wasm.vm.opcode.i64geu._WASM_opcode_I64GeUOp;
    Table^[ord(TWasmOpcode.F32EqOp)]        := @wasm.vm.opcode.f32eq._WASM_opcode_F32EqOp;
    Table^[ord(TWasmOpcode.F32NeOp)]        := @wasm.vm.opcode.f32ne._WASM_opcode_F32NeOp;
    Table^[ord(TWasmOpcode.F32LtOp)]        := @wasm.vm.opcode.f32lt._WASM_opcode_F32LtOp;
    Table^[ord(TWasmOpcode.F32GtOp)]        := @wasm.vm.opcode.f32gt._WASM_opcode_F32GtOp;
    Table^[ord(TWasmOpcode.F32LeOp)]        := @wasm.vm.opcode.f32le._WASM_opcode_F32LeOp;
    Table^[ord(TWasmOpcode.F32GeOp)]        := @wasm.vm.opcode.f32ge._WASM_opcode_F32GeOp;
    Table^[ord(TWasmOpcode.F64EqOp)]        := @wasm.vm.opcode.f64eq._WASM_opcode_F64EqOp;
    Table^[ord(TWasmOpcode.F64NeOp)]        := @wasm.vm.opcode.f64ne._WASM_opcode_F64NeOp;
    Table^[ord(TWasmOpcode.F64LtOp)]        := @wasm.vm.opcode.f64lt._WASM_opcode_F64LtOp;
    Table^[ord(TWasmOpcode.F64GtOp)]        := @wasm.vm.opcode.f64gt._WASM_opcode_F64GtOp;
    Table^[ord(TWasmOpcode.F64LeOp)]        := @wasm.vm.opcode.f64le._WASM_opcode_F64LeOp;
    Table^[ord(TWasmOpcode.F64GeOp)]        := @wasm.vm.opcode.f64ge._WASM_opcode_F64GeOp;
    Table^[ord(TWasmOpcode.I32ClzOp)]       := @wasm.vm.opcode.i32clz._WASM_opcode_I32ClzOp;
    Table^[ord(TWasmOpcode.I32CtzOp)]       := @wasm.vm.opcode.i32ctz._WASM_opcode_I32CtzOp;
    Table^[ord(TWasmOpcode.I32PopcntOp)]    := @wasm.vm.opcode.i32popcnt._WASM_opcode_I32PopcntOp;
    Table^[ord(TWasmOpcode.I32AddOp)]       := @wasm.vm.opcode.i32add._WASM_opcode_I32AddOp;
    Table^[ord(TWasmOpcode.I32SubOp)]       := @wasm.vm.opcode.i32sub._WASM_opcode_I32SubOp;
    Table^[ord(TWasmOpcode.I32MulOp)]       := @wasm.vm.opcode.i32mul._WASM_opcode_I32MulOp;
    Table^[ord(TWasmOpcode.I32DivSOp)]      := @wasm.vm.opcode.i32divs._WASM_opcode_I32DivSOp;
    Table^[ord(TWasmOpcode.I32DivUOp)]      := @wasm.vm.opcode.i32divu._WASM_opcode_I32DivUOp;
    Table^[ord(TWasmOpcode.I32RemSOp)]      := @wasm.vm.opcode.i32rems._WASM_opcode_I32RemSOp;
    Table^[ord(TWasmOpcode.I32RemUOp)]      := @wasm.vm.opcode.i32remu._WASM_opcode_I32RemUOp;
    Table^[ord(TWasmOpcode.I32AndOp)]       := @wasm.vm.opcode.i32and._WASM_opcode_I32AndOp;
    Table^[ord(TWasmOpcode.I32OrOp)]        := @wasm.vm.opcode.i32or._WASM_opcode_I32OrOp;
    Table^[ord(TWasmOpcode.I32XorOp)]       := @wasm.vm.opcode.i32xor._WASM_opcode_I32XorOp;
    Table^[ord(TWasmOpcode.I32ShlOp)]       := @wasm.vm.opcode.i32shl._WASM_opcode_I32ShlOp;
    Table^[ord(TWasmOpcode.I32ShrSOp)]      := @wasm.vm.opcode.i32shrs._WASM_opcode_I32ShrSOp;
    Table^[ord(TWasmOpcode.I32ShrUOp)]      := @wasm.vm.opcode.i32shru._WASM_opcode_I32ShrUOp;
    Table^[ord(TWasmOpcode.I32RotlOp)]      := @wasm.vm.opcode.i32rotl._WASM_opcode_I32RotlOp;
    Table^[ord(TWasmOpcode.I32RotrOp)]      := @wasm.vm.opcode.i32rotr._WASM_opcode_I32RotrOp;
    Table^[ord(TWasmOpcode.I64ClzOp)]       := @wasm.vm.opcode.i64clz._WASM_opcode_I64ClzOp;
    Table^[ord(TWasmOpcode.I64CtzOp)]       := @wasm.vm.opcode.i64ctz._WASM_opcode_I64CtzOp;
    Table^[ord(TWasmOpcode.I64PopcntOp)]    := @wasm.vm.opcode.i64popcnt._WASM_opcode_I64PopcntOp;
    Table^[ord(TWasmOpcode.I64AddOp)]       := @wasm.vm.opcode.i64add._WASM_opcode_I64AddOp;
    Table^[ord(TWasmOpcode.I64SubOp)]       := @wasm.vm.opcode.i64sub._WASM_opcode_I64SubOp;
    Table^[ord(TWasmOpcode.I64MulOp)]       := @wasm.vm.opcode.i64mul._WASM_opcode_I64MulOp;
    Table^[ord(TWasmOpcode.I64DivSOp)]      := @wasm.vm.opcode.i64divs._WASM_opcode_I64DivSOp;
    Table^[ord(TWasmOpcode.I64DivUOp)]      := @wasm.vm.opcode.i64divu._WASM_opcode_I64DivUOp;
    Table^[ord(TWasmOpcode.I64RemSOp)]      := @wasm.vm.opcode.i64rems._WASM_opcode_I64RemSOp;
    Table^[ord(TWasmOpcode.I64RemUOp)]      := @wasm.vm.opcode.i64remu._WASM_opcode_I64RemUOp;
    Table^[ord(TWasmOpcode.I64AndOp)]       := @wasm.vm.opcode.i64and._WASM_opcode_I64AndOp;
    Table^[ord(TWasmOpcode.I64OrOp)]        := @wasm.vm.opcode.i64or._WASM_opcode_I64OrOp;
    Table^[ord(TWasmOpcode.I64XorOp)]       := @wasm.vm.opcode.i64xor._WASM_opcode_I64XorOp;
    Table^[ord(TWasmOpcode.I64ShlOp)]       := @wasm.vm.opcode.i64shl._WASM_opcode_I64ShlOp;
    Table^[ord(TWasmOpcode.I64ShrSOp)]      := @wasm.vm.opcode.i64shrs._WASM_opcode_I64ShrSOp;
    Table^[ord(TWasmOpcode.I64ShrUOp)]      := @wasm.vm.opcode.i64shru._WASM_opcode_I64ShrUOp;
    Table^[ord(TWasmOpcode.I64RotlOp)]      := @wasm.vm.opcode.i64rotl._WASM_opcode_I64RotlOp;
    Table^[ord(TWasmOpcode.I64RotrOp)]      := @wasm.vm.opcode.i64rotr._WASM_opcode_I64RotrOp;
end;

end.

