clear
cls

import delimited "/Users/mikeshi/Desktop/ECON 419/Final Project/SBAcase.csv"

set seed 123456
gen random = uniform()
sort random
gen byte train = (_n <= (_N*0.5))

gen rev_credit = 1 if revlinecr == "Y"
replace rev_credit = 0 if revlinecr != "Y"

gen low_doc = 1 if lowdoc == "Y"
replace low_doc = 0 if lowdoc != "Y"

sum term rev_credit disbursementgross new portion recession train default

logit default new term disbursementgross portion recession rev_credit if train == 1

logit default term disbursementgross portion rev_credit if train == 1

gen default_logit = 1/(1+exp(-_b[_cons]-_b[term]*term-_b[disbursementgross]*disbursementgross-_b[portion]*portion-_b[rev_credit]*rev_credit))


gen approve_logit = 1 if default_logit <= 0.4
replace approve_logit = 0 if default_logit > 0.4

gen misrate_logit = 1 if default == approve_logit
replace misrate_logit = 0 if default != approve_logit

sum misrate_logit if train  == 0

sum misrate_logit if train == 0 & approve_logit == 1 & misrate_logit == 0
sum misrate_logit if train == 0 & approve_logit == 1 & misrate_logit == 1
sum misrate_logit if train == 0 & approve_logit == 0 & misrate_logit == 0
sum misrate_logit if train == 0 & approve_logit == 0 & misrate_logit == 1

chaidforest default, ordered(rev_credit) xtile(term disbursementgross portion)

predict default_prob

gen approve_rf = 1 if default_prob1 <= 0.5
replace approve_rf = 0 if default_prob1 > 0.5

gen misrate_rf = 1 if default == approve_rf
replace misrate_rf = 0 if default != approve_rf

sum misrate_rf

sum misrate_rf if approve_rf == 1 & misrate_rf == 0
sum misrate_rf if approve_rf == 1 & misrate_rf == 1
sum misrate_rf if approve_rf == 0 & misrate_rf == 0
sum misrate_rf if approve_rf == 0 & misrate_rf == 1

