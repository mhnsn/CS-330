#lang racket

;; RACKET #1 : Literals and simple expressions

;; -----------------------------------------------------------------------
;; Literals

; number
3

; number - all just one "number" type
3.1415926

; fractions - part of the "number" type
1/4

; string
"hello world"

; character
#\a

; symbol - not usually found in non-interpreted languages
'abc

; boolean literals
true
false

;; -----------------------------------------------------------------------
;; Expressions

; simple example -- show variations with other operators
(+ 1 2)

; unary
(sqrt 16)

; binary
(- 16 4)

; variable arity
(+ 1 2 3 4 5)

; nested
(+ (* 2 3)
   (- 10 5))

; relations
(< 5 0)
(>= 5 0)

; predicates
(zero? 0)
(zero? 1)
(negative? 3)
(string=? "hello" "hello")

; type-testing predicates
(number? 3)
(string? 3)
(string? "hello")

; type-converter functions
(number->string 5)
(string->number "42")

;; -----------------------------------------------------------------------
;; Defining things -- a means of abstraction

; simple definition and use
(define a 3)
(+ a 1)

; initialized with more complicated expression
(define b (+ a 1))
b

;; -----------------------------------------------------------------------
;; Functions
(define (inc x)
  (+ x 1))

(inc 6)

;; -----------------------------------------------------------------------
;; Conditionals

; if expressions
(if (< a 5)
    100
    200)

(if (number? a)
    (+ a 10)
    "I don't know what to do")

; cond expressions

(cond
  ((< a 0) "positive")
  ((> a 0) "negative")
  (else    "zero"))

;; -----------------------------------------------------------------------
;; Example: smart incrementer (if time permits)
(define (smart-inc a)
  (cond
    ((number? a) (+ a 1))
    ((string? a) (+ (string->number a) 1))
    (else "Error!")))

(smart-inc 4)
(smart-inc "4")



