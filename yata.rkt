#lang racket
(require racket/string)
(require racket/generator)
(require "filesystem.rkt")

(define todos (load-list))

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

; to argify -> sanitize to use as argument. ex: #f to OFF
(define argify-status (lambda (todo) (if (cadr todo)
                         (cons (car todo) "ON")
                         (cons (car todo) "OFF"))))

; returns a whiptail/dialog compatible arguemnt string from a todo-list
; ("1st todo" #f 4) -> "1" "1st todo" "OFF"
(define argify (lambda (todo-list)
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
(define args (argify todos))
; adjust list length dynamically to the amount of todo items
(define options(list* "--cancel-button" "gtfo" "--title" "YATλ!" "--checklist" "Todos" "18" "60" (number->string (/ (length args) 3)) args))
(define completed-todo-indicies
  (map string->number
       (string-split ; "1 3 4" -> '("1" "3" "4")
        (call-with-output-string
         (lambda (listener-port)
           ((fifth ; grab the fifth return value from the system call
             ; spawn whiptail/dialog process and redirect the stderr to the call-with-string (p)
             (apply process*/ports (current-output-port) (current-input-port) listener-port (find-executable-path "dialog") options))'wait))))))

(write completed-todo-indicies)

; returns todo-list with completed field true or false based on the complted indices list
(define apply-status
  (lambda (todo-list completed-indices)
    ; map over todo itmes
    (map (lambda (todo-item)
           ; if the todo item's index is member of the completed indicies
           (cond [(member (string->number(car todo-item)) completed-indices)
                  ; set it's completed status to true
                  (list-set todo-item 2 #t)]
                 [else
                  (list-set todo-item 2 #f)]))
         todo-list)))

(apply-status (zip-with-index (sort todos #:key caddr <) 1) completed-todo-indicies)
; (module whippy racket/base
;   (provide checklist)
;   ; takes a list of (tag item status)s
;   ; There are menu-height entries displayed in the menu at one time, but the menu will be scrolled if there are more entries than that.
;   (define checklist (lambda (text height width menu-height tag-item-status-list)
;                  (let ([tag-item-status-string (flatten tag-item-status-list)])
