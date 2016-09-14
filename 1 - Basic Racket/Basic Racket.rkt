#lang racket

(define (sum-coins pennies nickels dimes quarters)
  (+ (* 1 pennies) (* 5 nickels) (* 10 dimes) (* 25 quarters) ))

(define (degrees-to-radians angle)
  (* angle (/ pi 180)))

(define (sign x)
  (if (> x 0) 1 
  (if(< x 0) -1
  0)))

(define (new-sin angle type)
  (if (symbol=? type 'degrees)
      (sin (degrees-to-radians angle))
      (sin angle)))

(sum-coins 1 1 1 1)

(degrees-to-radians 60)

(sign 4)

(new-sin 60 'radians)