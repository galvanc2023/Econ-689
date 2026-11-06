
* Problem 3

clear all
set more off
capture log close _all

local storage : environment storage
local projects : environment projects

local datafile "`storage'/econ689_data/ps01/data/card.dta"
local outdir "`projects'/ps06"

capture mkdir "`outdir'"
log using "`outdir'/ps06_CarterGalvan.log", text replace

use "`datafile'", clear
keep if !missing(lwage, educ, exper, expersq, south)

local N = _N
local K = 4
local J = 4
local df2 = `N' - 2*`K'

* 3a

* H0: delta0 = delta1 = delta2 = delta3 = 0
* J = 4
* Restricted model: lwage = beta0 + beta1*educ
* + beta2*exper + beta3*expersq + error

* 3b

* Restricted regression
reg lwage educ exper expersq
scalar SSR_r = e(rss)

* Outside the South
reg lwage educ exper expersq if south == 0
scalar SSR_1 = e(rss)

* In the South
reg lwage educ exper expersq if south == 1
scalar SSR_2 = e(rss)

* Unrestricted SSR
scalar SSR_u = SSR_1 + SSR_2

* F statistic
scalar F_SSR = ((SSR_r - SSR_u)/`J') / ///
    (SSR_u/`df2')

* P-value
scalar p_SSR = Ftail(`J', `df2', F_SSR)

* Results
display "SSR restricted = " SSR_r
display "SSR south=0 = " SSR_1
display "SSR south=1 = " SSR_2
display "SSR unrestricted = " SSR_u
display "N - 2K = " `df2'
display "F statistic = " F_SSR
display "p-value = " p_SSR

* 3c

* Interaction variables
generate south_educ = south * educ
generate south_exper = south * exper
generate south_expersq = south * expersq

* Interacted regression
reg lwage educ exper expersq south ///
    south_educ south_exper south_expersq

* Save SSR
scalar SSR_interacted = e(rss)

* Education coefficients
scalar b_educ = _b[educ]
scalar b_south_educ = _b[south_educ]
scalar b_educ_south = b_educ + b_south_educ

* Compare SSR
display "SSR separate = " SSR_u
display "SSR interacted = " SSR_interacted
display "SSR difference = " abs(SSR_u - SSR_interacted)

* Joint F test
test south south_educ south_exper south_expersq

scalar F_test = r(F)
scalar p_test = r(p)

* Compare F statistics
display "F from SSR = " F_SSR
display "F from test = " F_test
display "F difference = " abs(F_SSR - F_test)
display "p-value = " p_test

* Education slopes
display "Education outside South = " b_educ
display "Education interaction = " b_south_educ
display "Education in South = " b_educ_south

* Test education interaction
test south_educ

* Conclusion
if scalar(p_test) < 0.05 {
    display "Reject H0 at the 5% level."
    display "There is significant structural change."
}
else {
    display "Fail to reject H0 at the 5% level."
}

* Close log
log close

