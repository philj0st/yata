#lang racket

; writes list to savefile-path
; http://docs.racket-lang.org/reference/file-ports.html
(provide save-list)
(define (save-list list)
  (write-to-file list (get-savefile-path ) #:exists 'truncate/replace))

; reads list from savefile-path
(provide load-list)
(define (load-list)
  (file->value (get-savefile-path)))

; returns ex. #<path:/home/phil/.racket/yata>
(provide get-savefile-path)
(define (get-savefile-path)
  (build-path (find-system-path 'home-dir) ".racket" "yata" "todos.rkt"))
