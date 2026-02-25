;; fdstat.wat — WASI fd_fdstat_get test
;; Calls fd_fdstat_get for stdout (fd=1), expects ESUCCESS.
;; Checks that filetype byte = 2 (CHARACTER_DEVICE).
;;
;; @expect-exit 0

(module
  (import "wasi_snapshot_preview1" "fd_fdstat_get"
    (func $fd_fdstat_get (param i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  (memory (export "memory") 1)

  (func $main (export "_start")
    (local $errno i32)

    ;; fd_fdstat_get(fd=1, buf=0) — write fdstat struct at offset 0
    (local.set $errno
      (call $fd_fdstat_get (i32.const 1) (i32.const 0)))

    ;; Should return ESUCCESS=0
    (if (i32.ne (local.get $errno) (i32.const 0))
      (then (call $proc_exit (i32.const 1))))

    ;; First byte (filetype) should be 2 (CHARACTER_DEVICE)
    (if (i32.ne (i32.load8_u (i32.const 0)) (i32.const 2))
      (then (call $proc_exit (i32.const 2))))

    ;; All good
    (call $proc_exit (i32.const 0))
  )
)
