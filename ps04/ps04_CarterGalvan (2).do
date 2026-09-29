clear all
set more off
set seed 2026

capture log close
log using "ps04_yourname.log", text replace

* Problem 1

set obs 500

generate x2 = rnormal(1,1)
generate v = rnormal(0,1)
generate x1 = 0.7*x2 + v
generate u = rnormal(0,2)
generate y = 5 + 3*x1 - 2*x2 + u

summarize y x1 x2

regress y x1 x2

scalar b1_full = _b[x1]
display b1_full

* Problem 2

regress y x2
predict y_resid, residuals

regress x1 x2
predict x1_resid, residuals

twoway (scatter y_resid x1_resid) (lfit y_resid x1_resid), title("FWL Residual Plot") xtitle("Residualized x1") ytitle("Residualized y")

regress y_resid x1_resid, noconstant

scalar b1_fwl = _b[x1_resid]

display b1_full
display b1_fwl
display b1_full - b1_fwl

log close
