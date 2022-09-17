clear 
program drop _all 
set more off 
*ssc install matchit 
*ssc install reclink
*ssc install egenmore 

local usr = c(username)
global user `usr'

cd  "C:/Users/$user/Dropbox/mma"
capture mkdir dtafiles 
capture mkdir graphs
capture mkdir tables

import delimited "sherdog_sample", clear

*Clean results 
tab result
replace result = "Loss" if strpos(upper(result),"L")
replace result = "Win" if strpos(upper(result),"WI")
replace result = "Win" if strpos(upper(result),"WO")
replace result = "Draw" if strpos(upper(result),"D")
replace result = "NC" if strpos(upper(result),"C")

gen bin_result=1 if strpos(result,"Win")
replace bin_result=0 if strpos(result,"Loss")

*determine duration of fight
replace time=subinstr(time, " ", "", .)
replace time = subinstr(time,";",":",.)
replace time = subinstr(time,"?",":",.)
replace time = subinstr(time, `"""',  "", .)

split time, p(":") gen(time) /* time3 is empty */

destring time1, replace force /* everyone else is missing */ 
destring time2, replace force /* others are missing */ 
ren time1 minutes
ren time2 seconds 
capture drop time3 

gen fight_time = (round-1)*60*5 + minute*60 + second if round!=. & minute!=.
replace fight_time = 0 if round==0
gen mins = fight_time/60 

*Code the method  
gen ko =(strpos(lower(method),"ko") | (strpos(lower(method),"tko")) & (strpos(lower(method),"pun") | strpos(lower(method),"kick")))

/*
gen tko =strpos(lower(method),"tko")
replace tko=1 if tko>1 
*/
gen decision = strpos(lower(method),"decision")
replace decision = 0 if decision>1 & strpos(lower(method),"overturn")
replace decision = 1 if decision>1 

gen sub =strpos(lower(method),"sub")
replace sub=0 if sub>1 & strpos(lower(method),"tko") /* Tko via punches */ 
recode sub (11=1) 
replace sub=1 if sub>1 & strpos(lower(method),"submission") & !strpos(lower(method),"punch")
replace sub=0 if sub>1 

gen guil = strpos(lower(method),"guil")
replace guil=1 if guil!=. & guil>0

gen triangle = strpos(lower(method),"triangle")
replace triangle=1 if triangle!=. & triangle>0

gen rear_naked = (strpos(lower(method),"nake") & strpos(lower(method),"rear"))
replace rear_naked=1 if rear_naked!=. & rear_naked>0

gen arm_bar = (strpos(lower(method),"arm") & strpos(lower(method),"bar"))
replace arm_bar=1 if arm_bar!=. & arm_bar>0

**Special consideration for drug-related no contests
gen drug_nc = 1 if result=="NC" & strpos(lower(method),"drug")
replace drug_nc = 0 if result=="NC" & !strpos(lower(method),"drug")

*date of fight
gen date_float = date(date,"MDY")
format date_float %td

gen monthly_events = mofd(date_float)
format monthly_events %tm

gen yearly_events = yofd(date_float)
format yearly_events %ty

*how many fights in the data 
gen unique_fights = .5 

/* create a variable for layoff time */
sort name date_float
gen time_off = date_float[_n] - date_float[_n-1] if name[_n]==name[_n-1] /* row _n = # of the current observation */

*how many fights in a career 
gen a_fight = 1 
bysort name year: egen fights_within = total(a_fight) /* determines how many fights each individual has fought */

bysort name: gen dup = cond(_N==1,0,_n) /* show how many times a fighter appears*/
bysort name: egen first_day = min(dup) /* Assumption: first appearance = first pro fight */
bysort name: egen last_day = max(dup) /* Assumption: last appearance = last pro fight */

gen first_fight = 1 if first_day==dup 
replace first_fight = 0 if first_day !=dup

gen last_fight = 1 if last_day==dup
replace last_fight = 0 if last_day !=dup

save "dtafiles/sherdog_clean.dta", replace 

/*date of fight
gen date_2 = date(date,"DMY")
format date_2 %td

replace date_float = date_2 if date_float==.
drop date_2

/* create a variable for layoff time */
sort name date_float
gen time_off = date_float[_n] - date_float[_n-1] if name[_n]==name[_n-1] /* row _n = # of the current observation */


/* Possibly usable code
/* a test file */
import delimited "rawdata/sherdog/Daniel-Cormier-52311.txt", clear


/* Used to change KO's that were the result of a submission to being submissions, exclusively */
foreach x in triangle rear_naked guil arm_bar{
	replace sub =1 if `x'==1
	replace ko = 0 if `x'==1
}

gen decision = strpos(lower(method),"decision")
recode decision (11=1) (7=1) (5=0)