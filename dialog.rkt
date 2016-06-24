#lang racket
(require racket/generator)
(require racket/string)

(require "system.rkt")
(provide toggle-todos add-todo edit-todos)

; takes a list of (tag item status)s
; returns the new state of the todo list after toggling
(define toggle-todos
  (lambda (todo-list)
    (let* ([menu-heigth (number->string (length todo-list))]
           [window-options (list "--title" "YATΛ!" "--checklist" "Toggle Todos" WINDOW-HEIGHT WINDOW-WIDTH menu-heigth)]
           [todo-list-options (todo-list->shell-options todo-list)]
           [arguments (append window-options todo-list-options)]
           [checked-indicies (dialog->string arguments)])

      (cond [(non-empty-string? checked-indicies)
             (map cdr ; removes the index again
                  ; returns todo-list with completed field true or false based on the complted indices list
                  (apply-status
                   (zip-with-index
                    (sort todo-list #:key caddr <) 1)
                   ; '("1" "3" "4") -> '(1 3 4)
                   (map string->number
                        ; "1 3 4" -> '("1" "3" "4")
                        (string-split checked-indicies))))]
            ; if the toggle-dialog returns a empty string usually means the dialog got cancelled
            ; could also mean that no todo is checked -> check issues
            [else #f]))))


(define add-todo (lambda ()
                   (let ([add-todo-text-options (list "--clear" "--title" "YATΛ!" "--inputbox" "New Todo: Content" WINDOW-HEIGHT WINDOW-WIDTH)]
                         [add-todo-priority-options (list "--clear" "--title" "YATΛ!" "--menu" "New Todo: Priority" WINDOW-HEIGHT WINDOW-WIDTH "3" "1" "High" "2" "Medium" "3" "Low")])
                     ; capture the result of the todo-text dialog as text
                     (let* ([text (dialog->string add-todo-text-options)]
                            ; pass text to this immediatly invoked lambda
                            [priority ((lambda (previous-dialog-passed?)
                                         ; which assigns the result of the priority-dialog to priority if the text-dialog didn't get cancelled
                                         (cond [previous-dialog-passed? (dialog->string add-todo-priority-options)]
                                               ; if the text-dialog got cancelled don't even display the priority-dialog
                                               [else #f]))
                                         (non-empty-string? text))])
                       ; if the priority-dialog didn't get cancelled
                       (cond [(non-empty-string? priority)
                              ; return a new todo item
                              (list text #f (string->number priority))]
                             ; otherwise return false
                             [else #f])))))

; todo-list (unindexed) -> todo-list (unindexed)
(define edit-todos
 (lambda (todo-list)
   ; if the todo-list is smaller than 6 let the menu-heigth be 3*size, else 18
   (let* ([menu-heigth (number->string((lambda (x) (if (> x 6) 18 (* x 3)))(length todo-list)))]
         ; using 19 as heigth makes 4 items fit on the screen in --inputmenu mode
         [window-options (list "--title" "YATΛ!" "--inputmenu" "Edit Todos" "19" WINDOW-WIDTH menu-heigth)]
         [todo-list-options (todo-list->index-content-pair todo-list)]
         [arguments (append window-options todo-list-options)]
         [changes (dialog->string arguments)]
         [changed-index (string->number(cadr (string-split changes)))])
     (write changed-index))))


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

; TODO Refactor/combine with shell-options
(define todo-list->index-content-pair (lambda (todo-list)
                (flatten
                 (zip-with-index
                  ; replace #t and #f with ON and OFF
                  (map (lambda (todo-item)
                         ; only take title
                         (car todo-item))
                       ; sort by priority
                       (sort todo-list #:key caddr <))
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
