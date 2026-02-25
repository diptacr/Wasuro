unit wasm.types.wasi;

interface

uses
    wasm.types.builtin;

const
    { WASI errno codes }
    WASI_ESUCCESS        = 0;
    WASI_E2BIG           = 1;
    WASI_EACCES          = 2;
    WASI_EADDRINUSE      = 3;
    WASI_EADDRNOTAVAIL   = 4;
    WASI_EAFNOSUPPORT    = 5;
    WASI_EAGAIN          = 6;
    WASI_EALREADY        = 7;
    WASI_EBADF           = 8;
    WASI_EBADMSG         = 9;
    WASI_EBUSY           = 10;
    WASI_ECANCELED       = 11;
    WASI_ECHILDPROCESS   = 12;
    WASI_ECONNABORTED    = 13;
    WASI_ECONNREFUSED    = 14;
    WASI_ECONNRESET      = 15;
    WASI_EDEADLK         = 16;
    WASI_EDESTADDRREQ    = 17;
    WASI_EDOM            = 18;
    WASI_EDQUOT          = 19;
    WASI_EEXIST          = 20;
    WASI_EFAULT          = 21;
    WASI_EFBIG           = 22;
    WASI_EHOSTUNREACH    = 23;
    WASI_EIDRM           = 24;
    WASI_EILSEQ          = 25;
    WASI_EINPROGRESS     = 26;
    WASI_EINTR           = 27;
    WASI_EINVAL          = 28;
    WASI_EIO             = 29;
    WASI_EISCONN         = 30;
    WASI_EISDIR          = 31;
    WASI_ELOOP           = 32;
    WASI_EMFILE          = 33;
    WASI_EMLINK          = 34;
    WASI_EMSGSIZE        = 35;
    WASI_EMULTIHOP       = 36;
    WASI_ENAMETOOLONG    = 37;
    WASI_ENETDOWN        = 38;
    WASI_ENETRESET       = 39;
    WASI_ENETUNREACH     = 40;
    WASI_ENFILE          = 41;
    WASI_ENOBUFS         = 42;
    WASI_ENODEV          = 43;
    WASI_ENOENT          = 44;
    WASI_ENOEXEC         = 45;
    WASI_ENOLCK          = 46;
    WASI_ENOLINK         = 47;
    WASI_ENOMEM          = 48;
    WASI_ENOMSG          = 49;
    WASI_ENOPROTOOPT     = 50;
    WASI_ENOSPC          = 51;
    WASI_ENOSYS          = 52;
    WASI_ENOTCONN        = 53;
    WASI_ENOTDIR         = 54;
    WASI_ENOTEMPTY       = 55;
    WASI_ENOTRECOVERABLE = 56;
    WASI_ENOTSOCK        = 57;
    WASI_ENOTSUP         = 58;
    WASI_ENOTTY          = 59;
    WASI_ENXIO           = 60;
    WASI_EOVERFLOW       = 61;
    WASI_EOWNERDEAD      = 62;
    WASI_EPERM           = 63;
    WASI_EPIPE           = 64;
    WASI_EPROTO          = 65;
    WASI_EPROTONOSUPPORT = 66;
    WASI_EPROTOTYPE      = 67;
    WASI_ERANGE          = 68;
    WASI_EROFS           = 69;
    WASI_ESPIPE          = 70;
    WASI_ESRCH           = 71;
    WASI_ESTALE          = 72;
    WASI_ETIMEDOUT       = 73;
    WASI_ETXTBSY         = 74;
    WASI_EXDEV           = 75;
    WASI_ENOTCAPABLE     = 76;

    { Standard file descriptors }
    WASI_FD_STDIN  = 0;
    WASI_FD_STDOUT = 1;
    WASI_FD_STDERR = 2;

    { fd_fdstat_get filetype values }
    WASI_FILETYPE_UNKNOWN          = 0;
    WASI_FILETYPE_BLOCK_DEVICE     = 1;
    WASI_FILETYPE_CHARACTER_DEVICE = 2;
    WASI_FILETYPE_DIRECTORY        = 3;
    WASI_FILETYPE_REGULAR_FILE     = 4;
    WASI_FILETYPE_SOCKET_DGRAM     = 5;
    WASI_FILETYPE_SOCKET_STREAM    = 6;
    WASI_FILETYPE_SYMBOLIC_LINK    = 7;

    { fd_prestat types }
    WASI_PREOPENTYPE_DIR = 0;

    { fd_seek whence }
    WASI_WHENCE_SET = 0;
    WASI_WHENCE_CUR = 1;
    WASI_WHENCE_END = 2;

type
    { iovec - scatter/gather I/O vector (in WASM linear memory) }
    { Layout: buf_ptr:i32 (offset into memory), buf_len:i32 }
    TWASIIoVec = record
        BufPtr : TWASMUInt32;  { pointer into linear memory }
        BufLen : TWASMUInt32;  { length in bytes }
    end;
    PWASIIoVec = ^TWASIIoVec;

    { fd_fdstat - file descriptor status }
    TWASIFdStat = record
        FileType   : TWASMUInt8;    { WASI_FILETYPE_* }
        Flags      : TWASMUInt16;   { fdflags }
        RightsBase : TWASMUInt64;   { fs_rights_base }
        RightsInheriting : TWASMUInt64; { fs_rights_inheriting }
    end;
    PWASIFdStat = ^TWASIFdStat;

    { prestat - pre-opened fd info }
    TWASIPrestat = record
        Tag     : TWASMUInt8;    { WASI_PREOPENTYPE_DIR }
        NameLen : TWASMUInt32;   { length of the dir name }
    end;
    PWASIPrestat = ^TWASIPrestat;

implementation

end.
