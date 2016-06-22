#lang racket
(require racket/cmdline)
(require "filesystem.rkt")
(require "dialog.rkt")

(define remove-completed
 (lambda (todo-list)
   (filter (lambda (todo-item)
             ; filters for the todo items that have a #f at the cadr spot
             (not (cadr todo-item)))
           todo-list)))

(define add-todo-flag? (make-parameter #f))
(define remove-completed-flag? (make-parameter #f))
(define toggle-flag? (make-parameter #f))

(define mode
  (command-line
   #:program "yata"
   #:once-each
   [("-n" "--new") "Displays a dialog to Add a new Todo"
                       (add-todo-flag? #t)]
   [("-r" "--remove-completed") "Removes all completed Todos"
                       (remove-completed-flag? #t)]
   [("-t" "--toggle") "Displays a dialog to toggle Todos"
                       (toggle-flag? #t)]
   ))


; if there are no flags set run default action
(when (zero? (vector-length (current-command-line-arguments)))
  (toggle-flag? #t))

(when (add-todo-flag?)
 (let ([new-todo (add-todo)])
   (cond [(list? new-todo) (save-list (cons new-todo (load-list)))]
         [else (write "Add Todo was cancelled")])))

(when (remove-completed-flag?)
 (save-list (remove-completed (load-list))))

(when (toggle-flag?)
 ; capture the result of the toggle-dialog
 (let ([new-todos-state (toggle-todos (load-list))])
   ; only save them if the dialog wasn't cancelled
   (cond [(list? new-todos-state) (save-list new-todos-state)]
         [else (write "Toggling Todos was cancelled")])))


(system "clear")
