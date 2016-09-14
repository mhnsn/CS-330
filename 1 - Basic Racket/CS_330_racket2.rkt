#lang racket

;; RACKET #2 : Inductively defined data, lists, natural recursion

;; -----------------------------------------------------------------------

;; Introduction: 
;
; Types = set of values + operations on those values
; Some sets are simple, and we can list them: days of the week, months of the year, students in this class, etc.
; How many integers are there? (infinite)
; Sometimes we use finite sets as approximations (ints in C++)
; How many possible binary trees are there? Do we want to limit this (other than memory limits)?
; So how to we describe the elements of the set of all valid binary trees?
; Can also describe by filtering some other set by some property -- does that work here?
; Can define inductively: some known elements, others included based on known elements
; Example: positive integers = 0, positive integer + 1
; You already know how to do this with tree - how?
; We call these the "base cases" and the "inductive step" respectively.

;; -----------------------------------------------------------------------

;; Linked lists as an inductively defined set/type
; How do you define a list of numbers this way?
; Base case: empty list
; Inductive step: a number followed by a list of numbers

;; -----------------------------------------------------------------------

;; How to write this in Racket

; empty
empty

; non-empty
; cons = the simplest possible aggregate data structure
(cons 5 empty)
(cons 5 (cons 6 empty))

; list-of-numbers = empty | (cons number list-of-numbers)

;; -----------------------------------------------------------------------

;; Box-and-pointer diagrams
; whiteboard discussion

;; -----------------------------------------------------------------------

;; Generalizing lists
; lists of any one particular type
; heterogeneous lists
; lists of lists?

;; -----------------------------------------------------------------------

;; Accessing lists

(define a (cons 1 (cons 2 (cons 3 (cons 4 empty)))))

; first
(first a)

; rest
(rest a)

;; Other list functions

(list 1 2 3 4 5)

(cons (list 1 2 3 4) (list 5 6 7 8))
(list (list 1 2 3 4) (list 5 6 7 8))
(append (list 1 2 3 4) (list 5 6 7 8))

;; -----------------------------------------------------------------------

;; Coding functions that work on lists

; len : list of anything -> number
; return the length of the list
(define (len lst)
  (if (empty? lst)
      0
      (+ 1 (len (rest lst)))))

(len (list 1 2 3 4 5))

; sum : list of number -> number
; returns the sum of a list of numbers
(define (sum lon)
  (if (empty? lon)
      0
      (+ (first lon) (sum (rest lon)))))

(sum empty)
(sum (cons 99 empty))
(sum (cons 1 (cons 2 empty)))

;; -----------------------------------------------------------------------

;; Natural recursion
;
; Notice that the recursive structure of the code matches the inductive structure of the data!
;
; Structure (not quite the same as written on the board, but same idea):
; 1. Base case(s)? -> return corresponding answer
; 2. Inductive step?
;    a. Break apart into pieces
;    b. Process pieces (possibly recursively!)
;    c. Combine results to produce combined result

; Note: recursion isn't just a cute language feature -- 
; it's an inherently powerful idea of things being defined in terms of (smaller) versions of themselves!

;; -----------------------------------------------------------------------

;; Languages as inductively defined types
;
; Here's a new type to think about: the set of all syntactically valid C++ programs
; How do we define its elements?  ->  Grammars (usually written in BNF)
; Point out inductive structure of statements / while loops / for loops / etc.
; The only sane way to process these is recursively!

;; -----------------------------------------------------------------------

;; Other patterns for recursive functions that work with lists

; all-even? : list of number -> boolean
; returns whether all of the elements of a list are even
(define (all-even? lon)
  (if (empty? lon)
      true
      (and (even? (first lon)) 
           (all-even? (rest lon)))))

(all-even? empty)
(all-even? (cons 2 (cons 4 empty)))
(all-even? (cons 2 (cons 4 (cons 5 (cons 6 empty)))))

; are-even : list of number -> list of boolean
; returns whether each element of a list is a number
(define (are-even lon)
  (if (empty? lon)
      empty
      (cons (even? (first lon)) 
            (are-even (rest lon)))))

(are-even empty)
(are-even (cons 2 (cons 4 empty)))
(are-even (cons 2 (cons 4 (cons 5 (cons 6 empty)))))

; find-even : list of number -> list of number
; finds all of the even elements of a list of numbers
(define (find-even lon)
  (if (empty? lon)
      empty
      (if (even? (first lon))
          (cons (first lon) 
                (find-even (rest lon)))
          (find-even (rest lon)))))

(find-even empty)
(find-even (cons 2 (cons 4 empty)))
(find-even (cons 2 (cons 4 (cons 5 (cons 6 empty)))))

;; -----------------------------------------------------------------------

;; Using local definitions to re-use results of computations
;; (not covered in class and not required for the labs, but useful)

; simple example of "local"
; Can be used for local definitions that have scope only
; within the "local" block.
; Form is (local [ <definitions> ] <expression>)
(local [(define a (+ 1 2))
        (define b (* 2 2))]
  (+ (* a a) (* b b)))


; find-even2 : list of number -> list of number
; finds all of the even elements of a list of numbers
; This is the same as find-even except it uses local variables
; to avoid multiple assesses into the list.
(define (find-even2 lon)
  (if (empty? lon)
      empty
      (local
        [(define f (first lon))
         (define r (rest lon))]
        (if (even? f)
            (cons f (find-even2 r))
            (find-even2 r)))))

(find-even2 empty)
(find-even2 (cons 2 (cons 4 empty)))
(find-even2 (cons 2 (cons 4 (cons 5 (cons 6 empty)))))

;; -----------------------------------------------------------------------

;; Auxiliary parameters and auxiliary functions

; len2 : list of anything -> number
; a version of len that uses an auxiliary variable
; -- len2 doesn't really do the work but just uses the
; -- auxiliary function and passes the appropriate initialization
; -- for the auxiliary parameter
(define (len2 lst)
  (len2-aux lst 0))

; len2-aux : list of anything , number -> number
; -- helper for the len2 function that uses an additional parameter
; -- count is called an "auxiliary parameter"
; -- len2-aux is called an "auxiliary function"
(define (len2-aux lst count)
  (if (empty? lst)
      count
      (len2-aux (rest lst) (+ count 1))))

(len2 (list 1 2 3 4 5))

;; -----------------------------------------------------------------------

;; Using local definitions to hide auxiliary functions
;; (asked about in class but not shown, so included here)

; len3 : list of anything -> number
; hides auxiliary function inside of itself
(define (len3 lst)
  (local [(define (aux lst count)
            (if (empty? lst)
                count
                (aux (rest lst) (+ count 1))))]
    (aux lst 0)))

(len3 (list 1 2 3 4 5))

;; -----------------------------------------------------------------------

;; Slightly more complicated (and necessary!) use of an aux. parameter

; anno : list of anything -> list of lists of (anything number)

(define (anno lst)
  (anno-aux lst 0))

(define (anno-aux lst pos)
  (if (empty? lst)
      empty
      (cons (list (first lst) pos)
            (anno-aux (rest lst) (+ pos 1)))))

(anno (list "matthew" "mark" "luke" "john"))

