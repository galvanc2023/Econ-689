* ECON 689 - Problem Set 3
* Carter Galvan

clear all
set more off

capture log close
log using "ps03_cartergalvan.log", text replace

* Problem 1
set seed 2026
set obs 500

generate x1 = rnormal(2,1)
generate v = rnormal(0,1)
generate x2 = 0.5*x1 + v
generate u = rnormal(0,2)
generate y = 3 + 2*x1 - x2 + u

summarize y x1 x2

twoway (scatter y x1) (lfit y x1), title("Y against X1") xtitle("X1") ytitle("Y")

twoway (scatter y x2) (lfit y x2), title("Y against X2") xtitle("X2") ytitle("Y")

* Problem 2
regress y x1 x2
estimates store model1

predict yhat, xb
predict ehat, residuals

generate x1_ehat = x1*ehat
summarize x1_ehat, meanonly
display "Sum of x1*ehat = " r(mean)*r(N)

generate x2_ehat = x2*ehat
summarize x2_ehat, meanonly
display "Sum of x2*ehat = " r(mean)*r(N)

twoway (scatter ehat x1) (lfit ehat x1), yline(0) title("Residuals against X1") xtitle("X1") ytitle("Residuals")

twoway (scatter ehat x2) (lfit ehat x2), yline(0) title("Residuals against X2") xtitle("X2") ytitle("Residuals")

* Problem 3
summarize ehat, meanonly
display "Sum of residuals = " r(mean)*r(N)
display "Mean of residuals = " r(mean)

summarize yhat, meanonly
scalar mean_yhat = r(mean)

summarize y, meanonly
scalar mean_y = r(mean)

display "Mean of yhat = " mean_yhat
display "Mean of y = " mean_y
display "Difference = " mean_yhat - mean_y

histogram ehat, frequency xline(0) title("Histogram of Residuals") xtitle("Residuals") ytitle("Frequency")

* Problem 4
estimates restore model1

summarize x1, meanonly
scalar mean_x1 = r(mean)

summarize x2, meanonly
scalar mean_x2 = r(mean)

summarize y, meanonly
scalar mean_y2 = r(mean)

scalar yhat_mean = _b[_cons] + _b[x1]*mean_x1 + _b[x2]*mean_x2

display "Predicted y at average x values = " yhat_mean
display "Mean of y = " mean_y2
display "Difference = " yhat_mean - mean_y2

log close
