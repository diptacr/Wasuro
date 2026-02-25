;; hello.wat — WASI "Hello, World!" test program
;; Writes "Hello, World!\n" to stdout via fd_write, then exits with code 0.
;;
;; @expect-exit 0
;; @expect-stdout Hello, World!

(module
  ;; Import fd_write from WASI
  (import "wasi_snapshot_preview1" "fd_write"
    (func $fd_write (param i32 i32 i32 i32) (result i32)))

  ;; Import proc_exit from WASI
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  ;; 1 page of linear memory (64KB), exported as "memory"
  (memory (export "memory") 1)

  ;; "Hello, World!\n" at offset 8
  (data (i32.const 8) "Hello, World!\n")

  ;; iovec at offset 0: { buf_ptr=8, buf_len=14 }
  (data (i32.const 0) "\08\00\00\00"  ;; buf ptr = 8
                       "\0e\00\00\00") ;; buf len = 14

  (func $main (export "_start")
    ;; fd_write(stdout=1, iovs=0, iovs_len=1, nwritten=100)
    (call $fd_write
      (i32.const 1)    ;; fd = stdout
      (i32.const 0)    ;; iovs pointer
      (i32.const 1)    ;; iovs count
      (i32.const 100)  ;; nwritten pointer
    )
    drop ;; discard errno

    ;; proc_exit(0)
    (call $proc_exit (i32.const 0))
  )
)
