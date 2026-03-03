unit wasm.types.builtin;

interface

uses
    types;

type
    { Unsigned integers }
    TWASMUInt8  = uint8;
    TWASMUInt16 = uint16;
    TWASMUInt32 = uint32;
    TWASMUInt64 = uint64;

    { Signed integers }
    TWASMSInt8  = sint8;
    TWASMSInt16 = sint16;
    TWASMInt32  = sint32;
    TWASMInt64  = sint64;

    { Floating point }
    TWASMFloat  = float;
    TWASMDouble = double;

    { Pointer types }
    TWASMPUInt8  = puint8;
    TWASMPUInt16 = puint16;
    TWASMPUInt32 = puint32;
    TWASMPUInt64 = puint64;
    TWASMPFloat  = pfloat;
    TWASMPDouble = pdouble;
    TWASMPChar   = pchar;

    { Other }
    TWASMBoolean = boolean;
    TWASMChar    = char;
    TWASMVoid    = void;

implementation

end.
