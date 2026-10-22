#!/usr/bin/env bash
# Runs one experiment script and records PASS/FAIL (the job keeps going so every experiment runs).
n=$1
mkdir -p ci-out/results
if bash ".github/lab-ci/exp$n.sh"; then echo PASS > "ci-out/results/exp$n"; else echo FAIL > "ci-out/results/exp$n"; fi
echo "Experiment $n: $(cat ci-out/results/exp$n)"
exit 0
