;; random.wat — WASI random_get test
;; Calls random_get to fill 8 bytes, verifies ESUCCESS (exit 0)
;; @expect-exit 0
(module
  (import "wasi_snapshot_preview1" "random_get"
    (func $random_get (param i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  (memory (export "memory") 1)

  (func (export "_start")
    (local $errno i32)
    ;; random_get(buf=0, buf_len=8)
    (local.set $errno
      (call $random_get
        (i32.const 0)    ;; buf pointer
        (i32.const 8)))  ;; 8 bytes

    ;; Exit with errno (should be 0 = ESUCCESS)
    (call $proc_exit (local.get $errno))
  )
)
