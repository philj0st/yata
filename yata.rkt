#lang racket
(require racket/string)
(require racket/generator)
(require "filesystem.rkt")
(require "dialog.rkt")

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


(write (cons (add-todo) todos))
; toggling todos and save result
(save-list (map cdr (apply-status (zip-with-index (sort todos #:key caddr <) 1) (toggle-todos todos))))

(system "clear")
