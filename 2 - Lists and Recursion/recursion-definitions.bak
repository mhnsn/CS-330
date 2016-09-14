#lang at-exp racket

(define (check-temps1 temps)
  (check-temps temps 5 95))

(define (check-temps temps low high)
  (if (empty? temps)
      true
      (if (> low high)
          false
          (and
           (if (> (first temps) high) false true)
           (if (< (first temps) low) false true)
           (if (check-temps1 (rest temps)) true false)))))

(define (convert digits)
  (if (empty? digits)
      0
      (+ (first digits) (* 10 (convert(rest digits))))))

(define  (duple lst)
  (if (not (empty? lst))
      (cons (list (first lst) (first lst)) (duple (rest lst)))
  empty))

@; note that 'average' is handled with two recursive functions:
@; one to sum and one to count elements
(define (sum-list lst)
    (if (empty? lst)
      0
      (+ (first lst) (sum-list (rest lst)))))

(define (count-list-elems lst)
  (if (empty? lst)
      0
      (+ 1 (count-list-elems (rest lst)))))

(define (average lst)
  (/ (sum-list lst) (count-list-elems lst)))


(define (convertFC temps)
  (if (not (empty? temps))
      (cons (* (- (first temps) 32) (/ 5 9)) (convertFC (rest temps)))
  empty))


@; this uses a helper function to grab the largest item that follows the list head
(define (find-largest-following lst)
  (if (empty? lst)
      -99999999
      (if (> (first lst) (find-largest-following (rest lst)))
          (first lst)
          (find-largest-following (rest lst)))))

(define (eliminate-larger lst)
    (if (empty? lst)
        null
        
            
 
(define (get-nth lst n) 0)

(define (find-item lst target) 0)

@; some definitions for testing
(define pass-list (list 80 92 56))
(define fail-list (list 80 99 56))
(define temp-tests (list pass-list fail-list)) @; not necessary
(define hiTemp 95)
(define loTemp 5)
(define convert-list-1 (list 1 2 3))
(define convert-list-2 (list 3 2 1))
(define convert-list-3 (list 0 0 1))
(define convert-list-4 (list 1 0 0))
(define convert-tests (list convert-list-1 convert-list-2 convert-list-3)) @; not necessary
(define duple-test (list 1 2 3))
(define average-test (list 1 2 3 4))
(define convertFC-test (list 32 50 212))
(define eliminate-test (list 1 2 3 9 4 5))

@; check-temps1 tests
(check-temps1 pass-list)
(check-temps1 fail-list)

@; check-temps tests
(check-temps pass-list loTemp hiTemp)
(check-temps fail-list loTemp hiTemp)

@; convert tests
(convert convert-list-1)
(convert convert-list-2)
(convert convert-list-3)
(convert convert-list-4)

@; duple tests
(duple duple-test)
(duple pass-list)
(duple fail-list)

@; average tests
(average average-test)

@; convertFC tests
(convertFC convertFC-test)
@; eliminate-larger tests
(eliminate-larger eliminate-test)
(and "Not implemented past here!")
@; get-nth  tests
(get-nth eliminate-test 6)
@; find-item tests
(find-item eliminate-test 9)

@; pay no attention to the man behind the curtain!
@;(define (((curry2 func) arg1) arg2)
@;  (func arg1 arg2))