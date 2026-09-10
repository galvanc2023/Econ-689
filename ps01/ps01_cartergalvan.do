clear all
set more off
* ECON 689 - Problem Set 1
* Carter Galvan
* Problem Set 1
global projects: env projects
global storage : env storage
global dataready "$storage/econ689_data/ps01/data"
global code "$projects/econ689/ps01"
global output "$projects/econ689/ps01/output"
cd "$code"
use "$dataready/card.dta", clear
display "$storage"
display "$projects"
display "$dataready"
display "$code"
display "$output"
capture mkdir "$output"
capture mkdir "$dataready"
capture mkdir "$code"
capture log close
log using "$output/ps01_cartergalvan.txt", text replace
* Problem 1: Reproducible storage and projects workflow
display "$storage"
display "$projects"
display "$dataready"
display "$code"
display "$output"
* Problem 2: Generate data and estimate OLS regressions
set seed 68901
clear
set obs 500
generate v = rnormal(8, 2.5)
generate study_hours = max(0, v)
generate w = rnormal(3, 0.45)
generate prior_gpa = min(4, max(0, w))
generate u = rnormal(0, 5)
generate exam_score = 45 + 2.5*study_hours + 6*prior_gpa + u
summarize study_hours prior_gpa exam_score
regress exam_score study_hours
predict exam_fitted
predict exam_residual, residuals
summarize exam_residual
regress exam_score study_hours prior_gpa
save "$dataready/ps01_simulated.dta", replace
* Problem 3: Card data analysis
use "$dataready/card.dta", clear
describe lwage educ exper expersq black south smsa nearc4
summarize lwage educ exper expersq black south smsa nearc4
regress lwage educ
regress lwage educ exper expersq black south smsa
predict lwage_fitted
predict lwage_residual, residuals
summarize lwage_residual
regress educ nearc4
log close
