#lang racket

;    S E N D
; +  M O R E
; ----------
;  M O N E Y


; input: 2 lists of letters -- a b
;        a binary operation (+, for now)
;        a result (as a list of letters) -- s 
; ------------------------------------------------------
; output: a finite mapping of letters to *disctint* ints 
; ------------------------------------------------------
; fairly easy brute-force solution: filter correct . gen

; subst takes a mapping and letters to a list of ints
; (define (subst m l) (map (λ (x) (hash-ref m x 0)) l))

; : (Immutable-HashTable Letter Integer) -> Letters -> Integer
(define (letters->integer m l)
  (for*/fold ([s 0])
             ([a (in-list (map (curry hash-ref m) l))])
    (+ a (* s 10))))



; correct: (Immutable-HashTable Letter Integer) ->
; Letters -> Letters -> Letters -> Boolean

; correct takes a solutions, 2 input letters, and a solution
; and verifies if then *add* up to the solution 
(define (correct m a b s)
  (let* ([l->i (curry letters->integer m)]
         [a-value (l->i a)]
         [b-value (l->i b)]
         [s-value (l->i s)])
    (eq? (+ a-value b-value) s-value)))

;two solutions to avoid using 0 for the first letter:
; - tell `generate` which letter is the first
;   and always remove 0 from `rng` for that letter
; - filter the stream to remove the solutions
;   which have 0 for the first letter
; obviously, the latter is more efficient.
(define (generate rng letters)
  (match letters
    ['() (stream empty)]
    [`(,l . ,letters)
     (for*/stream ([i (in-list rng)]
                   [result (in-stream (generate (remove i rng) letters))])
       (cons (cons l i) result))]))

(define (solve a b s)
  (for*/stream ([letters (in-value (set->list (apply set (append a b s))))]
                [solution (in-stream (generate (range 0 10) letters))]
                #:when (and (correct (make-immutable-hash solution) a b s)
                            (h (map first (list a b s))
                               solution)))
    solution))

(define (p xs x)
 (match (assoc x xs)
   [(cons _ 0) #f]
   [_ #t]))

(define (h letters m)
  (andmap (curry p m) letters))

(module+ tests
  (require rackunit)
  
  (test-case
   "Simple test"
   (check-eq? (list 1) (list 5)))

  (test-case
   "Another test case"))

