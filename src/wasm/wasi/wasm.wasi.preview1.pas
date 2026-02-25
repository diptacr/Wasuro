unit wasm.wasi.preview1;

interface

uses
    wasm.types.context;

{ Register all WASI preview1 glue callbacks into the given context }
procedure register_all(ctx : PWASMProcessContext);

implementation

uses
    wasm.wasi.registry,
    wasm.wasi.preview1.fd.write, wasm.wasi.preview1.fd.read, wasm.wasi.preview1.fd.close,
    wasm.wasi.preview1.fd.seek, wasm.wasi.preview1.fd.prestat, wasm.wasi.preview1.fd.fdstat,
    wasm.wasi.preview1.proc.exit, wasm.wasi.preview1.environ, wasm.wasi.preview1.args,
    wasm.wasi.preview1.clock, wasm.wasi.preview1.random,
    wasm.wasi.preview1.fd.stubs, wasm.wasi.preview1.path, wasm.wasi.preview1.poll, wasm.wasi.preview1.sock;

const
    WASI_MODULE = 'wasi_snapshot_preview1';

procedure register_all(ctx : PWASMProcessContext);
begin
    { Tier 1 - stdio + process }
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_write', @wasm.wasi.preview1.fd.write._WASI_fd_write);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_read', @wasm.wasi.preview1.fd.read._WASI_fd_read);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_close', @wasm.wasi.preview1.fd.close._WASI_fd_close);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_seek', @wasm.wasi.preview1.fd.seek._WASI_fd_seek);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_prestat_get', @wasm.wasi.preview1.fd.prestat._WASI_fd_prestat_get);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_prestat_dir_name', @wasm.wasi.preview1.fd.prestat._WASI_fd_prestat_dir_name);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_fdstat_get', @wasm.wasi.preview1.fd.fdstat._WASI_fd_fdstat_get);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'proc_exit', @wasm.wasi.preview1.proc.exit._WASI_proc_exit);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'environ_sizes_get', @wasm.wasi.preview1.environ._WASI_environ_sizes_get);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'environ_get', @wasm.wasi.preview1.environ._WASI_environ_get);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'args_sizes_get', @wasm.wasi.preview1.args._WASI_args_sizes_get);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'args_get', @wasm.wasi.preview1.args._WASI_args_get);

    { Tier 2 - clocks + random }
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'clock_time_get', @wasm.wasi.preview1.clock._WASI_clock_time_get);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'clock_res_get', @wasm.wasi.preview1.clock._WASI_clock_res_get);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'random_get', @wasm.wasi.preview1.random._WASI_random_get);

    { Tier 3 - filesystem fd_* stubs }
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_readdir', @wasm.wasi.preview1.fd.stubs._WASI_fd_readdir);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_filestat_get', @wasm.wasi.preview1.fd.stubs._WASI_fd_filestat_get);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_filestat_set_size', @wasm.wasi.preview1.fd.stubs._WASI_fd_filestat_set_size);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_filestat_set_times', @wasm.wasi.preview1.fd.stubs._WASI_fd_filestat_set_times);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_pread', @wasm.wasi.preview1.fd.stubs._WASI_fd_pread);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_pwrite', @wasm.wasi.preview1.fd.stubs._WASI_fd_pwrite);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_sync', @wasm.wasi.preview1.fd.stubs._WASI_fd_sync);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_datasync', @wasm.wasi.preview1.fd.stubs._WASI_fd_datasync);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_tell', @wasm.wasi.preview1.fd.stubs._WASI_fd_tell);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_advise', @wasm.wasi.preview1.fd.stubs._WASI_fd_advise);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_allocate', @wasm.wasi.preview1.fd.stubs._WASI_fd_allocate);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_renumber', @wasm.wasi.preview1.fd.stubs._WASI_fd_renumber);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_fdstat_set_flags', @wasm.wasi.preview1.fd.stubs._WASI_fd_fdstat_set_flags);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'fd_fdstat_set_rights', @wasm.wasi.preview1.fd.stubs._WASI_fd_fdstat_set_rights);

    { Tier 3 - filesystem path_* stubs }
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'path_open', @wasm.wasi.preview1.path._WASI_path_open);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'path_filestat_get', @wasm.wasi.preview1.path._WASI_path_filestat_get);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'path_create_directory', @wasm.wasi.preview1.path._WASI_path_create_directory);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'path_remove_directory', @wasm.wasi.preview1.path._WASI_path_remove_directory);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'path_unlink_file', @wasm.wasi.preview1.path._WASI_path_unlink_file);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'path_rename', @wasm.wasi.preview1.path._WASI_path_rename);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'path_readlink', @wasm.wasi.preview1.path._WASI_path_readlink);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'path_symlink', @wasm.wasi.preview1.path._WASI_path_symlink);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'path_link', @wasm.wasi.preview1.path._WASI_path_link);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'path_filestat_set_times', @wasm.wasi.preview1.path._WASI_path_filestat_set_times);

    { Tier 4 - poll + scheduler }
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'poll_oneoff', @wasm.wasi.preview1.poll._WASI_poll_oneoff);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'proc_raise', @wasm.wasi.preview1.poll._WASI_proc_raise);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'sched_yield', @wasm.wasi.preview1.poll._WASI_sched_yield);

    { Tier 4 - socket stubs }
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'sock_recv', @wasm.wasi.preview1.sock._WASI_sock_recv);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'sock_send', @wasm.wasi.preview1.sock._WASI_sock_send);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'sock_shutdown', @wasm.wasi.preview1.sock._WASI_sock_shutdown);
    wasm.wasi.registry.register_host_func(ctx,
        WASI_MODULE, 'sock_accept', @wasm.wasi.preview1.sock._WASI_sock_accept);
end;

end.
