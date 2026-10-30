* ECON 689 - Problem Set 5
* Carter Galvan
* Problems 2 and 3: Joint hypothesis tests
* Run from start to finish in a fresh Stata session.

clear all
set more off

* Read the two Windows environment variables from Problem Set 1.
global storage : env storage
global projects : env projects

if "$storage" == "" {
    display as error "The Windows environment variable storage is empty. Set it and restart Stata."
    exit 198
}
if "$projects" == "" {
    display as error "The Windows environment variable projects is empty. Set it and restart Stata."
    exit 198
}

global dataready "$storage/econ689_data/ps01/data"
global output "$storage/econ689_data/ps05"

capture mkdir "$output"
capture log close _all
log using "$output/ps05_cartergalvan.txt", text replace

display as text "Storage location: $storage"
display as text "Projects location: $projects"
display as text "Data location: $dataready"
display as text "Log location: $output/ps05_cartergalvan.txt"

* ------------------------------------------------------------
* Problem 2: SSR form of the F test (Card data)
* ------------------------------------------------------------
use "$dataready/card.dta", clear

* 2(a): Unrestricted regression, omitting reg661 as the reference region.
regress lwage educ exper expersq black south smsa smsa66 ///
    reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669
scalar SSR_u = e(rss)
scalar df_u = e(df_r)
display as result "2(a) Unrestricted SSR = " %12.8f SSR_u
display as result "2(a) Unrestricted residual df = " %7.0f df_u

* 2(b): Test all eight 1966 region coefficients jointly equal to zero.
test reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669
scalar F_test2 = r(F)
scalar p_test2 = r(p)
display as result "2(b) Restrictions J = 8"
display as result "2(b) Joint F statistic = " %12.8f F_test2
display as result "2(b) p-value = " %12.9f p_test2

* 2(c): Restricted regression and independently computed SSR F statistic.
regress lwage educ exper expersq black south smsa smsa66
scalar SSR_r = e(rss)
scalar F_SSR2 = ((SSR_r - SSR_u)/8) / (SSR_u/df_u)
display as result "2(c) Restricted SSR = " %12.8f SSR_r
display as result "2(c) SSR F statistic = " %12.8f F_SSR2
display as result "2(c) Stata test F = " %12.8f F_test2
display as result "2(c) Absolute difference = " %12.10f abs(F_SSR2-F_test2)
if p_test2 < 0.05 {
    display as result "2(c) Reject H0 at the 5% level."
}
else {
    display as result "2(c) Fail to reject H0 at the 5% level."
}

* ------------------------------------------------------------
* Problem 3: Matrix form of the F test (simulated data)
* ------------------------------------------------------------

* 3(a): Set the seed and generate variables in the requested order.
clear
set seed 2026
set obs 500
generate x1 = rnormal(0,1)
generate v = rnormal(0,1)
generate x2 = 0.5*x1 + v
generate x3 = rnormal(1,1)
generate u = rnormal(0,2)
generate y = 1 + x1 + 0.5*x2 - 0.5*x3 + u
summarize x1 v x2 x3 u y
regress y x1 x2 x3

display as result "3(a) Estimated intercept = " %10.7f _b[_cons]
display as result "3(a) Estimated x1 = " %10.7f _b[x1]
display as result "3(a) Estimated x2 = " %10.7f _b[x2]
display as result "3(a) Estimated x3 = " %10.7f _b[x3]

* 3(b): H0: beta1=1 and beta2+beta3=0; J=2.
test (x1 = 1) (x2 + x3 = 0)
scalar F_test3 = r(F)
scalar p_test3 = r(p)
display as result "3(b) Joint F statistic = " %12.8f F_test3
display as result "3(b) p-value = " %12.8f p_test3

* 3(c): e(b) is ordered (x1, x2, x3, _cons) and is a row vector.
matrix b = e(b)
matrix V = e(V)
matrix R = (1,0,0,0 \ 0,1,1,0)
matrix r = (1 \ 0)
matrix d = R*b' - r
matrix W = d' * invsym(R*V*R') * d
scalar F_matrix3 = W[1,1]/2

display as result "3(c) Matrix F statistic = " %12.8f F_matrix3
display as result "3(c) Stata test F = " %12.8f F_test3
display as result "3(c) Absolute difference = " %12.10f abs(F_matrix3-F_test3)
if p_test3 < 0.05 {
    display as result "3(c) Reject H0 at the 5% level."
}
else {
    display as result "3(c) Fail to reject H0 at the 5% level."
}

log close
