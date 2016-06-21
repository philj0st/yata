#lang racket
(require racket/cmdline)
(require "filesystem.rkt")
(require "dialog.rkt")

(define add-todo-flag? (make-parameter #f))
(define toggle-flag? (make-parameter #f))

(define mode
  (command-line
   #:program "yata"
   #:once-each
   [("-n" "--new") "Add new Todo"
                       (add-todo-flag? #t)]
   [("-m" "--menu") "Display graphical menu"
                       (toggle-flag? #t)]
   ))

;(write (add-todo))

(when (add-todo-flag?)
 (let ([new-todo (add-todo)])
   (cond [(list? new-todo) (save-list (cons new-todo (load-list)))]
         [else (write "Add Todo was cancelled")])))

(when (toggle-flag?)
 ; capture the result of the toggle-dialog
 (let ([toggled-todos (toggle-todo (load-list))])
   ; only save them if the dialog wasn't cancelled
   (cond [(list? toggled-todos) (save-list (cons new-todo (load-list)))]
         [else (write "Add Todo was cancelled")])))

(system "clear")
