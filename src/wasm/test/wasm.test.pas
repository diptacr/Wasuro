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
    wasm.test.parser.importsection,
    wasm.test.parser.tablesection,
    wasm.test.parser.elementsection,
    { Validation tests }
    wasm.test.parser.validate,
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
    { Table opcode tests }
    wasm.test.opcode.tableget,
    wasm.test.opcode.tableset,
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
    { F32 arithmetic tests }
    wasm.test.opcode.f32abs,
    wasm.test.opcode.f32neg,
    wasm.test.opcode.f32ceil,
    wasm.test.opcode.f32floor,
    wasm.test.opcode.f32trunc,
    wasm.test.opcode.f32nearest,
    wasm.test.opcode.f32sqrt,
    wasm.test.opcode.f32add,
    wasm.test.opcode.f32sub,
    wasm.test.opcode.f32mul,
    wasm.test.opcode.f32div,
    wasm.test.opcode.f32min,
    wasm.test.opcode.f32max,
    wasm.test.opcode.f32copysign,
    { F64 arithmetic tests }
    wasm.test.opcode.f64abs,
    wasm.test.opcode.f64neg,
    wasm.test.opcode.f64ceil,
    wasm.test.opcode.f64floor,
    wasm.test.opcode.f64trunc,
    wasm.test.opcode.f64nearest,
    wasm.test.opcode.f64sqrt,
    wasm.test.opcode.f64add,
    wasm.test.opcode.f64sub,
    wasm.test.opcode.f64mul,
    wasm.test.opcode.f64div,
    wasm.test.opcode.f64min,
    wasm.test.opcode.f64max,
    wasm.test.opcode.f64copysign,
    { Conversion/truncation tests }
    wasm.test.opcode.i32wrapi64,
    wasm.test.opcode.i32truncf32s,
    wasm.test.opcode.i32truncf32u,
    wasm.test.opcode.i32truncf64s,
    wasm.test.opcode.i32truncf64u,
    wasm.test.opcode.i64extendi32s,
    wasm.test.opcode.i64extendi32u,
    wasm.test.opcode.i64truncf32s,
    wasm.test.opcode.i64truncf32u,
    wasm.test.opcode.i64truncf64s,
    wasm.test.opcode.i64truncf64u,
    wasm.test.opcode.f32converti32s,
    wasm.test.opcode.f32converti32u,
    wasm.test.opcode.f32converti64s,
    wasm.test.opcode.f32converti64u,
    wasm.test.opcode.f32demotef64,
    wasm.test.opcode.f64converti32s,
    wasm.test.opcode.f64converti32u,
    wasm.test.opcode.f64converti64s,
    wasm.test.opcode.f64converti64u,
    wasm.test.opcode.f64promotef32,
    wasm.test.opcode.i32reinterpretf32,
    wasm.test.opcode.i64reinterpretf64,
    wasm.test.opcode.f32reinterpreti32,
    wasm.test.opcode.f64reinterpreti64,
    wasm.test.opcode.i32extend8s,
    wasm.test.opcode.i32extend16s,
    wasm.test.opcode.i64extend8s,
    wasm.test.opcode.i64extend16s,
    wasm.test.opcode.i64extend32s,
    { Typed select test }
    wasm.test.opcode.selecttyped,
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
    { Saturating truncation tests (0xFC $00-$07) }
    wasm.test.opcode.i32truncsatf32s,
    wasm.test.opcode.i32truncsatf32u,
    wasm.test.opcode.i32truncsatf64s,
    wasm.test.opcode.i32truncsatf64u,
    wasm.test.opcode.i64truncsatf32s,
    wasm.test.opcode.i64truncsatf32u,
    wasm.test.opcode.i64truncsatf64s,
    wasm.test.opcode.i64truncsatf64u,
    { Bulk memory tests (0xFC $08-$0B) }
    wasm.test.opcode.memoryinit,
    wasm.test.opcode.datadrop,
    wasm.test.opcode.memorycopy,
    wasm.test.opcode.memoryfill,
    { Table ops tests (0xFC $0C-$11) }
    wasm.test.opcode.tableinit,
    wasm.test.opcode.elemdrop,
    wasm.test.opcode.tablecopy,
    wasm.test.opcode.tablegrow,
    wasm.test.opcode.tablesize,
    wasm.test.opcode.tablefill,
    { Parser tests }
    wasm.test.parser.datacount,
    wasm.test.parser.passivedata,
    { End-to-end binary tests }
    wasm.test.binary.return42,
    wasm.test.binary.addnums,
    wasm.test.binary.arithmetic,
    wasm.test.binary.locals,
    wasm.test.binary.memroundtrip,
    wasm.test.binary.controlflow,
    { WASI tests }
    wasm.test.wasi.types,
    wasm.test.wasi.registry,
    wasm.test.wasi.hooks,
    wasm.test.wasi.call,
    wasm.test.wasi.glue,
    wasm.test.wasi.clock,
    wasm.test.wasi.random,
    wasm.test.wasi.stubs,
    wasm.test.wasi.extensibility,
    { Glue unit }
    wasm.test.glue,
    { VM setup }
    wasm.test.vm.setup;

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
    wasm.test.parser.importsection.run;
    wasm.test.parser.tablesection.run;
    wasm.test.parser.elementsection.run;

    { Validation }
    wasm.test.parser.validate.run;

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

    { Table opcodes }
    wasm.test.opcode.tableget.run;
    wasm.test.opcode.tableset.run;

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

    { F32 arithmetic }
    wasm.test.opcode.f32abs.run;
    wasm.test.opcode.f32neg.run;
    wasm.test.opcode.f32ceil.run;
    wasm.test.opcode.f32floor.run;
    wasm.test.opcode.f32trunc.run;
    wasm.test.opcode.f32nearest.run;
    wasm.test.opcode.f32sqrt.run;
    wasm.test.opcode.f32add.run;
    wasm.test.opcode.f32sub.run;
    wasm.test.opcode.f32mul.run;
    wasm.test.opcode.f32div.run;
    wasm.test.opcode.f32min.run;
    wasm.test.opcode.f32max.run;
    wasm.test.opcode.f32copysign.run;

    { F64 arithmetic }
    wasm.test.opcode.f64abs.run;
    wasm.test.opcode.f64neg.run;
    wasm.test.opcode.f64ceil.run;
    wasm.test.opcode.f64floor.run;
    wasm.test.opcode.f64trunc.run;
    wasm.test.opcode.f64nearest.run;
    wasm.test.opcode.f64sqrt.run;
    wasm.test.opcode.f64add.run;
    wasm.test.opcode.f64sub.run;
    wasm.test.opcode.f64mul.run;
    wasm.test.opcode.f64div.run;
    wasm.test.opcode.f64min.run;
    wasm.test.opcode.f64max.run;
    wasm.test.opcode.f64copysign.run;

    { Conversion/truncation }
    wasm.test.opcode.i32wrapi64.run;
    wasm.test.opcode.i32truncf32s.run;
    wasm.test.opcode.i32truncf32u.run;
    wasm.test.opcode.i32truncf64s.run;
    wasm.test.opcode.i32truncf64u.run;
    wasm.test.opcode.i64extendi32s.run;
    wasm.test.opcode.i64extendi32u.run;
    wasm.test.opcode.i64truncf32s.run;
    wasm.test.opcode.i64truncf32u.run;
    wasm.test.opcode.i64truncf64s.run;
    wasm.test.opcode.i64truncf64u.run;
    wasm.test.opcode.f32converti32s.run;
    wasm.test.opcode.f32converti32u.run;
    wasm.test.opcode.f32converti64s.run;
    wasm.test.opcode.f32converti64u.run;
    wasm.test.opcode.f32demotef64.run;
    wasm.test.opcode.f64converti32s.run;
    wasm.test.opcode.f64converti32u.run;
    wasm.test.opcode.f64converti64s.run;
    wasm.test.opcode.f64converti64u.run;
    wasm.test.opcode.f64promotef32.run;
    wasm.test.opcode.i32reinterpretf32.run;
    wasm.test.opcode.i64reinterpretf64.run;
    wasm.test.opcode.f32reinterpreti32.run;
    wasm.test.opcode.f64reinterpreti64.run;
    wasm.test.opcode.i32extend8s.run;
    wasm.test.opcode.i32extend16s.run;
    wasm.test.opcode.i64extend8s.run;
    wasm.test.opcode.i64extend16s.run;
    wasm.test.opcode.i64extend32s.run;

    { Typed select }
    wasm.test.opcode.selecttyped.run;

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

    { Saturating truncation (0xFC $00-$07) }
    wasm.test.opcode.i32truncsatf32s.run;
    wasm.test.opcode.i32truncsatf32u.run;
    wasm.test.opcode.i32truncsatf64s.run;
    wasm.test.opcode.i32truncsatf64u.run;
    wasm.test.opcode.i64truncsatf32s.run;
    wasm.test.opcode.i64truncsatf32u.run;
    wasm.test.opcode.i64truncsatf64s.run;
    wasm.test.opcode.i64truncsatf64u.run;

    { Bulk memory (0xFC $08-$0B) }
    wasm.test.opcode.memoryinit.run;
    wasm.test.opcode.datadrop.run;
    wasm.test.opcode.memorycopy.run;
    wasm.test.opcode.memoryfill.run;

    { Table ops (0xFC $0C-$11) }
    wasm.test.opcode.tableinit.run;
    wasm.test.opcode.elemdrop.run;
    wasm.test.opcode.tablecopy.run;
    wasm.test.opcode.tablegrow.run;
    wasm.test.opcode.tablesize.run;
    wasm.test.opcode.tablefill.run;

    { Parser tests }
    wasm.test.parser.datacount.run;
    wasm.test.parser.passivedata.run;

    { End-to-end binary tests }
    wasm.test.binary.return42.run;
    wasm.test.binary.addnums.run;
    wasm.test.binary.arithmetic.run;
    wasm.test.binary.locals.run;
    wasm.test.binary.memroundtrip.run;
    wasm.test.binary.controlflow.run;

    { WASI }
    wasm.test.wasi.types.run;
    wasm.test.wasi.registry.run;
    wasm.test.wasi.hooks.run;
    wasm.test.wasi.call.run;
    wasm.test.wasi.glue.run;
    wasm.test.wasi.clock.run;
    wasm.test.wasi.random.run;
    wasm.test.wasi.stubs.run;
    wasm.test.wasi.extensibility.run;

    { Glue unit }
    wasm.test.glue.run;

    { VM setup }
    wasm.test.vm.setup.run;

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
