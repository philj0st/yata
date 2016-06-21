#lang racket
(provide dialog->string WINDOW-WIDTH WINDOW-HEIGHT)

; Constants
(define DIALOG "dialog")
(define WINDOW-WIDTH "60")
(define WINDOW-HEIGHT "18")
; takes a list of option strings and returns the stderr as a string
(define dialog->string
  (lambda (options)
    (call-with-output-string
     (lambda (listener-port)
       ((fifth ; grab the fifth return value from the system call
         ; spawn whiptail/dialog process and redirect the stderr to the call-with-string (p)
         (apply process*/ports
                (current-output-port)
                (current-input-port)
                listener-port
                (find-executable-path DIALOG)
                options))'wait)))))
