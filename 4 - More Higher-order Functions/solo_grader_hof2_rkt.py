# example: run this with "python grader_filename.py your_code_filename"
# this is an auto-generated file for general student testing

import sys
import subprocess
import os
from difflib import Differ
if __name__ == "__main__":
    fn = sys.argv[1]
    tmp_fn = "tmp.rkt"
    feedback_fn = "feedback.txt"
    run_cmd = "racket"
    tests = """



;; sample function
(define (f x y z)
  ;(printf "Parameters are ~a, ~a, and ~a~n" x y z) ; for demonstration
  (+ x y z))

;; make a version with default parameter filling
(define g (default-parms f (list 0 1 2)))

;; and use it
(g 5)

;; a sample function
(define (sum-coins pennies nickels dimes quarters)
  (+ (*  1 pennies)
     (*  5 nickels)
     (* 10 dimes)
     (* 25 quarters)))

;; a composite type predicate
(define (positive-number? n)
  (and (number? n)
       (positive? n)))

;; make the typed version of the function
(define typed-sum-coins
  (type-parms sum-coins
              (list
               positive-number?
               positive-number?
               positive-number?
               positive-number?)))

;; using the typed version of the function correctly
(typed-sum-coins 1 2 3 4)
(with-handlers ([exn:fail? (lambda (e) (println "got an error"))]) (typed-sum-coins -1 2 3 4))

;; the chaining test for the assignment
(define (round-n num place)
  (let ((power (expt 10 place)))
    (/ (round (* power num)) power)))
(round-n (new-sin2 45 'degrees) 3)
(round-n (new-sin2 pi 'radians) 3)
"""
    tests_info = """1. 1 point. default-parms general test. Uses 3-parameter addition.
2. 1 point. type-parms general test. Uses an implementation of sum-coins and positive? and number?.
3. 1 point. type-parms error test. Uses an implementation of sum-coins and positive? and number?.
4. 1 point. Test of new-sin2 (the chaining default-parms and type-parms functionality). This test uses degrees.
5. 1 point. Test of new-sin2 (the chaining default-parms and type-parms functionality). This test uses radians.
"""
    correctoutput = """8
141
"got an error"
0.707
0.0
"""
    grade = 0
    total_possible = 0
    with open(fn, "r") as f:
        with open(tmp_fn, "w") as w:
            w.write(f.read())
            w.write(tests)
    cmd = [run_cmd, tmp_fn]
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    studentoutput, err = process.communicate()
    comparison = "".join(Differ().compare(correctoutput.splitlines(1), studentoutput.splitlines(1)))
    error_line_nos = []
    extra_line_nos = []
    q_line_nos = []
    for count, i in enumerate(comparison.splitlines()):
        if "-" == i[0]:
            error_line_nos.append(count)
        elif "+" == i[0]:
            extra_line_nos.append(count)
        elif "?" == i[0]:
            q_line_nos.append(count)
    failed_tests_line_nos = []
    for x in error_line_nos:
        numextralines = len([y for y in extra_line_nos if y < x])
        numqlines = len([z for z in q_line_nos if z < x])
        failed_tests_line_nos.append(x - numextralines - numqlines)
    with open(feedback_fn, "w") as feedback_file:
        feedback_file.write("        Correct output:\n")
        feedback_file.write(str(correctoutput))
        feedback_file.write("\n        Your output:\n")
        feedback_file.write(str(studentoutput))
        feedback_file.write("\n        Failed tests:\n")
        for count, l in enumerate(tests_info.splitlines(1)):
            points = int(l.split()[1])
            if count in failed_tests_line_nos:
                total_possible += points
                feedback_file.write(l)
            elif count in extra_line_nos:
                pass
            else:
                total_possible += points
                grade += points
        feedback_file.write("\n        Grade:\n" + str(grade) + " out of " + str(total_possible))
    os.remove(tmp_fn)
    print("See feedback file: " + feedback_fn)
