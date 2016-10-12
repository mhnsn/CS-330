#lang racket

;
;Required definitions for lab:
;  default-parms
;  type-parms
;  new-sin2
;

(define debugMode #t)

(define (default-parms f values)
  (lambda args
    (if (< (length args) (length values))
        (apply f (append args (list-tail values (length args))))
        (apply f args))))

(define (validate-types types parms)
  (if (empty? types)
      #t
      (if ((first types) (first parms))
          (validate-types (rest types) (rest parms))
           (error "Invalid argument!"))))

(define (type-parms f types)
  (lambda args
    (if (validate-types types args)
        (apply f args)
        (error "Invalid argument!"))))

(define (degrees-to-radians angle)
  (* angle (/ pi 180)))

(define (new-sin angle type)
  (if (symbol=? type 'degrees)
      (sin (degrees-to-radians angle))
      (sin angle)))

(define new-sin2
  (default-parms
    (type-parms new-sin (list number? symbol?))
    (list 0 'radians)))


; 0. some definitions for testing
(define f +)
(define g (default-parms f (list 42 99)))

(define functions (list
                   g
                   g
                   g
                   new-sin2
                   new-sin2
                   new-sin2
                 ))

(define test-cases (list
                    42
                    1
                    -79
                    180
                    pi
                    (/ pi 2)
                    ))

(define expected-results (list
                          141
                          100
                          20
                          -0.8011526357338304
                          1.2246063538223773e-016
                          1.0
                          ))

; attempting to make my own test driver?
(define (do-all-tests funcs test-cases expected-results)
  (andmap
   (lambda (test input result)
     (if (equal? (test input) result)
         (writeln"               TEST PASSED!                   ||")
         (map
          (lambda (test input result)
            (if (equal? (test input) result)
                #t
                (test input)))
          funcs
          test-cases
          expected-results)))
   funcs
   test-cases
   expected-results))


(define write-test-driver-footer-str
  (and (writeln"==============================================||")
       #t))

(if (and #t debugMode)
    (and  (writeln"==============================================||")
          (writeln"        BEGIN MY OWN TEST BENCH DRIVER        ||")
          (writeln"                                              ||")
          (do-all-tests functions test-cases expected-results)
          (writeln"                                              ||")
          (writeln"==============================================||")
          (writeln"        MANUAL TESTS FOR COMPLEX FUNCS        ||")
          (if (= (new-sin2) 0)
              (writeln"               TEST PASSED!                   ||") new-sin2)
          (if (= (new-sin2 45 'degrees) 0.7071067811865475)
              (writeln"               TEST PASSED!                   ||") (new-sin2 45 'degrees))
          (writeln"==============================================||"))
    (and ""))
(writeln"==============================================||")
