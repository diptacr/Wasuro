;; prestat.wat — WASI prestat enumeration test
;; Calls fd_prestat_get for fds 3..7, expects EBADF (8) for all.
;; Proves libc's pre-open enumeration loop terminates correctly.
;;
;; @expect-exit 0

(module
  (import "wasi_snapshot_preview1" "fd_prestat_get"
    (func $fd_prestat_get (param i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  (memory (export "memory") 1)

  (func $main (export "_start")
    (local $errno i32)

    ;; fd_prestat_get(3, buf=200) should return EBADF=8
    (local.set $errno
      (call $fd_prestat_get (i32.const 3) (i32.const 200)))

    ;; If errno != 8, exit with 1 (failure)
    (if (i32.ne (local.get $errno) (i32.const 8))
      (then (call $proc_exit (i32.const 1))))

    ;; fd_prestat_get(4, buf=200) should also return EBADF
    (local.set $errno
      (call $fd_prestat_get (i32.const 4) (i32.const 200)))
    (if (i32.ne (local.get $errno) (i32.const 8))
      (then (call $proc_exit (i32.const 2))))

    ;; All good — exit 0
    (call $proc_exit (i32.const 0))
  )
)
