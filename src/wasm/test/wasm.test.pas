unit wasm.test;

interface

procedure run_all_tests;

implementation

uses
    console, wasm.test.framework,
    { Infra tests }
    wasm.test.stack,
    wasm.test.heap,
    wasm.test.leb128,
    { Parser tests }
    wasm.test.parser.typesection,
    wasm.test.parser.functionsection,
    wasm.test.parser.exportsection,
    wasm.test.parser.code,
    wasm.test.parser.global,
    wasm.test.parser.memory,
    wasm.test.parser.start,
    wasm.test.parser.data,
    { Const/control opcode tests }
    wasm.test.opcode.nop,
    wasm.test.opcode.unreachable,
    wasm.test.opcode.drop,
    wasm.test.opcode.select,
    wasm.test.opcode.i32const,
    wasm.test.opcode.i64const,
    wasm.test.opcode.f32const,
    wasm.test.opcode.f64const,
    wasm.test.opcode.return,
    wasm.test.opcode.block,
    wasm.test.opcode.loop,
    wasm.test.opcode.ifop,
    wasm.test.opcode.elseop,
    wasm.test.opcode.endop,
    wasm.test.opcode.br,
    wasm.test.opcode.brif,
    wasm.test.opcode.brtable,
    wasm.test.opcode.call,
    wasm.test.opcode.callindirect,
    { Variable opcode tests }
    wasm.test.opcode.localget,
    wasm.test.opcode.localset,
    wasm.test.opcode.localtee,
    wasm.test.opcode.globalget,
    wasm.test.opcode.globalset,
    { I32 comparison tests }
    wasm.test.opcode.i32eqz,
    wasm.test.opcode.i32eq,
    wasm.test.opcode.i32ne,
    wasm.test.opcode.i32lts,
    wasm.test.opcode.i32ltu,
    wasm.test.opcode.i32gts,
    wasm.test.opcode.i32gtu,
    wasm.test.opcode.i32les,
    wasm.test.opcode.i32leu,
    wasm.test.opcode.i32ges,
    wasm.test.opcode.i32geu,
    { I32 arithmetic tests }
    wasm.test.opcode.i32add,
    wasm.test.opcode.i32sub,
    wasm.test.opcode.i32mul,
    wasm.test.opcode.i32divs,
    wasm.test.opcode.i32divu,
    wasm.test.opcode.i32rems,
    wasm.test.opcode.i32remu,
    wasm.test.opcode.i32clz,
    wasm.test.opcode.i32ctz,
    wasm.test.opcode.i32popcnt,
    { I32 bitwise tests }
    wasm.test.opcode.i32and,
    wasm.test.opcode.i32or,
    wasm.test.opcode.i32xor,
    wasm.test.opcode.i32shl,
    wasm.test.opcode.i32shrs,
    wasm.test.opcode.i32shru,
    wasm.test.opcode.i32rotl,
    wasm.test.opcode.i32rotr,
    { I64 comparison tests }
    wasm.test.opcode.i64eqz,
    wasm.test.opcode.i64eq,
    wasm.test.opcode.i64ne,
    wasm.test.opcode.i64lts,
    wasm.test.opcode.i64ltu,
    wasm.test.opcode.i64gts,
    wasm.test.opcode.i64gtu,
    wasm.test.opcode.i64les,
    wasm.test.opcode.i64leu,
    wasm.test.opcode.i64ges,
    wasm.test.opcode.i64geu,
    { I64 arithmetic tests }
    wasm.test.opcode.i64add,
    wasm.test.opcode.i64sub,
    wasm.test.opcode.i64mul,
    wasm.test.opcode.i64divs,
    wasm.test.opcode.i64divu,
    wasm.test.opcode.i64rems,
    wasm.test.opcode.i64remu,
    wasm.test.opcode.i64clz,
    wasm.test.opcode.i64ctz,
    wasm.test.opcode.i64popcnt,
    { I64 bitwise tests }
    wasm.test.opcode.i64and,
    wasm.test.opcode.i64or,
    wasm.test.opcode.i64xor,
    wasm.test.opcode.i64shl,
    wasm.test.opcode.i64shrs,
    wasm.test.opcode.i64shru,
    wasm.test.opcode.i64rotl,
    wasm.test.opcode.i64rotr,
    { F32 comparison tests }
    wasm.test.opcode.f32eq,
    wasm.test.opcode.f32ne,
    wasm.test.opcode.f32lt,
    wasm.test.opcode.f32gt,
    wasm.test.opcode.f32le,
    wasm.test.opcode.f32ge,
    { F64 comparison tests }
    wasm.test.opcode.f64eq,
    wasm.test.opcode.f64ne,
    wasm.test.opcode.f64lt,
    wasm.test.opcode.f64gt,
    wasm.test.opcode.f64le,
    wasm.test.opcode.f64ge,
    { Memory load tests }
    wasm.test.opcode.i32load,
    wasm.test.opcode.i64load,
    wasm.test.opcode.f32load,
    wasm.test.opcode.f64load,
    wasm.test.opcode.i32load8s,
    wasm.test.opcode.i32load8u,
    wasm.test.opcode.i32load16s,
    wasm.test.opcode.i32load16u,
    wasm.test.opcode.i64load8s,
    wasm.test.opcode.i64load8u,
    wasm.test.opcode.i64load16s,
    wasm.test.opcode.i64load16u,
    wasm.test.opcode.i64load32s,
    wasm.test.opcode.i64load32u,
    { Memory store tests }
    wasm.test.opcode.i32store,
    wasm.test.opcode.i64store,
    wasm.test.opcode.f32store,
    wasm.test.opcode.f64store,
    wasm.test.opcode.i32store8,
    wasm.test.opcode.i32store16,
    wasm.test.opcode.i64store8,
    wasm.test.opcode.i64store16,
    wasm.test.opcode.i64store32,
    { Memory size/grow tests }
    wasm.test.opcode.memorysize,
    wasm.test.opcode.memorygrow,
    { End-to-end binary tests }
    wasm.test.binary.return42,
    wasm.test.binary.addnums,
    wasm.test.binary.arithmetic,
    wasm.test.binary.locals,
    wasm.test.binary.memroundtrip,
    wasm.test.binary.controlflow;

procedure run_all_tests;
begin
    writestringln('========================================');
    writestringln('  WASURO Test Suite');
    writestringln('========================================');

    reset_test_state;

    { Infra }
    wasm.test.stack.run;
    wasm.test.heap.run;
    wasm.test.leb128.run;

    { Parsers }
    wasm.test.parser.typesection.run;
    wasm.test.parser.functionsection.run;
    wasm.test.parser.exportsection.run;
    wasm.test.parser.code.run;
    wasm.test.parser.global.run;
    wasm.test.parser.memory.run;
    wasm.test.parser.start.run;
    wasm.test.parser.data.run;

    { Const/control opcodes }
    wasm.test.opcode.nop.run;
    wasm.test.opcode.unreachable.run;
    wasm.test.opcode.drop.run;
    wasm.test.opcode.select.run;
    wasm.test.opcode.i32const.run;
    wasm.test.opcode.i64const.run;
    wasm.test.opcode.f32const.run;
    wasm.test.opcode.f64const.run;
    wasm.test.opcode.return.run;
    wasm.test.opcode.block.run;
    wasm.test.opcode.loop.run;
    wasm.test.opcode.ifop.run;
    wasm.test.opcode.elseop.run;
    wasm.test.opcode.endop.run;
    wasm.test.opcode.br.run;
    wasm.test.opcode.brif.run;
    wasm.test.opcode.brtable.run;
    wasm.test.opcode.call.run;
    wasm.test.opcode.callindirect.run;

    { Variable opcodes }
    wasm.test.opcode.localget.run;
    wasm.test.opcode.localset.run;
    wasm.test.opcode.localtee.run;
    wasm.test.opcode.globalget.run;
    wasm.test.opcode.globalset.run;

    { I32 comparisons }
    wasm.test.opcode.i32eqz.run;
    wasm.test.opcode.i32eq.run;
    wasm.test.opcode.i32ne.run;
    wasm.test.opcode.i32lts.run;
    wasm.test.opcode.i32ltu.run;
    wasm.test.opcode.i32gts.run;
    wasm.test.opcode.i32gtu.run;
    wasm.test.opcode.i32les.run;
    wasm.test.opcode.i32leu.run;
    wasm.test.opcode.i32ges.run;
    wasm.test.opcode.i32geu.run;

    { I32 arithmetic }
    wasm.test.opcode.i32add.run;
    wasm.test.opcode.i32sub.run;
    wasm.test.opcode.i32mul.run;
    wasm.test.opcode.i32divs.run;
    wasm.test.opcode.i32divu.run;
    wasm.test.opcode.i32rems.run;
    wasm.test.opcode.i32remu.run;
    wasm.test.opcode.i32clz.run;
    wasm.test.opcode.i32ctz.run;
    wasm.test.opcode.i32popcnt.run;

    { I32 bitwise }
    wasm.test.opcode.i32and.run;
    wasm.test.opcode.i32or.run;
    wasm.test.opcode.i32xor.run;
    wasm.test.opcode.i32shl.run;
    wasm.test.opcode.i32shrs.run;
    wasm.test.opcode.i32shru.run;
    wasm.test.opcode.i32rotl.run;
    wasm.test.opcode.i32rotr.run;

    { I64 comparisons }
    wasm.test.opcode.i64eqz.run;
    wasm.test.opcode.i64eq.run;
    wasm.test.opcode.i64ne.run;
    wasm.test.opcode.i64lts.run;
    wasm.test.opcode.i64ltu.run;
    wasm.test.opcode.i64gts.run;
    wasm.test.opcode.i64gtu.run;
    wasm.test.opcode.i64les.run;
    wasm.test.opcode.i64leu.run;
    wasm.test.opcode.i64ges.run;
    wasm.test.opcode.i64geu.run;

    { I64 arithmetic }
    wasm.test.opcode.i64add.run;
    wasm.test.opcode.i64sub.run;
    wasm.test.opcode.i64mul.run;
    wasm.test.opcode.i64divs.run;
    wasm.test.opcode.i64divu.run;
    wasm.test.opcode.i64rems.run;
    wasm.test.opcode.i64remu.run;
    wasm.test.opcode.i64clz.run;
    wasm.test.opcode.i64ctz.run;
    wasm.test.opcode.i64popcnt.run;

    { I64 bitwise }
    wasm.test.opcode.i64and.run;
    wasm.test.opcode.i64or.run;
    wasm.test.opcode.i64xor.run;
    wasm.test.opcode.i64shl.run;
    wasm.test.opcode.i64shrs.run;
    wasm.test.opcode.i64shru.run;
    wasm.test.opcode.i64rotl.run;
    wasm.test.opcode.i64rotr.run;

    { F32 comparisons }
    wasm.test.opcode.f32eq.run;
    wasm.test.opcode.f32ne.run;
    wasm.test.opcode.f32lt.run;
    wasm.test.opcode.f32gt.run;
    wasm.test.opcode.f32le.run;
    wasm.test.opcode.f32ge.run;

    { F64 comparisons }
    wasm.test.opcode.f64eq.run;
    wasm.test.opcode.f64ne.run;
    wasm.test.opcode.f64lt.run;
    wasm.test.opcode.f64gt.run;
    wasm.test.opcode.f64le.run;
    wasm.test.opcode.f64ge.run;

    { Memory loads }
    wasm.test.opcode.i32load.run;
    wasm.test.opcode.i64load.run;
    wasm.test.opcode.f32load.run;
    wasm.test.opcode.f64load.run;
    wasm.test.opcode.i32load8s.run;
    wasm.test.opcode.i32load8u.run;
    wasm.test.opcode.i32load16s.run;
    wasm.test.opcode.i32load16u.run;
    wasm.test.opcode.i64load8s.run;
    wasm.test.opcode.i64load8u.run;
    wasm.test.opcode.i64load16s.run;
    wasm.test.opcode.i64load16u.run;
    wasm.test.opcode.i64load32s.run;
    wasm.test.opcode.i64load32u.run;

    { Memory stores }
    wasm.test.opcode.i32store.run;
    wasm.test.opcode.i64store.run;
    wasm.test.opcode.f32store.run;
    wasm.test.opcode.f64store.run;
    wasm.test.opcode.i32store8.run;
    wasm.test.opcode.i32store16.run;
    wasm.test.opcode.i64store8.run;
    wasm.test.opcode.i64store16.run;
    wasm.test.opcode.i64store32.run;

    { Memory size/grow }
    wasm.test.opcode.memorysize.run;
    wasm.test.opcode.memorygrow.run;

    { End-to-end binary tests }
    wasm.test.binary.return42.run;
    wasm.test.binary.addnums.run;
    wasm.test.binary.arithmetic.run;
    wasm.test.binary.locals.run;
    wasm.test.binary.memroundtrip.run;
    wasm.test.binary.controlflow.run;

    { Summary }
    writestringln('');
    writestringln('========================================');
    writestringln('  Test Results');
    writestringln('========================================');
    writestring('  Total:  ');
    writeintlnWND(TotalTests, 0);
    writestring('  Passed: ');
    writeintlnWND(PassedTests, 0);
    writestring('  Failed: ');
    writeintlnWND(FailedTests, 0);
    writestringln('========================================');
end;

end.
