//per il 18/10/24


**********************************************
* DESCRIPTIVE ANALYSIS OF THE JOB EPISODE PANEL*****************************
*set working directoring, globals locals
cd /Users/paolomicera/Library/CloudStorage/Dropbox/PhDThesis_MiceraPaolo/primo_capitolo/data/sharedata
clear all 
global source "/Users/paolomicera/Library/CloudStorage/Dropbox/PhDThesis_MiceraPaolo/primo_capitolo/data/sharedata/share_rel9-0-0/"

global output "/Users/paolomicera/Library/CloudStorage/Dropbox/PhDThesis_MiceraPaolo/primo_capitolo/data/sharedata/presvenezia/"

global other "/Users/paolomicera/Library/CloudStorage/Dropbox/PhDThesis_MiceraPaolo/primo_capitolo/data/panelonet/clean"

global pino "/Users/paolomicera/Library/CloudStorage/Dropbox/PhDThesis_MiceraPaolo/primo_capitolo/data/panelonet"


//fai la matrice completa di isco 1920-2019
use "$pino/isco1", clear
merge m:m isco year using "$pino/indici_onet_isco_1024"

gsort isco -year

foreach var of varlist physical_demands environmental_condition psychosocial_stressors id_isco physical_demands_n environmental_condition_n psychosocial_stressors_n physical_demands_n_np environmental_condition_n_np psychosocial_stressors_n_np {
    replace `var' = `var'[_n-1] if isco == isco[_n-1] & `var'==.
}

sort isco year 
mdesc
drop _merge
save "$pino/indici_onet_isco_1024_completa", replace


use "$source/sharewX_rel9-0-0_gv_job_episodes_panel.dta", clear



sort mergeid year
*Now, we set the panel, first creating id variable since mergeid is a string variable*
egen id = group(mergeid)
*declear the panel*
xtset id year
order mergeid id year

**how many individuals per wave
*28,465 individuals in wave 3
*62,561 individuals in wave 7

*we have
*28,447 in w3
*63,228 in w7
*total = 91,675 individuals

*There are 14 countries in wave 3
*There are 27 countries in wave 7
/*
preserve
bysort id: keep if _n==1
sort mergeid year
drop if jep_w == 3
tab country
duplicates report mergeid
bys jep_w: tab country
tab country
outsheet using "/Users/paolomicera/Desktop/PhD/primo_capitolo/data/tab_bycountry.csv", replace
tab country jep_w
table country (jep_w gender)
restore
*/



*-- Observations wave 3 and 7 ----*
/*tab jep_w 
/*
  Number of |
       Wave |      Freq.     Percent        Cum.
------------+-----------------------------------
          3 |  1,893,524       30.72       30.72
          7 |  4,271,168       69.28      100.00
------------+-----------------------------------
      Total |  6,164,692      100.00
*/
tab jep_w industry, row
tab industry 
tab isco jep_w if working==1 & retired ==0, missing
/*
 ISCO-08 code: |    Number of Wave
  Title of job |         3          7 |     Total
             . |   117,120     43,544 |   160,664
*/
br  mergeid id year ordjob mainjob working retired isco  if isco == -4 | isco == -7 | isco == -8 
br if mergeid == "AT-001492-02"
*/
*we now solve the problem for having:
*ISCO = -1 --> Don't know
*ISCO = -2 --> Refuse to answer
*ISCO = 0 --> Homemaker
*ISCO = -4 --> Not codable
*ISCO = -7 --> Not yet coded
*ISCO = -8 --> Not applicable
gen isco_m = isco
replace isco_m = . if isco_m == -1 | isco_m == -2| isco_m == 0| isco_m ==-4| isco_m ==-7| isco_m ==-8 | isco_m ==-9
tab isco_m, missing
tab isco_m

*here, what we want to see is how many infos about the isco code I have by id, so how many years worked in which sector does the id's have
egen t = count(isco_m), by(id)
tab t



*having t == 0 says that we have no infos about that individual
drop if t == 0
count if isco_m != isco
*br if isco_m != isco
tab isco_m, missing
*tab isco_
*br if isco_ == -1

*How to deal with retired people? For now we don't count on them
drop if working == 0
egen unique_ids = tag(id)
count if unique_ids == 1

drop if ordjob == .
tab isco_m, missing
*Now we suppouse that individuals who infos about their employment history have in their preavious job history  worked in the same isco sector so we attached the first usable isco code to that preavious years
replace isco_m = isco_m[_n-1] if id==id[_n-1] & isco_m==.


*using gsort we reverse the dataset 
gsort id -year


*we do the same thing assuming that the years after the last usable isco code have the same working sector and so the same isco code
replace isco_m = isco_m[_n-1] if id==id[_n-1] & isco_m==.
list id if isco_m ==.
count if isco_m == .


sort id year

*multiplying the isco code with 3 digits to have an approximation of the 4 digits measure
tab isco_m
replace isco_m=isco_m*10 if isco_m <= 1000
drop isco
rename isco_m isco
tab isco
tab year



 
 
 /*
sort id year
preserve 
keep if work_setting == . & year >= 1960
levelsof isco, local(unique_values)
br if isco == 3319
drop if year == 2019

restore
/*
keep if inlist(isco, 3319, 3414, 3439, 3441, 3452, 3642, 3965, 4111, 4112, 4113, 4115, 4119, 4121, 4122, 4129, 4190, 4232, 4400, 4421, 4422, 4426, 4429, 5121, 5123, 5129, 5133, 5134, 5135, 5139, 5143, 5159, 5219, 5224, 5229, 5233, 5239, 5251, 5313, 5319, 5332, 5434, 6131, 6133, 6212, 7129, 7156, 7299, 7329, 7332, 7335, 7342, 7343, 7381, 7432, 7434, 7539, 7641, 7723, 7931, 8129, 8133, 8135, 8139, 8229, 8334, 8412, 8414, 8419, 8513, 9113, 9114, 9131, 9299, 9323, 9339, 9422, 9434 )
levelsof id, local(unique_ids)
di "`unique_ids'"
*/
br if isco == 5114 | isco == 5323
// devo capire quale sia lo mismatch con gli isco, questi sono tutti gli isco che sono presenti in share ma non sono codificati nella lista ufficiale di ilo... posso droppare le id corrispondenti
br if inlist(isco, 3319, 3414, 3439, 3441, 3452, 3642, 3965, 4111, 4112, 4113, 4115, 4119, 4121, 4122, 4129, 4190, 4232, 4400, 4421, 4422, 4426, 4429, 5121, 5123, 5129, 5133, 5134, 5135, 5139, 5143, 5159, 5219, 5224, 5229, 5233, 5239, 5251, 5313, 5319, 5332, 5434, 6131, 6133, 6212, 7129, 7156, 7299, 7329, 7332, 7335, 7342, 7343, 7381, 7432, 7434, 7539, 7641, 7723, 7931, 8129, 8133, 8135, 8139, 8229, 8334, 8412, 8414, 8419, 8513, 9113, 9114, 9131, 9299, 9323, 9339, 9422, 9434 , 5114, 5323	
	)
	
keep if inlist(isco,1130, 1314, 1325, 1421, 1440, 2122, 2246, 2312, 5323, 6411) 
levelsof id, local(unique_ids)

//3120  4310 c'è stai attento
*/

//queste sono tutte le id da droppare per isco non esistenti nella conversione onet
drop if inlist(id, 33135, 68913, 30662, 34028, 38154, 71153, 71803, 72771, 70903, 71084, 31729, 32424, 32693, 34040, 68741, 72812, 71131, 70992, 71206, 72121, 4160, 72121, 71820, 72162, 71767, 24539, 70957, 71067, 71396, 72210, 8490, 9114, 1975, 4742, 6199, 6473, 6571, 7231, 7535, 7784, 8046, 8095, 9114, 11229, 16579, 19375, 19441, 20649, 21192, 22808, 23157, 23506, 24072, 24084, 24504, 24605, 24742, 25264, 25397, 25458, 25579, 25860, 26964, 27425, 28124, 28740, 28749, 29440, 29477, 32292, 33619, 34914, 35064, 35105, 35354, 35612, 35794, 36071, 36882, 37369, 37572, 38465, 45015, 45086, 45457, 46173, 46193, 5978, 7551, 7738, 7799, 14568, 14791, 15368, 16671, 16745, 18149, 31056, 31790, 31814, 33085, 37670, 61881, 69277, 70936, 71178, 72457, 72883, 72884, 73540, 74183, 79549)

drop if inlist(id, 47532, 56934, 57254, 58407, 58544, 58599, 58877, 59143, 59470, 60265, 60622, 60689, 60850, 61883, 61890, 70697, 70713, 70725, 70726, 70763, 70774, 70775, 70787, 70789, 70791, 70811, 70832, 70848, 70908, 70919, 70923, 70935, 70981, 70982, 70987, 71000, 71020, 71052, 71068, 71086, 71092, 71153, 71172, 71173, 71174, 71192, 71193, 71194, 71210, 71215, 71217, 71244, 71262, 71328, 71330, 71335, 71349, 71390, 71393, 71399, 71439, 71441, 71470, 71499, 71501, 71529, 71559, 71591, 71608, 71622, 71626, 71632, 71646, 71658, 71684, 71688, 71702, 71732, 71739, 71742, 71744, 71756, 71780, 71781, 71815, 71817, 71836, 71853, 71867, 71897, 71915, 71917, 71918, 71934, 71936, 71947, 71951, 71980, 71995, 72015, 72033, 72034, 72051, 72061, 72068, 72069, 72082, 72095, 72097, 72105, 72128, 72137, 72138, 72142, 72153, 72175, 72181, 72229, 72230, 72238, 72240, 72261, 72270, 72280, 72292, 72331, 72340, 72349, 72365, 72389, 72420, 72440, 72444, 72486, 72499, 72518, 72523, 72535, 72556, 72564, 72603, 72613, 72615, 72618, 72638, 72645, 72653, 72670, 72678, 72723, 72726, 72729, 72735, 72764, 72775, 72786, 72792, 72796, 72828, 72832, 72833, 72863, 72864, 72895, 72908, 72929)


local ids 71398 32377 72843 72517 5886 71554 5709 72004 7830 45817 71228 72848 71265 70926 72850 71289 70926 70890 72741 71644 72754 71316 70715 57345 71709 72004 70997 72865 71182 71488 9120 60621 57198 59684 72045 59770 71456 71660 72817 72501 72130 9049 70716 13669 72563 72910 7927 70913

foreach id of local ids {
    drop if id == `id'
}


/*
drop if id == 71398 | id == 32377 | id == 72843 | id == 72517 | id == 5886 | ///
id == 71554 | id == 5709 | id == 72004 | id == 7830 | id == 45817 | id == 71228 | ///
id == 72848 | id == 71265 | id == 70926 | id == 72850 | id == 71289 |///
id == 70890 | id == 72741 | id == 71644 | id == 72754 | id == 71316 | id == 70715 | ///
id == 57345 | id == 71709  | id == 70997 | id == 72865 | id == 71182 | ///
id == 71488 | id == 9120 | id == 60621 | id == 57198 | id == 59684 | id == 72045 | ///
id == 59770 | id == 71456 | id == 71660 | id == 72817 | id == 72501 | id == 72130 | ///
id == 9049 | id == 70716 | id == 13669 | id == 72563 | id == 72910 | id == 7927 |id == 70913| ///
*/


*ISCO non presenti nelle conversione O*NET, approssiamiamo al più vicino


* Crea una macro locale per i vecchi valori
local old_values 1100 1110 1111 1210 1310 1320 1340 1410 1430 2100 2140 2150 2210 2220 2260 2300 2340 2350 2410 2420 2640 2650 2659 3100 3110 3120 3130 3140 3150 3210 3220 3250 3300 3330 3340 3350 3413 3520 4130 4210 4213 4220 4310 4320 4410 5100 5110 5130 5161 5200 5210 5220 5240 5300 5310 5320 6100 6110 6120 6200 6220 7000 7100 7110 7120 7130 7133 7210 7220 7230 7310 7320 7410 7510 7520 7530 7540 8000 8100 8110 8120 8130 8140 8150 8155 8159 8180 8210 8300 8330 8340 9110 9120 9210 9310 9320 9330 9332 9510 9610 9613 9620

* Crea una macro locale per i nuovi valori
local new_values 1112 1112 1112 1211 1311 1321 1341 1411 1431 2111 2141 2151 2211 2221 2261 2310 2341 2351 2411 2421 2641 2651 2651 3111 3111 3121 3131 3141 3151 3211 3221 3251 3311 3331 3341 3351 3412 3521 4131 4211 4214 4221 4311 4321 4411 5111 5111 5131 5162 5211 5211 5221 5241 5311 5311 5321 6111 6111 6121 6210 6221 7111 7111 7111 7121 7131 7132 7211 7221 7231 7311 7321 7411 7511 7521 7531 7541 8111 8111 8111 8121 8131 8141 8151 8156 8157 8181 8211 8311 8331 8341 9111 9121 9211 9311 9321 9331 9333 9520 9611 9612 9621

* Usa un ciclo foreach per applicare il comando recode
local i = 1
foreach old in `old_values' {
    local new : word `i' of `new_values'
    recode isco (`old' = `new')
    local ++i
}



/*
recode isco (1100=1112) ///
             (1110=1112) ///
             (1111=1112) ///
             (1210=1211) ///
             (1310=1311) ///
             (1320=1321) ///
             (1340=1341) ///
             (1410=1411) ///
             (1430=1431) ///
             (2100=2111) ///
             (2140=2141) ///
             (2150=2151) ///
             (2210=2211) ///
             (2220=2221) ///
             (2260=2261) ///
             (2300=2310) ///
             (2340=2341) ///
             (2350=2351) ///
             (2410=2411) ///
             (2420=2421) ///
             (2640=2641) ///
             (2650=2651) ///
             (2659=2651) ///
             (3100=3111) ///
             (3110=3111) ///
			 (3120=3121) ///
             (3130=3131) ///
             (3140=3141) ///
             (3150=3151) ///
             (3210=3211) ///
             (3220=3221) ///
             (3250=3251) ///
             (3300=3311) ///
             (3330=3331) /// 
			(3340 = 3341) ///
            (3350 = 3351) ///
            (3413 = 3412) ///
            (3520 = 3521) ///
			(4130 = 4131) ///
            (4210 = 4211) ///
            (4213 = 4214) ///
            (4220 = 4221) ///
			(4310 = 4311) ///
            (4320 = 4321) ///
            (4410 = 4411) ///
            (5100 = 5111) ///
            (5110 = 5111) ///
            (5130 = 5131) ///
            (5161 = 5162) ///
            (5200 = 5211) ///
            (5210 = 5211) ///
            (5220 = 5221) ///
            (5240 = 5241) ///
            (5300 = 5311) ///
            (5310 = 5311) ///
            (5320 = 5321) ///
			(6100=6111) ///
             (6110=6111) ///
             (6120=6121) ///
             (6200=6210) ///
             (6220=6221) ///
             (7000=7111) ///
             (7100=7111) ///
             (7110=7111) ///
             (7120=7121) ///
             (7130=7131) ///
             (7133=7132) ///
             (7210=7211) ///
             (7220=7221) ///
             (7230=7231) ///
             (7310=7311) ///
             (7320=7321) ///
             (7410=7411) ///
             (7510=7511) ///
             (7520=7521) ///
			 (7530=7531) ///
             (7540=7541) ///
             (8000=8111) ///
			 (8100=8111) ///
             (8110=8111) ///
             (8120=8121) ///
             (8130=8131) ///
             (8140=8141) ///
             (8150=8151) ///
             (8155=8156) ///
             (8159=8157) ///
             (8180=8181) ///
             (8210=8211) ///
             (8300=8311) ///
             (8330=8331) ///
             (8340=8341) ///
             (9110=9111) ///
             (9120=9121) ///
             (9210=9211) ///
             (9310=9311) ///
             (9320=9321) ///
             (9330=9331) ///
             (9332=9333) ///
             (9510=9520) ///
             (9610=9611) ///
             (9613=9612) ///
             (9620=9621)
*/		 
			 
//merge with onet indicators
merge m:m isco year using  "${pino}/indici_onet_isco_1024_completa"
sort mergeid id year jep_w
br

drop if id ==.
drop hhid7 hhid3
 drop if situation == 8 //in realtà qua avevi fatto veloce e avevi droppato tutti i retired, non è che visto che alcune volte ci sono solo 1 spell poissiamo pìmantenerlo cosi da avere più dati quando mergiamo con share?
drop if situation == 10
order currency_fw first_income currency_fi reason_endjob afterlast lastwage currency_lw lastincome currency_li first_pension currency_fp, after(_merge)


foreach var of varlist physical_demands environmental_condition psychosocial_stressors id_isco physical_demands_n environmental_condition_n psychosocial_stressors_n physical_demands_n_np environmental_condition_n_np psychosocial_stressors_n_np {
    replace `var' = `var'[_n-1] if isco == isco[_n-1] & `var'==.
}




		 
/*			 
drop if id == 71398 
drop if id == 32377
drop if id == 72843
drop if id == 72517
drop if id == 5886			 
drop if id == 71554		 
drop if id == 5709
drop if id == 72004
drop if id == 7830
drop if id == 45817
drop if id == 71228
drop if id == 72848
drop if id ==		71265
drop if id ==		70926
drop if id ==		72850
drop if id ==		71289
drop if id ==		70926
drop if id ==		70890
drop if id ==		72741
drop if id ==		71644
drop if id ==		72754
drop if id ==		71316
drop if id ==		70715
drop if id ==		57345
drop if id ==		71709
drop if id ==		72004
drop if id ==		70997
drop if id ==		72865
drop if id ==		71182
drop if id ==		71488
drop if id ==		9120
drop if id ==		60621
drop if id ==		57198 
drop if id ==		59684
drop if id ==		72045
drop if id ==		59770
drop if id ==		71456
drop if id ==		71660
drop if id ==		72817
drop if id ==		72501
drop if id ==		72130
drop if id ==		9049
drop if id ==		70716
drop if id ==		13669
drop if id ==	72563
drop if id ==	72910
drop if id ==	7927
drop if id ==	70913
*/


br
mdesc
sort id year
foreach var in physical_demands_n_np environmental_condition_n_np psychosocial_stressors_n_np {
    replace `var' = `var' * 100
}


order physical_demands environmental_condition psychosocial_stressors id_isco physical_demands_n environmental_condition_n psychosocial_stressors_n physical_demands_n_np environmental_condition_n_np psychosocial_stressors_n_np, after(isco)

order first_wage country_res_ nchildren_nat nchildren age_youngest age_youngest_nat withpartner married contrib_employee contrib_employer early_ret_reduction currency_min_pension currency_max_pension ret_age early_age min_pension max_pension current_wage current_currency_w current_income current_currency_i, after(t)


sort id year
mdesc

//ci sono working ==1 con situation strane, teniamo solo gli id che hanno sit == 1
gen situation_is_1 = (situation == 1)
bysort id: egen not_1 = total(situation != 1)
count if not_1 == 0

bysort id: drop if not_1 != 0
recode working_hours -2=1 -1=1 .=1 2=0.5 3=0.75 4=0.75 5=0.75



bys id (year): gen y_start_working = yrbirth + age if _n==1
bysort id: replace y_start_working = y_start_working[_n-1] if missing(y_start_working)
label var y_start_working  "First year of work"
order mergeid id year jep_w gender yrbirth age y_start_working
gen n_job_spell = .
bysort id (ordjob): replace n_job_spell = ordjob if _n == _N
gsort id -year
bys id: replace n_job_spell = n_job_spell[_n-1] if missing(n_job_spell)

sort id year

order mergeid id year jep_w gender yrbirth age y_start_working n_job_spell
* Crea una variabile che conta il numero di osservazioni (anni) per ogni id
egen n_years = count(year), by(id)



* Preserva il dataset originale
preserve

* Filtra solo gli id con n_years > 20
keep if n_years > 20 and 

* Collapsa il dataset per ottenere la media dei job spells per anno di inizio della carriera
collapse (mean) n_job_spell, by(y_start_working)

* Crea il grafico di dispersione (scatter plot)
twoway (scatter n_job_spell y_start_working), ///
    ytitle("Numero di Job Spells") ///
    xtitle("Anno di Inizio della Carriera") ///
    title("Job Spells per Anno di Inizio della Carriera")

* Ripristina il dataset originale
restore
   
   
   
   


local vars  physical_demands environmental_condition psychosocial_stressors
foreach var of local vars {
	bysort id (year): gen `var'_whours = `var'*working_hours
}



rename physical_demands_whours ph_wh
rename environmental_condition_whours ec_wh
rename psychosocial_stressors_whours   ps_wh 



local vars    ph_wh ec_wh ps_wh
foreach var of local vars {
	bysort id (year): gen cum_`var' = sum(`var')
}



 



local vars  physical_demands_n environmental_condition_n psychosocial_stressors_n physical_demands_n_np environmental_condition_n_np psychosocial_stressors_n_np
foreach var of local vars {
	bysort id (year): gen cum_`var' = sum(`var')
}

save "${source}/job_episode_con_indici_cumulati", replace
use "${source}/job_episode_con_indici_cumulati", clear










keep if inlist(country, 13, 18, 23, 12, 17, 20, 16, 11, 15)
keep if year >= 2004
histogram y_start_working, width(2) xlabel(1940(10)2020)

graph export "histogram_y_start_working.png", as(png) replace
save "${source}/job_episode_con_indici_cumulati_dal2004", replace
use  "${source}/job_episode_con_indici_cumulati_dal2004", clear
drop _merge 
save "${source}/job_episode_con_indici_cumulati_dal2004", replace

use "/Users/paolomicera/Downloads/health_index_MP.dta", clear
use "/Users/paolomicera/Downloads/health_index_MP1.dta", clear
drop ph006d1_m ph006d2_m ph006d3_m ph006d4_m ph006d5_m ph006d6_m ph006d10_m ph006d11_m ph006d12_m ph006d13_m ph048d1_m ph048d2_m ph048d3_m ph048d4_m ph048d5_m ph048d6_m ph048d7_m ph048d8_m ph048d9_m ph048d10_m ph049d1_m ph049d2_m ph049d3_m ph049d4_m ph049d5_m ph049d6_m ph049d7_m ph049d8_m ph049d9_m ph049d10_m ph049d11_m ph049d12_m ph049d13_m
label var prob_at_least_poor_health "Probability of being in fair or poor health"

merge 1:1 mergeid year using "${source}/job_episode_con_indici_cumulati_dal2004"
sort mergeid id wave year age
bys id: gen w = (physical_demands_n != .)
bys id: egen w_t1 = total(w==1)
drop if _merge == 2
drop if w_t1 <=1
drop if cum_physical_demands_n ==.
egen id_finale=group(mergeid)


tab country wave, summarize(unique_ids)

preserve
collapse (count) id_finale, by(country wave)
tab country wave
restore

replace id =id_finale
order ph003_, after(ph049d13)

xtset id year


preserve
bysort id : keep if _n == 1
tab country wave
restore


drop t_4C1a4 t_4C1b1f t_4C1b1g t_4C1c1 t_4C1c2 t_4C1d1 t_4C1d2 t_4C1d3 t_4C2a1a t_4C2a1c t_4C2b1a t_4C2b1b t_4C2b1c t_4C2b1d t_4C2b1e t_4C2b1f t_4C2c1a t_4C2c1b t_4C2c1c t_4C2c1d t_4C2c1e t_4C2c1f t_4C2d1a t_4C2d1b t_4C2d1c t_4C2d1d t_4C2d1e t_4C2d1f t_4C2d1g t_4C2d1h t_4C2d1i t_4C2e1d t_4C2e1e t_4C3a1 t_4C3b2 t_4C3b4 t_4C3b7 t_4C3d3 t_4C1a2c t_4C1a2f t_4C1a2h t_4C1a2j t_4C1a2l t_4C1b1e t_4C2a1b t_4C2a1d t_4C2a1e t_4C2a1f t_4C2a3 t_4C3a2a t_4C3a2b t_4C3a4 t_4C3b8 t_4C3c1 t_4C3d1 t_4C3d4 t_4C3d8

drop _merge w w_t w_t1 id_finale

gen y = 1
bysort id: egen sum_var = total(y)
hist sum_var ,freq
drop if sum_var == 1

bysort id: gen y1 = .  
bysort id: replace y1 = sum_var if _n == 1  // Copia il valore solo per il primo ID
hist y1, freq
graph export "histogram_n_of_waves_followed" , as(pdf) replace
label var y1 "Number of waves for which individuals have been followed"

bysort wave id: gen tag = _n == 1
bysort wave: egen count_ids = total(tag)
tab country wave 

tab country female
bysort id (country female): gen tag1 = _n == 1   // Tagga solo la prima osservazione per ciascun id
tab country female if tag1 == 1                  // Esegui il tab solo sugli ID unici
sort mergeid id wave year
replace id = id1



* Genera il primo grafico e salvalo temporaneamente
preserve
collapse (mean) p1, by(wave)
twoway (line p1 wave), ///
    ytitle("Average probability") ///
    xtitle("Wave") ///
    title("Time trend in Probability of being in excellent health") ///
    xlabel(2004 2006 2011 2013 2015 2017)
graph save "graph_excellent_health.gph", replace
restore

* Genera il secondo grafico e salvalo temporaneamente
preserve
collapse (mean) prob_at_least_poor_health, by(wave)
twoway (line prob_at_least_poor_health wave), ///
    ytitle("Average probability") ///
    xtitle("Wave") ///
    title("Time trend in Probability of being in fair or poor health") ///
    xlabel(2004 2006 2011 2013 2015 2017)
graph save "graph_poor_health.gph", replace
restore

* Combina i due grafici con dimensioni ridotte
graph combine "graph_excellent_health.gph" "graph_poor_health.gph", ///
    title("Combined Health Probabilities") ///
    imargin(zero) ///
    xsize(5) ysize(3)

* Esporta il grafico combinato come PDF
graph export "Combined_Health_Probabilities.pdf", as(pdf) replace

* Calcola le medie per ogni wave
bysort wave: summarize prob_at_least_poor_health

* Per salvare le medie per ogni wave
* Calcola la media per ogni wave
table wave, statistic(mean prob_at_least_poor_health)


* Calcolo delle differenze tra le medie delle wave consecutive
reg prob_at_least_poor_health i.wave

* Verifica delle differenze di media con test di significatività tra wave 1 e wave 2
ttest prob_at_least_poor_health if wave == 2006 | wave == 2004, by(wave)

* Verifica delle differenze di media con test di significatività tra wave 2 e wave 3
ttest prob_at_least_poor_health if wave == 2006 | wave == 2011, by(wave)

* Ripeti per tutte le altre wave consecutive
ttest prob_at_least_poor_health if wave == 2011 | wave == 2013, by(wave)


ttest prob_at_least_poor_health if wave == 2013 | wave == 2015, by(wave)
ttest prob_at_least_poor_health if wave == 2015 | wave == 2017, by(wave)


* Esegui il t-test


* Salva il valore della differenza

scalar diff_mean1 = r(mu_2) - r(mu_1)



display diff_mean1  diff_mean2


* Salva il p-value per Ha: diff != 0
scalar p_value = r(p)

* Visualizza i risultati salvati
display "Differenza media: " diff_mean
display "p-value: " p_value










gen isco_1d =floor(isco/1000)



//need to compute the normalization of the indicies
rename cum_physical_demands_n_np cum_ph_p

rename cum_environmental_condition_n_np cum_env_p
rename cum_psychosocial_stressors_n_np cum_psy_p

local vars cum_ph_p cum_env_p cum_psy_p
foreach var of local vars {
	egen `var'_mean=mean(`var')
	
}

foreach var of local vars {
	egen `var'_sd=sd(`var')
	
}

foreach var of local vars {
	gen `var'_stand=(`var'-`var'_mean)/`var'_sd
	
}
gen age2=age^2

xtset id year
rename prob_at_least_poor_health p_bad_h
local y p_bad_h
local x cum_ph_p_stand cum_env_p_stand cum_psy_p_stand

regress `y' `x' if gender == 0, vce(robust)  // Regressione per le donne
regress `y' `x' if gender == 1, vce(robust)  // Regressione per gli uomini



* Regressione per donne
xtreg `y' `x' if gender == 0, fe vce(robust)

* Regressione per uomini
xtreg `y' `x' if gender == 1, fe vce(robust)




egen cum_ph_p_stand_z = std(cum_ph_p)
egen cum_env_p_stand_z = std(cum_env_p)
egen cum_psy_p_stand_z = std(cum_psy_p)

//recode gender 1 femmine 0 maschi
gen female = . 
replace female = 1 if gender == 1
replace female = 0 if gender == 0
label define gender_lbl 0 "Male" 1 "Female"
label values female gender_lbl


save "waves_panel_reg", replace
drop sum_lim morbidity 
egen sum_lim= rowtotal(ph048d1 ph048d2 ph048d3 ph048d4 ph048d5 ph048d6 ph048d7 ph048d8 ph048d9 ph048d10 depressione ph006d1 ph006d2 ph006d3 ph006d4 ph006d5 ph006d6 ph006d10 ph006d11 ph006d12 ph006d13 ph049d1 ph049d2 ph049d3 ph049d4 ph049d5 ph049d6 ph049d7 ph049d8 ph049d9 ph049d10 ph049d11 ph049d12 ph049d13)
label var sum_lim "Total of number of chronic disease and limitations"
tab sum_lim
gen morbidity = sum_lim/34
label var morbidity "Morbidity Index"
tab morbidity

egen chronic = rowtotal(ph006d1 ph006d2 ph006d3 ph006d4 ph006d5 ph006d6 ph006d10 ph006d11 ph006d12 ph006d13)

tab chronic
tab age
* Inizializza age_bin1 come variabile stringa
gen str10 age1 = ""

* Assegna i valori di testo a age_bin1 in base all'intervallo di età
replace age1 = "50-54" if age >= 50 & age <= 54
replace age1 = "55-59" if age >= 55 & age <= 59
replace age1 = "60-64" if age >= 60 & age <= 64
replace age1 = "65-69" if age >= 65 & age <= 69
replace age1 = "70-74" if age >= 70 & age <= 74


tab age1


 bys female : tab  age1 chronic if age1_code <= 4, nofreq row
 
encode age1, gen (age1_code)
tab age1_code


tab chronic age_bin1
tab chronic age_bin2
tab chronic age_bin3
tab chronic age_bin4
tab chronic age_bin5





preserve
collapse (mean) morbidity, by(wave )
twoway (line morbidity wave), ///
    ytitle("Average Index") ///
    xtitle("Wave") ///
    title("Time trend in Morbidity index ") ///
    xlabel(2004 2006 2011 2013 2015 2017)
graph save "graph_morbidity.gph", replace
restore
* Converti la variabile age_bin in numerica con etichette
encode age_bin, gen(age_bin_num)

* Visualizza le etichette create
label list age_bin_num

* Ora puoi usare age_bin_num per il grafico
twoway (area chronic_0 age_bin_num, sort) (area chronic_1 age_bin_num, sort) ///
    (area chronic_2 age_bin_num, sort) (area chronic_3 age_bin_num, sort) ///
    (area chronic_4 age_bin_num, sort) (area chronic_5 age_bin_num, sort), ///
    ytitle("Percentuale") xtitle("Intervallo di Età") ///
    legend(order(1 "0" 2 "1" 3 "2" 4 "3" 5 "4" 6 "5+" )) ///
    xlabel(1 "50-54" 2 "55-59" 3 "60-64" 4 "65-69" )


	
	
	
	
	
	
	
rename age1 age_bin


* Crea la variabile che assume 1 se wave è 2013 per un dato id
bys id: gen wave_2013 = (wave == 2013)

* Crea una variabile temporanea che verifica se esistono sia wave 2013 che wave 2015
bys id: egen check_2013 = max(wave == 2013)
bys id: egen check_2015 = max(wave == 2015)

* Crea la variabile che assume 1 se esistono sia wave 2013 che wave 2015
bys id: gen wave_2013_and_2015 = (check_2013 == 1 & check_2015 == 1)

tab wave_2013
tab wave_2013_and_2015


save "wavewave", replace
use "wavewave",clear








keep mergeid isced1997_r isced1997_m isced1997_f
rename isced1997_r education
rename isced1997_f education_mother
rename isced1997_m education_father 
qui: mvdecode _all, mv(95 97 -1 -2 -3 -4 -5 -7 -9 -91 -92 -93 -94 -95 -97 -98 -99 -9999991 -9999992)





foreach var of varlist education education_father education_mother {
    tab `var', nol
}
tab isced1997_r
gen education = .
replace education = 1 if isced1997_r >= 0 & isced1997_r <= 2
replace education = 2 if isced1997_r >= 3 & isced1997_r <= 4
replace education = 3 if isced1997_r >= 5 & isced1997_r <= 6


* Per ciascuna variabile, calcola la media e la deviazione standard, poi crea la variabile standardizzata

foreach var in cum_ps_wh cum_ph_wh cum_ec_wh {
    * Calcola la media e la deviazione standard
    su `var'
    
    * Crea la versione standardizzata della variabile
    gen `var'_std = (`var' - r(mean)) / r(sd)
}






bysort id: replace edu = edu[_n-1] if missing(edu)
reg sphus2 cum_ps_wh_std cum_ph_wh_std cum_ec_wh_std i.education c.age##c.age married if gender == 1 & age >= 50 & age <= 65, vce(robust)




label var cum_ps_wh_std "Psycosocial"
label var cum_ph_wh_std  "Physical"
label var cum_ec_wh_std "Environmental"

label define education 2 "Educated" 3 "Highly Educated"
label values education education

* Regressioni per gender == 1 (donne)
reg prob_at_least_poor_health cum_ps_wh_std cum_ph_wh_std cum_ec_wh_std i.education c.age##c.age married  if gender == 1 & age >= 50 & age <= 65, vce(robust)
est store  Female_poor_health

reg morbidity cum_ps_wh_std cum_ph_wh_std cum_ec_wh_std i.education c.age##c.age married  if gender == 1 & age >= 50 & age <= 65, vce(robust)
est store  Female_morbidity

reg sphus cum_ps_wh_std cum_ph_wh_std cum_ec_wh_std i.education c.age##c.age married  if gender == 1 & age >= 50 & age <= 65, vce(robust)
est store  Female_sphus

* Regressioni per gender == 0 (uomini)
reg prob_at_least_poor_health cum_ps_wh_std cum_ph_wh_std cum_ec_wh_std i.education c.age##c.age married  if gender == 0 & age >= 50 & age <= 65, vce(robust)
est store Male_poor_health

reg morbidity cum_ps_wh_std cum_ph_wh_std cum_ec_wh_std i.education c.age##c.age married  if gender == 0 & age >= 50 & age <= 65, vce(robust)
est store Male_morbidity

reg sphus cum_ps_wh_std cum_ph_wh_std cum_ec_wh_std i.education c.age##c.age married  if gender == 0 & age >= 50 & age <= 65, vce(robust)
est store male_self_reported

**# Bookmark #3

		 
		 


* Primo grafico: Poor Health
coefplot (Male_poor_health, recast(scatter) color(navy) msymbol(O)) ///
         (Female_poor_health, recast(scatter) color(red) msymbol(O)), ///
    yline(0) drop(_cons c.age#c.age age married  ) vertical ///
    title("Health Index for Men and Women (50-65)") ///
    legend(order(1 "Male" 2 "Female") colfirst rows(1) position(12)) ///
    name(poor_health, replace)

* Secondo grafico: Morbidity
coefplot (Male_morbidity, recast(scatter) color(navy) msymbol(O)) ///
         (Female_morbidity, recast(scatter) color(red) msymbol(O)), ///
    yline(0) drop(_cons c.age#c.age age married) vertical ///
    title("Morbidity Index for Men and Women (50-65)") ///
    legend(order(1 "Male" 2 "Female") colfirst rows(1) position(12)) ///
    name(morbidity_health, replace)

* Combinare i grafici
graph combine poor_health morbidity_health, cols(2)

* Salvare il grafico combinato
graph export "combined_health_graphs.pdf", as(pdf) replace

**# Bookmark #4
		 
		 

reg prob_at_least_poor_health cum_ps_wh_std cum_ph_wh_std cum_ec_wh_std i.education c.age##c.age married if gender == 1 & age >= 50 , vce(robust)

reg prob_at_least_poor_health cum_ps_wh_std cum_ph_wh_std cum_ec_wh_std i.education c.age##c.age married if gender == 0 & age >= 50 , vce(robust)









xtreg prob_at_least_poor_health cum_ps_wh_std cum_ph_wh_std cum_ec_wh_std i.education c.age##c.age married if gender == 1 & age >= 50 & age <= 65, fe vce(robust)

















