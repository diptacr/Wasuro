;; clockres.wat — WASI clock_res_get test
;; Calls clock_res_get for realtime clock, verifies ESUCCESS (exit 0)
;; @expect-exit 0
(module
  (import "wasi_snapshot_preview1" "clock_res_get"
    (func $clock_res_get (param i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  (memory (export "memory") 1)

  (func (export "_start")
    (local $errno i32)
    ;; clock_res_get(clock_id=0 [realtime], resolution_ptr=0)
    (local.set $errno
      (call $clock_res_get
        (i32.const 0)     ;; CLOCK_REALTIME
        (i32.const 0)))   ;; resolution output pointer

    ;; Exit with errno (should be 0 = ESUCCESS)
    (call $proc_exit (local.get $errno))
  )
)
