use "dtafiles/sherdog_clean.dta", clear 

keep if year<=2019 & year >=1990 
keep if mins<=15 

* total number of fights 
preserve 
collapse (sum) unique_fights , by(year)
twoway line unique_fights year ||, ///
	yti("Total Fights") xti("Year") ylabel(,angle(horizontal)) ///
	graphregion(color(white)) bgcolor(white) 
	gr export "graphs/total_fights.png", replace
restore

/* how many new fighters enter the sport*/
preserve 
collapse (mean) first_fight , by(year)
twoway line first_fight yearl ||, ///
	yti("Proportion") xti("Year") ylabel(,angle(horizontal)) ///
	ylabel(0(.1).4, angle(horizontal)) ///
	graphregion(color(white)) bgcolor(white) 
	gr export "graphs/new_entries.png", replace
restore

/* Fights per fighter */
preserve
collapse (mean) fights_within , by(year)
twoway line fights_within year ||, ///
	yti("Average Fights") xti("Year") ylabel(,angle(horizontal)) ///
	graphregion(color(white)) bgcolor(white)
	gr export "graphs/fights_within.png", replace
restore 

/* lay off times */
preserve
collapse (mean) time_off if time_off!=., by(year) 
twoway line time_off year ||, ///
	yti("Average Days") xti("Year") ylabel(,angle(horizontal)) ///
	graphregion(color(white)) bgcolor(white) 
	gr export "graphs/layoff_time.png", replace
restore

/* how many fighters exit the sport*/
preserve 
collapse (mean) last_fight , by(year)
twoway line last_fight yearl ||, ///
	yti("Proportion") xti("Year") ylabel(,angle(horizontal)) ///
	ylabel(0(.1).4, angle(horizontal)) ///
	graphregion(color(white)) bgcolor(white) 
	gr export "graphs/fighter_exits.png", replace
restore

/* Duration of fights each year */
preserve
collapse (mean) mins , by(year)
twoway line mins year ||, ///
	yti("Average Minutes") xti("Year") ylabel(,angle(horizontal)) ///
	graphregion(color(white)) bgcolor(white) 
	gr export "graphs/fight_time.png", replace
restore 



********************************************************************************
*More Specific 
********************************************************************************
preserve 
collapse (mean) time_off last_fight mins , by(yearly_events sub ko decision) /* best way to get three round fights */
twoway line mins yearly_events if sub==1, lc(black%75) || ///
	line mins yearly_events if ko==1 , lc(blue%75)|| ///
	line mins yearly_events if decision==1 , lc(red%75) ||, ///
	yti("Average Minutes") xti("Year") ///
	legend(order(1 "Submission" 2 "KO" 3 "Decision") cols(3)) ///
	graphregion(color(white)) bgcolor(white)  ylabel(, angle(horizontal)) 
	gr export "graphs/fight_time_bymethod.png", replace 
restore 

preserve
keep if bin_res == 1
collapse (mean) ko sub decision , by(year)
twoway line ko yearly_events , lc(blue%75) ||, ///
	yti("Proportion of Fights") xti("Year") ///
	graphregion(color(white)) bgcolor(white) ylabel(0(.1).4, angle(horizontal))
	gr export "graphs/ko_wins.png", replace
	
twoway line decision yearly_events , lc(red%75) ||, ///
	yti("Proportion of Fights") xti("Year")  ///
	graphregion(color(white)) bgcolor(white) ylabel(0(.1).4, angle(horizontal))
	gr export "graphs/decision_wins.png", replace
	
twoway line sub yearly_events , lc(black%75) ||, ///
	yti("Proportion of Fights") xti("Year") ///
	graphregion(color(white)) bgcolor(white) ylabel(0(.1).6, angle(horizontal))
	gr export "graphs/submission_wins.png", replace
restore 


*Types of submissions 
preserve
keep if bin_res == 1 & sub==1
collapse (mean) guil rear_naked triangle, by(yearly_event) 
twoway line guil yearly_events , lc(blue%75) || ///
	line rear_naked yearly_events , lc(black%75) || ///
	line triangle yearly_events  , lc(red%75) ||, ///
	legend(order(1 "Guillotine" 2 "Rear-Naked Choke" 3 "Triangle Choke") cols(3)) ///
	yti("Proportion of Submissions") xti("Year") ylabel(0(.1).5, angle(horizontal)) ///
	graphregion(color(white)) bgcolor(white) 
	gr export "graphs/submission_types.png", replace
restore 