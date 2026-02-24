unit wasm.parser.sections;

interface

uses
    wasm.types.builtin,
    wasm.types.enums, wasm.types.context,
    wasm.parser.sections.customSection,
    wasm.parser.sections.typeSection,
    wasm.parser.sections.importSection,
    wasm.parser.sections.functionSection,
    wasm.parser.sections.tableSection,
    wasm.parser.sections.memorySection,
    wasm.parser.sections.globalSection,
    wasm.parser.sections.exportSection,
    wasm.parser.sections.startSection,
    wasm.parser.sections.elementSection,
    wasm.parser.sections.codeSection,
    wasm.parser.sections.dataSection,
    wasm.parser.sections.dataCountSection;

procedure handle(sectionId : TWASMUInt8; buffer : TWASMPUInt8; section_length : TWASMUInt32; ctx : PWASMProcessContext);

implementation

procedure handle(sectionId : TWASMUInt8; buffer : TWASMPUInt8; section_length : TWASMUInt32; ctx : PWASMProcessContext);
begin
    // Handle the section
    case sectionId of
        // Custom Section
        ord(sidCustom):   wasm.parser.sections.customSection.handle    (buffer, section_length, ctx);
        // Type Section
        ord(sidType):     wasm.parser.sections.typeSection.handle      (buffer, section_length, ctx);
        // Import Section
        ord(sidImport):   wasm.parser.sections.importSection.handle    (buffer, section_length, ctx);
        // Function Section
        ord(sidFunction): wasm.parser.sections.functionSection.handle  (buffer, section_length, ctx);
        // Table Section
        ord(sidTable):    wasm.parser.sections.tableSection.handle     (buffer, section_length, ctx);
        // Memory Section
        ord(sidMemory):   wasm.parser.sections.memorySection.handle    (buffer, section_length, ctx);
        // Global Section
        ord(sidGlobal):   wasm.parser.sections.globalSection.handle    (buffer, section_length, ctx);
        // Export Section
        ord(sidExport):   wasm.parser.sections.exportSection.handle    (buffer, section_length, ctx);
        // Start Section
        ord(sidStart):    wasm.parser.sections.startSection.handle     (buffer, section_length, ctx);
        // Element Section
        ord(sidElement):  wasm.parser.sections.elementSection.handle   (buffer, section_length, ctx);
        // Code Section
        ord(sidCode):     wasm.parser.sections.codeSection.handle      (buffer, section_length, ctx);
        // Data Section
        ord(sidData):     wasm.parser.sections.dataSection.handle      (buffer, section_length, ctx);
        // DataCount Section
        ord(sidDataCount): wasm.parser.sections.dataCountSection.handle (buffer, section_length, ctx);
    end;
end;

end.
