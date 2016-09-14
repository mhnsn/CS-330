# example: run this with "python grader_filename.py YOUR_CODE.rkt"
# this is an auto-generated file for general student testing

import sys
import subprocess
if __name__ == "__main__":
    fn = sys.argv[1]
    diff_fn = "tmp_correct_output.txt"
    info_fn = "tmp_tests_info.txt"
    tmp_fn = "tmp.rkt"
    output_fn = "tmp_output.txt"
    feedback_fn = "feedback.txt"
    run_cmd = "racket"
    tests = """(define (round-n num place)
  (let ((power (expt 10 place)))
    (/ (round (* power num)) power)))
(sum-coins 1 1 1 1)
(round-n (degrees-to-radians 60) 3)
(sign 4)
(round-n (new-sin 60 'radians) 3)
"""
    tests_info = """1 point. sum-coins function general test.
1 point. degrees-to-radians function general test. Make sure to use the Racket literal for the value of pi.
1 point. sign function general test.
1 point. new-sin function general test.
"""
    diff = """41
1.047
1
-0.305
"""
    grade = 0
    total_possible = 0
    with open(info_fn, "w") as w:
        w.write(tests_info)
    with open(diff_fn, "w") as w:
        w.write(diff)
    with open(fn, "r") as f:
        with open(tmp_fn, "w") as w:
            w.write(f.read())
            w.write(tests)
    cmd = [run_cmd, tmp_fn]
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    out, err = process.communicate()
    with open(output_fn, "w") as w:
        w.write(out)
    cmd = ["diff", "-y", diff_fn, output_fn]
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    out, err = process.communicate()
    error_line_nos = []
    extra_line_nos = []
    for count, i in enumerate(out.split("\n")):
        if "|" in i or "<" in i:
            error_line_nos.append(count)
        if ">" in i:
            extra_line_nos.append(count)
    with open(info_fn, "r") as info_file:
        with open(feedback_fn, "w") as feedback_file:
            feedback_file.write("        Diff output:\n")
            feedback_file.write(out)
            feedback_file.write("\n        Failed tests:\n")
            for count, l in enumerate(info_file):
                points = int(l.split()[0])
                if count in error_line_nos:
                    total_possible += points
                    feedback_file.write(l)
                elif count in extra_line_nos:
                    pass
                else:
                    total_possible += points
                    grade += points
            feedback_file.write("\n        Grade:\n" + str(grade) + " out of " + str(total_possible))
    cmd = ["rm", tmp_fn, output_fn, info_fn, diff_fn]
    subprocess.call(cmd)
    print "See feedback file: " + feedback_fn
