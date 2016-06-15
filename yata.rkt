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

; flatten
(define args (flatten
 ; zip with index
 (zip-with-index
  ; replace #t and #f with ON and OFF
  (map argify-status
       (map (lambda (todo)
              ; only take title and completed field
              (take todo 2))
            ; sort by priority
            (sort todos #:key caddr <)))
  1)))

; adjust list length dynamically to the amount of todo items
(define options(list* "--cancel-button" "gtfo" "--title" "YATλ!" "--checklist" "Todos" "18" "60" (number->string (/ (length args) 3)) args))
(define completedTodos
  (string-split ; "1 3 4" -> '("1" "3" "4")
   (call-with-output-string
    (lambda (listener-port)
      ((fifth ; grab the fifth return value from the system call
        ; spawn whiptail/dialog process and redirect the stderr to the call-with-string (p)
        (apply process*/ports (current-output-port) (current-input-port) listener-port (find-executable-path "dialog") options))'wait)))))
(write completedTodos)

; (module whippy racket/base
;   (provide checklist)
;   ; takes a list of (tag item status)s
;   ; There are menu-height entries displayed in the menu at one time, but the menu will be scrolled if there are more entries than that.
;   (define checklist (lambda (text height width menu-height tag-item-status-list)
;                  (let ([tag-item-status-string (flatten tag-item-status-list)])
