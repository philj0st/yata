#lang racket
; todo item (title:s completed:b priority:i)
(define todos '(("finish writing yata" #f 3) ("learn more functional beauty" #t 5) ("come up with better todo examples" #t 5) ("persist this data" #f 4)))

; TODO: zip with lazy integer generator
; as long as list is not empty cons the cons of index and car of the list with the cdr of the list
(define zipWithIndex (lambda (list start-index)
                       (cond
                         [(empty? list) '()]
                         [else (cons (cons (number->string start-index) (car list))(zipWithIndex (cdr list) (+ start-index 1)))])))

; to argify -> sanitize to use as argument. ex: #f to OFF
(define argify-status (lambda (todo) (if (cadr todo)
                         (cons (car todo) "ON")
                         (cons (car todo) "OFF"))))



; flatten
(define args (flatten
 ; zip with index
 (zipWithIndex
  ; replace #t and #f with ON and OFF
  (map argify-status
       (map (lambda (todo)
              ; only take title and completed field
              (take todo 2))
            ; sort by priority
            (sort todos #:key caddr <)))
  1)))
  
; adjust list length dynamically to the amount of todo items
(define options(list* "--cancel-button" "gtfo" "--title" "YATλ!" "--checklist" "Todos" "20" "50" (number->string (/ (length args) 3)) args))
(define err(call-with-output-string (lambda (p) ((fifth (apply process*/ports (current-output-port) (current-input-port) p (find-executable-path "dialog") options)) 'wait))))
(write "capturing the stderr: ")
(write err)

; (module whippy racket/base
;   (provide checklist)
;   ; takes a list of (tag item status)s
;   ; There are menu-height entries displayed in the menu at one time, but the menu will be scrolled if there are more entries than that.
;   (define checklist (lambda (text height width menu-height tag-item-status-list)
;                  (let ([tag-item-status-string (flatten tag-item-status-list)])
