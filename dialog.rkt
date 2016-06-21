#lang racket
(require racket/generator)
(provide toggle-todos add-todo)

(define toggle-todos (lambda (todo-list)
  ; adjust list length dynamically to the amount of todo items
  (define args (todo-list->shell-options todo-list))
  (define options(list* "--cancel-button" "gtfo" "--title" "YATλ!" "--checklist" "Todos" "18" "60" (number->string (length todo-list)) args))
  (map string->number
       (string-split ; "1 3 4" -> '("1" "3" "4")
        (call-with-output-string
         (lambda (listener-port)
           ((fifth ; grab the fifth return value from the system call
             ; spawn whiptail/dialog process and redirect the stderr to the call-with-string (p)
             (apply process*/ports (current-output-port) (current-input-port) listener-port (find-executable-path "dialog") options))'wait)))))))

; TODO: extract system call
(define add-todo (lambda ()
                  (let* ([constant-options (lambda (title) (list "--clear" "--inputbox" title "18" "60"))]
                         [get-text (lambda (title)
                                     (call-with-output-string
                                      (lambda (listener-port)
                                        ((fifth ; grab the fifth return value from the system call
                                          ; spawn whiptail/dialog process and redirect the stderr to the call-with-string (p)
                                          (apply process*/ports (current-output-port) (current-input-port) listener-port (find-executable-path "dialog") (constant-options title)))'wait))))])
                    (define text (get-text "New Todo"))
                    (define priority (get-text "Priority"))
                    (list text #f priority))))

; to todo-list->shell-options -> sanitize to use as argument. ex: #f to OFF
(define argify-status (lambda (todo) (if (cadr todo)
                         (cons (car todo) "ON")
                         (cons (car todo) "OFF"))))

; TODO: refactor todo-list->shell-options to operate on single todo-item and call map in todo-list
; returns a whiptail/dialog compatible arguemnt string from a todo-list
; ("1st todo" #f 4) -> "1" "1st todo" "OFF"
(define todo-list->shell-options (lambda (todo-list)
                (flatten
                 (zip-with-index
                  ; replace #t and #f with ON and OFF
                  (map argify-status
                       (map (lambda (todo-item)
                              ; only take title and completed field
                              (take todo-item 2))
                            ; sort by priority
                            (sort todo-list #:key caddr <)))
                  1))))

; (zip-with-index '("@" "!" "%") 3) -> '(3 . "@") (4 . "!") (5 . "%"))
(define zip-with-index (lambda (lst start-index)
                         ; define a generators of natural integers starting from start-index
                         (letrec ([naturals (sequence->generator (in-naturals start-index))]
                                  [zip-with-naturals (lambda (lst)
                                                       (cond ((empty? lst) empty)
                                                             (else (cons
                                                                    ; cons (1 "a")
                                                                    (cons
                                                                          (number->string(naturals))
                                                                          (car lst))
                                                                    ; with the recursive call on the lst's tail
                                                                    (zip-with-naturals(cdr lst))))))])
                           (zip-with-naturals lst))))
