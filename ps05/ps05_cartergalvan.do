* ECON 689 - Problem Set 5
* Carter Galvan
* Problem 2

global storage "C:/Users/iamca/OneDrive - Texas A&M University"
global dataready "$storage/econ689_data/ps01/data"

use "$dataready/card.dta", clear

* Problem 2(a)
regress lwage educ exper expersq black south smsa smsa66 ///
    reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669

scalar SSR_u = e(rss)
scalar df_u = e(df_r)

display "Unrestricted SSR = " SSR_u
display "Residual degrees of freedom = " df_u

* Problem 2(b)
test reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669

scalar F_test = r(F)
scalar p_test = r(p)

display "F statistic = " F_test
display "P-value = " p_test

* Problem 2(c)
regress lwage educ exper expersq black south smsa smsa66

scalar SSR_r = e(rss)
scalar F_manual = ((SSR_r - SSR_u)/8)/(SSR_u/df_u)

display "Restricted SSR = " SSR_r
display "Manual F = " F_manual
display "Stata F = " F_test