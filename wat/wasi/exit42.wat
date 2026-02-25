;; exit42.wat — WASI proc_exit test
;; Calls proc_exit(42) immediately. Verify ExitCode=42.
;;
;; @expect-exit 42

(module
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  (memory (export "memory") 1)

  (func $main (export "_start")
    (call $proc_exit (i32.const 42))
  )
)
