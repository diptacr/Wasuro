;; clock.wat — WASI clock_time_get test
;; Calls clock_time_get for realtime clock, verifies ESUCCESS (exit 0)
;; @expect-exit 0
(module
  (import "wasi_snapshot_preview1" "clock_time_get"
    (func $clock_time_get (param i32 i64 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  (memory (export "memory") 1)

  (func (export "_start")
    (local $errno i32)
    ;; clock_time_get(clock_id=0 [realtime], precision=1000, time_ptr=0)
    (local.set $errno
      (call $clock_time_get
        (i32.const 0)      ;; CLOCK_REALTIME
        (i64.const 1000)   ;; precision
        (i32.const 0)))    ;; time output pointer

    ;; Exit with errno (should be 0 = ESUCCESS)
    (call $proc_exit (local.get $errno))
  )
)
