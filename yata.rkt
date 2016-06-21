#lang racket
(require racket/cmdline)
(require "filesystem.rkt")
(require "dialog.rkt")

(define add-todo-flag? (make-parameter #f))
(define menu-flag? (make-parameter #f))
(define help-flag? (make-parameter #f))

(define mode
  (command-line
   #:program "yata"
   #:once-each
   [("-n" "--new") "Add new Todo"
                       (save-list (cons (add-todo) (load-list)))]
   [("-m" "--menu") "Display graphical menu"
                       (menu-flag? #t)]
   ))


;(define todos (load-list))

; toggling todos and save result
(save-list (toggle-todos (load-list)))
;(save-list (cons (add-todo) (load-list)))


(system "clear")
