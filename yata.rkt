#lang racket
(require racket/cmdline)
(require "filesystem.rkt")
(require "dialog.rkt")

(define active-todo
 (lambda (todo-item)
             ; filters for the todo items that have a #f at the cadr spot
             (not (cadr todo-item))))

(define completed-todo
  (lambda (todo-item)
             ; filters for the todo items that have a #t at the cadr spot
             (cadr todo-item)))

(define menu-flag? (make-parameter #f))
(define add-todo-flag? (make-parameter #f))
(define remove-completed-flag? (make-parameter #f))
(define toggle-flag? (make-parameter #f))
(define edit-flag? (make-parameter #f))

(define options
  (command-line
   #:program "yata"
   #:once-each
   [("-m" "--menu") "Displays a menu with actions"
                       (menu-flag? #t)]
   [("-n" "--new") "Displays a dialog to Add a new Todo"
                       (add-todo-flag? #t)]
   [("-r" "--remove-completed") "Removes all completed Todos"
                       (remove-completed-flag? #t)]
   [("-t" "--toggle") "Displays a dialog to toggle Todos"
                       (toggle-flag? #t)]
   [("-e" "--edit") "Displays a dialog to rename Todos"
                       (edit-flag? #t)]
   [("-v" "--version") "Displays Yata's version number"
                       ; hardcoded for now
                       (displayln "0.0.1")]
   ))


; if there are no flags set run default action
(when (zero? (vector-length (current-command-line-arguments)))
  (toggle-flag? #t))

(when (menu-flag?)
  ; capture the result of the add-todo-dialog
  (let ([choice (menu)])
    (system "clear")
    (match choice
      ["Toggle Todos" (toggle-flag? #t)]
      ["New Todo" (add-todo-flag? #t)]
      ["Remove Completed" (remove-completed-flag? #t)]
      ["Edit Todo" (edit-flag? #t)]
      ["Quit" (exit)])))

(when (add-todo-flag?)
; capture the result of the add-todo-dialog
 (let ([new-todo (add-todo)])
   (system "clear")
   (cond [(list? new-todo) (save-list (cons new-todo (load-list)))]
         [else (displayln "Add Todo was cancelled")])))

(when (remove-completed-flag?)
 (let ([todo-list (load-list)])
   (displayln "Completed Todo's removed:")
   ; display on each line
   (map displayln
        ; the content part
        (map car
             ; of the completed-todos
             (filter completed-todo todo-list)))
   ; then save them
   (save-list (filter active-todo todo-list))))


(when (toggle-flag?)
  ; capture the result of the toggle-dialog
  (let ([new-todos-state (toggle-todos (load-list))])
    (system "clear")
    ; only save them if the dialog wasn't cancelled
    (cond [(list? new-todos-state) (save-list new-todos-state)]
          [else (write "Toggling Todos was cancelled")])))

(when (edit-flag?)
 ; capture the result of the toggle-dialog
 (let ([new-todos-state (edit-todos (load-list))])
   (system "clear")
   ; only save them if the dialog wasn't cancelled
   (cond [(list? new-todos-state) (save-list new-todos-state)]
         [else (displayln "Nothing changed")])))
