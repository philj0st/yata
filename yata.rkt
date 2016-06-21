#lang racket
(require racket/string)
(require racket/generator)
(require "filesystem.rkt")
(require "dialog.rkt")

(define todos (load-list))

; toggling todos and save result
;(write (cons (add-todo) todos))

(save-list (toggle-todos todos))

(system "clear")
