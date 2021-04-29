#lang racket/base

(require racket/function
         racket/match
         racket/stream
         racket/list
         racket/set
         racket/dict)

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
(define (letters->integer table letters)
  (for/fold ([result 0])
            ([digit (for/list ([l letters])
                      (hash-ref table l))])
    (+ digit (* result 10))))

; correct: (Immutable-HashTable Letter Integer) ->
; Letters -> Letters -> Letters -> Boolean

; correct takes a solutions, 2 input letters, and a solution
; and verifies if then *add* up to the solution 
(define (correct table top bot sol)
  (define l->i (curry letters->integer table))
  (eqv? (+ (l->i top) (l->i bot))
        (l->i sol)))

;two solutions to avoid using 0 for the first letter:
; - tell `generate` which letter is the first
;   and always remove 0 from `rng` for that letter
; - filter the stream to remove the solutions
;   which have 0 for the first letter
; obviously, the latter is more efficient.
(define (generate rng letters)
  (match letters
    ['() (stream empty)]
    [`(,letter . ,letters)
     (for*/stream ([index (in-list rng)]
                   [result (in-stream (generate (remove index rng)
                                                letters))])
       (cons (cons letter index)
             result))]))

(define (solve top bot sol)
  (for*/stream ([letters (in-value (set->list (apply set (append top bot sol))))]
                [solution (in-stream (generate (range 0 10) letters))]
                #:when (and (correct (make-immutable-hash solution) top bot sol)
                            (for/and ([l (for/list ([e (list top bot sol)])
                                           (first e))])
                              (not (eqv? (dict-ref solution l) 0)))))
    solution))