clear
clear matrix
cd "C:\Users\Anna Goodman\Dropbox\GitHub\pct-inputs\01_raw\04_other_data"

	** YLL DISCOUNTING
		import excel "GBD_YLLdeaths\yll_discounting\yll_discount_ratio.xlsx", sheet("YLL discount") firstrow clear
		saveold "GBD_YLLdeaths\yll_discounting\yll_discount_ratio.dta", replace
	
	
	** GBD PREPARATION
		import excel "GBD_YLLdeaths\GBD_download\IHME-GBD_2017_DATA-cb45b832-1_AGedit.xls", sheet("IHME-GBD_2017_DATA-cb45b832-1_A") firstrow clear

		* Aggregate to agecat
			gen female=(sex=="Female")
			bysort measure home_gor female agecat: egen val_sum=sum(age_adjusted_val)
			
		* Reshape to generate YLL / deaths
			gen death=(measure=="Deaths")
			keep home_gor female agecat val_sum death
			duplicates drop
			gen littlen=_n
			bysort home_gor female agecat: egen little2=max(littlen)
			drop littlen
			reshape wide val_sum, i(little2) j(death)
			gen yll_per_death = round(val_sum0/ val_sum1) 
			
		* Merge in discounted yll_per_death
			keep home_gor female agecat yll_per_death
			merge m:1 yll_per_death using "GBD_YLLdeaths\yll_discounting\yll_discount_ratio.dta", keepus(yll_per_death_discounted)
			drop if _m==2 
			
		* Create PCT-ready variables
			order  female agecat home_gor yll_per_death_discounted
			keep female - yll_per_death_discounted
		
		saveold "GBD_YLLdeaths\GBD_YLLperDeath.dta", replace
		bysort female agecat: sum yll // for user manual
