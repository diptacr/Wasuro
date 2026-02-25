;; multiwrite.wat — WASI fd_write with multiple iovecs
;; Writes "AB" then "CD" as two separate iovecs in one fd_write call.
;;
;; @expect-exit 0
;; @expect-stdout ABCD

(module
  (import "wasi_snapshot_preview1" "fd_write"
    (func $fd_write (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit"
    (func $proc_exit (param i32)))

  (memory (export "memory") 1)

  ;; String data
  (data (i32.const 100) "AB")  ;; 2 bytes at offset 100
  (data (i32.const 110) "CD")  ;; 2 bytes at offset 110

  ;; iovec array at offset 0 (2 entries, 8 bytes each)
  ;; iovec[0] = { ptr=100, len=2 }
  (data (i32.const 0) "\64\00\00\00"   ;; buf ptr = 100
                       "\02\00\00\00")  ;; buf len = 2
  ;; iovec[1] = { ptr=110, len=2 }
  (data (i32.const 8) "\6e\00\00\00"   ;; buf ptr = 110
                       "\02\00\00\00")  ;; buf len = 2

  (func $main (export "_start")
    ;; fd_write(stdout=1, iovs=0, iovs_len=2, nwritten=200)
    (call $fd_write
      (i32.const 1)    ;; fd = stdout
      (i32.const 0)    ;; iovs pointer
      (i32.const 2)    ;; iovs count = 2
      (i32.const 200)  ;; nwritten pointer
    )
    drop

    (call $proc_exit (i32.const 0))
  )
)
