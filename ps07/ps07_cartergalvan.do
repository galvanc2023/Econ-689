
// Carter Galvan - ECON 689 Problem Set 7, Problem 2

version 17.0
clear all
set more off
capture log close _all

// Set paths from Problem Set 1
local storage : env storage
local projects : env projects


local storage "C:\Users\iamca\OneDrive - Texas A&M University"
local projects "C:\Users\iamca"


global output "`storage'/econ689_data/ps07"
capture mkdir "$output"
log using "$output/ps07_results.log", text replace

use "`storage'/econ689_data/ps01/data/card.dta", clear

// Problem 2(a): Classical and robust standard errors

reg lwage educ exper expersq black south smsa
scalar b_educ = _b[educ]
scalar se_classic = _se[educ]

reg lwage educ exper expersq black south smsa, vce(robust)
scalar se_robust = _se[educ]
scalar se_south_robust = _se[south]

display "Education coefficient: " %9.6f b_educ
display "Classical SE (educ): " %9.6f se_classic
display "Robust SE (educ): " %9.6f se_robust
display "Percent change in SE: " %6.2f 100*(se_robust/se_classic - 1)

// vce(robust) uses HC1: weight 1 when i=j and 0 otherwise,
// with the N/(N-K) correction.

// Problem 2(b): Standard errors clustered by 1966 region

generate byte region66 = .
forvalues j = 1/9 {
    replace region66 = `j' if reg66`j' == 1
}

egen region_count = rowtotal(reg661-reg669)
assert region_count == 1
assert !missing(region66)
drop region_count

reg lwage educ exper expersq black south smsa, vce(cluster region66)

scalar C = e(N_clust)
scalar df_cluster = e(df_r)
scalar b_educ_cluster = _b[educ]
scalar se_educ_cluster = _se[educ]
scalar se_south_cluster = _se[south]

scalar tcrit = invttail(C-1, .025)
scalar ci_lower = b_educ_cluster - tcrit*se_educ_cluster
scalar ci_upper = b_educ_cluster + tcrit*se_educ_cluster

display "Number of clusters: " C
display "Cluster residual degrees of freedom: " df_cluster
display "Clustered SE (educ): " %9.6f se_educ_cluster
display "Clustered SE (south): " %9.6f se_south_cluster
display "95% CI for educ: [" %9.6f ci_lower ", " %9.6f ci_upper "]"

lincom educ, level(95)

display "Cluster vs robust SE change (educ), %: " %6.2f 100*(se_educ_cluster/se_robust - 1)
display "Cluster vs robust SE change (south), %: " %6.2f 100*(se_south_cluster/se_south_robust - 1)

// Problem 2(c): Delta method and Wald tests

reg lwage educ exper expersq black south smsa, vce(robust)

nlcom (theta: -_b[exper]/(2*_b[expersq]))

matrix theta_b = r(b)
matrix theta_v = r(V)

scalar theta_hat = theta_b[1,1]
scalar se_theta_delta = sqrt(theta_v[1,1])

testnl -_b[exper]/(2*_b[expersq]) = 20

scalar chi2_nonlinear = r(chi2)
scalar p_nonlinear = r(p)

test exper + 40*expersq = 0

scalar F_linear = r(F)
scalar p_linear = r(p)

display "Turning point: " %9.5f theta_hat
display "Delta-method SE: " %9.5f se_theta_delta
display "Nonlinear chi-squared: " %9.5f chi2_nonlinear
display "Nonlinear p-value: " %9.5f p_nonlinear
display "Linear F statistic: " %9.5f F_linear
display "Linear p-value: " %9.5f p_linear

// Problem 2(d): Pairs bootstrap (1,000 replications)

bootstrap b_educ=_b[educ] tp=(-_b[exper]/(2*_b[expersq])), ///
    reps(1000) seed(689) saving("$output/ps07_boot.dta", replace): ///
    reg lwage educ exper expersq black south smsa

use "$output/ps07_boot.dta", clear

summarize b_educ
scalar se_educ_boot = r(sd)

summarize tp
scalar se_theta_boot = r(sd)
scalar mean_tp_boot = r(mean)

// Center the bootstrap draws at theta=20 and calculate the p-value

generate double theta_null = tp - mean_tp_boot + 20
scalar observed_distance = abs(theta_hat - 20)

generate byte extreme = abs(theta_null - 20) >= observed_distance if !missing(theta_null)

summarize extreme, meanonly
scalar p_boot = r(mean)

display "Bootstrap SE (educ): " %9.6f se_educ_boot
display "Robust SE (educ): " %9.6f se_robust
display "Bootstrap SE (turning point): " %9.6f se_theta_boot
display "Delta-method SE (turning point): " %9.6f se_theta_delta
display "Centered bootstrap p-value: " %9.4f p_boot

if p_boot < .05 {
    display "Reject H0: turning point = 20 at the 5% level."
}
else {
    display "Fail to reject H0: turning point = 20 at the 5% level."
}

log close
