;; environ.wat — WASI environ test
;; Calls environ_sizes_get, expects count=0 and buf_size=0.
;;
;; @expect-exit 0

(module
  (import "wasi_snapshot_preview1" "environ_sizes_get"
    (func $environ_sizes_get (param i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  (memory (export "memory") 1)

  (func $main (export "_start")
    (local $errno i32)

    ;; environ_sizes_get(count_ptr=0, buf_size_ptr=4)
    (local.set $errno
      (call $environ_sizes_get (i32.const 0) (i32.const 4)))

    ;; Should return ESUCCESS=0
    (if (i32.ne (local.get $errno) (i32.const 0))
      (then (call $proc_exit (i32.const 1))))

    ;; count at offset 0 should be 0
    (if (i32.ne (i32.load (i32.const 0)) (i32.const 0))
      (then (call $proc_exit (i32.const 2))))

    ;; buf_size at offset 4 should be 0
    (if (i32.ne (i32.load (i32.const 4)) (i32.const 0))
      (then (call $proc_exit (i32.const 3))))

    ;; All good
    (call $proc_exit (i32.const 0))
  )
)
