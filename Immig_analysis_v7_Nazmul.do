*Stata do file for Nazmul 

*the analysis...

*2023 Summer version 7
/* This new version is my best attempt to get the identification correct, especially to account for 
the exogeneity issues with the earlier models.  What am I doing...

1. I am dumping the idea of using the 2nd lag, because I can use the Rational Distributed Lag model 
to get an estimate of the long run propensity of Economic Freedome on immigration.  (see page 638 on undergrad
Wooldridge book)  This is a fine models assuming that weak exogeneity holds. 

2. I am still using first differencing, for the specific reason to account for unobserved endogenity, but
given the time series structure of the data, this is also accounting for any potential autocorrelations in the 
error terms and unit root behavior. 

For now, I will  test for unit root behavior, but this may be something to look into regarding tables in 
an appendix. (see page 641 in undergrad book here too)

but for the panel error correction model, here is a citiation

Persyn, Damiaan, and Joakim Westerlund. "Error-correction–based cointegration tests for panel data." The STATA journal 8.2 (2008): 232-241.

and 

Westerlund, J. 2007. Testing for error correction in panel data.  Oxford Bulletin of Economics and Statistics 69: 709-748.

3. In our model, see about the contemporanous term and the lags of the economic freedom variable. 

4. Got to have time dummies

5. So we are definately limited one what we can run given the lack of data.  For example the Arrellano-Bond model 
will not work, nor does any GMM method because of the use of multiple lags of the DV for IVs. 

See the graduate Wooldridge book table 11.2, page 373.  This is a good explanation. 

Also see examples 11.3 and 11.4 in graduate wooldridge book

6.  Per an IHS seminar this April on immigration, it was recommended I do the following 
	- Use a Southern Border dummy
	- See if there is an Xenophobia dataset for different states (I decided against this, because these are so tied together, so I will get to that later)
	- collect a measure of business dynamics.  This is collected here. https://www.census.gov/data/datasets/time-series/econ/bds/bds-datasets.html
	
	If you check out the source file, there is a code book


*/

	clear  all                                
	set mem 1000m                           
	capture set maxvar 10000                         
	set more off  
	cd "C:\Users\mkass\Dropbox (IT (30) Advanced)\Research\Immigration_EF_Nazmul\datafiles"
	set logtype text
	capture log close
	log using analysis2023.log , replace
	set more off
	version 13

*cap net set ado "C:\ado\personal"
adopath + "C:\ado\personal"

set varabbrev off
global ImmigProject "$DROPBOX/Malcolm Kass/Research/Immigration_EF_Nazmul"

net install regsave, from("https://raw.githubusercontent.com/reifjulian/regsave/master") replace
ssc install xtabond2

*run "C:\Users\mkass\IT (30) Advanced Dropbox\Malcolm Kass\Research\Immigration_EF_Nazmul\datafiles\controls_to_dta.v5.do"
use ef_immig_data_v5.dta, replace


gsort year state_id
xtset state_id temp_pew

*now for the tables...
********************************************************************************
*********************************************************************************
*table 1a - Inflow variable :  Just looking at the economics freedom scores

/*My approprach is similar to the approprach for time series models.  We have no 
guidance in terms of theory for how the dynamics should work for these models.  
Hence we should rely on the results from estimation.  This mainly means that we 
need to add contemporanous terms to our model. (there is a paper for this called 
"Taking time seriously" and also explains this. )

Now we still need to take care about endogenity, hence we still need to take into
account first differences, control variable, include time dummies.  Hence, we will work with an Error 
Correction Model that accounts for the error correction terms in the model. 

First the immig_inflow_unau_pew inflow varaible, which is the long run, I do think is a superior variable...
*/

******************************************************************************
*Results table, just look at the labor market freedom for the variable of interest. inflow DV  variable.  Panel data methods

* Y =  immig_inflow, X = lag labor score. no contols
reg d.immig_inflow_unau_pew ///
l.d.immig_inflow_unau_pew ///
d.l.zlaborscore ///
if contus == 1, robust cluster(state_id)
estimates store M1
*this works!!!  FE works too

* Y =  immig_inflow, X = lag labor score, controls
reg d.immig_inflow_unau_pew ///
l.d.immig_inflow_unau_pew ///
d.l.zlaborscore ///
d.l.zurban d.l.zPersonalFreedom d.l.zlinc_pers d.l.zheatdays ///
if contus == 1, robust cluster(state_id)
estimates store M1


reg d.immig_inflow_unau_pew ///
d.zlaborscore ///
d.l.zlaborscore ///
if contus == 1, robust cluster(state_id)
*so here, evidence that scenario 2b may hold. 

reg d.immig_inflow_unau_pew ///
d.l.immig_inflow_unau_pew ///
d.zlaborscore ///
d.l.zlaborscore ///
i.temp_pew if contus == 1, robust cluster(state_id)
estimates store M1


**********************************************************************************
*check up table, this is for see if there is comptemporary correlation between X and Y and another condition

*m1a Y =  immig_inflow, X = labor score, control = none (2b in the Bellmare papaer)
reg d.immig_inflow_unau_pew ///
d.zlaborscore ///
d.l.zlaborscore ///
i.temp_pew if contus == 1, robust cluster(state_id)
*no evidence of a contemporanous relationship between x and Y

*m1b Y =  immig_inflow, X = labor score, control = none (2c in the Bellmare papaer)
reg d.immig_inflow_unau_pew ///
d.zlaborscore ///
d.l.immig_inflow_unau_pew /// ///
i.temp_pew if contus == 1, robust cluster(state_id)
*no evidence of dynamics in the dependent variable, this is good

*m2a Y =  immig_inflow, X = labor score, control = yes (2b in the Bellmare papaer)
reg d.immig_inflow_unau_pew ///
d.zlaborscore ///
d.l.zlaborscore ///
i.temp_pew if contus == 1, robust cluster(state_id)
*no evidence of a contemporanous relationship between x and Y

*m2b Y =  immig_inflow, X = labor score, control = yes (2c in the Bellmare papaer)
reg d.immig_inflow_unau_pew ///
d.zlaborscore ///
d.l.immig_inflow_unau_pew /// ///
i.temp_pew if contus == 1, robust cluster(state_id)
*no evidence of dynamics in the dependent variable, this is good












/*Nazmul, so some notes on this model.  Overall, what we are doing is a general auto
distrubed lag model, where we are estimated short and long run effects using a panel error correction 
model. Key is that the ECM method is important with regards to the ideas of equilibrium 

Here, 
*/

xtunitroot ht immig_inflow_unau_pew, demean
*Harris-Tzavalis (HT) (1999) unit root test, null is data contains unit root, no unit root with this data at 5% level. (p=0.04)
xtunitroot ht zef_temp, demean
*Harris-Tzavalis (HT) (1999) unit root test, null is data contains unit root, no unit root with this data at 5% level. (p=0.00)

*so this means that we should be OK with using our model



*M2: M1, now with controls
cap drop resid
cap drop lag_resid
xtreg immig_inflow_unau_pew zlaborscore ztaxscore zgovt_spend_score i.temp_pew zurban zPersonalFreedom zlinc_pers zheatdays south  if contus == 1, robust fe
predict resid, residuals 
generate lag_resid = resid[_n-1]  /*this is the EC terms, the fitted residuals of the lags */

reg d.immig_inflow_unau_pew d.l.immig_inflow_unau_pew ///
d.zlaborscore d.ztaxscore d.zgovt_spend_score ///
d.l.zlaborscore d.l.ztaxscore d.l.zgovt_spend_score ///
d.zurban d.zPersonalFreedom d.zlinc_pers d.zheatdays d.l.zurban d.l.zPersonalFreedom d.l.zlinc_pers d.l.zheatdays ///
lag_resid i.temp_pew if contus == 1, robust
estimates store M2

estout *, style(tex) cells(b(fmt(4)) se(fmt(4) par)) stats(r2 r2_a N) unstack 
estimates drop M1 M2 

******************************************************************************
*Table 2, immigration inflow, with the labor EF variables 

*M3:components of labor EF variables
cap drop resid
cap drop lag_resid
xtreg immig_inflow_unau_pew zminwage zfracgov zunion i.temp_pew if contus == 1, robust fe
predict resid, residuals 
generate lag_resid = resid[_n-1]  /*this is the EC terms, the fitted residuals of the lags */

reg d.immig_inflow_unau_pew d.l.immig_inflow_unau_pew ///
d.zminwage d.zfracgov d.zunion ///
d.l.zminwage d.l.zfracgov d.l.zunion ///
lag_resid i.temp_pew if contus == 1, robust
estimates store M3

*M4:  M3 now with Controls 
cap drop resid
cap drop lag_resid
xtreg immig_inflow_unau_pew zminwage zfracgov zunion i.temp_pew zurban zPersonalFreedom zlinc_pers zheatdays if contus == 1, robust fe
predict resid, residuals 
generate lag_resid = resid[_n-1]  /*this is the EC terms, the fitted residuals of the lags */

reg d.immig_inflow_unau_pew d.l.immig_inflow_unau_pew ///
d.zminwage d.zfracgov d.zunion ///
d.l.zminwage d.l.zfracgov d.l.zunion ///
d.zurban d.zPersonalFreedom d.zlinc_pers d.zheatdays d.l.zurban d.l.zPersonalFreedom d.l.zlinc_pers d.l.zheatdays ///
lag_resid i.temp_pew if contus == 1, robust
estimates store M4

estout *,  cells(b(fmt(4)) se(fmt(4) par)) stats(r2 r2_a N) unstack 
estimates drop M3 M4

******************************************************************************
*Table 3, immigration fraction, with the EF variables

*M1:EF variables
cap drop resid
cap drop lag_resid
xtreg immig_unau_pew zlaborscore ztaxscore zgovt_spend_score i.temp_pew if contus == 1, robust fe
predict resid, residuals 
generate lag_resid = resid[_n-1]  /*this is the EC terms, the fitted residuals of the lags */

reg d.immig_unau_pew ///
d.l.immig_unau_pew ///
d.zlaborscore d.ztaxscore d.zgovt_spend_score ///
d.l.zlaborscore d.l.ztaxscore d.l.zgovt_spend_score ///
lag_resid i.temp_pew if contus == 1, robust
estimates store M1

*M2: M1, now with controls
cap drop resid
cap drop lag_resid
xtreg immig_unau_pew zlaborscore ztaxscore zgovt_spend_score i.temp_pew zurban zPersonalFreedom zlinc_pers zheatdays if contus == 1, robust fe
predict resid, residuals 
generate lag_resid = resid[_n-1]  /*this is the EC terms, the fitted residuals of the lags */

reg d.immig_unau_pew d.l.immig_unau_pew ///
d.zlaborscore d.ztaxscore d.zgovt_spend_score ///
d.l.zlaborscore d.l.ztaxscore d.l.zgovt_spend_score ///
d.zurban d.zPersonalFreedom d.zlinc_pers d.zheatdays d.l.zurban d.l.zPersonalFreedom d.l.zlinc_pers d.l.zheatdays ///
lag_resid i.temp_pew if contus == 1, robust
estimates store M2

estout *, style(tex) cells(b(fmt(4)) se(fmt(4) par)) stats(r2 r2_a N) unstack 
estimates drop M1 M2 





















reg d.immig_inflow_unau_pew d.l.immig_inflow_unau_pew d.zef_temp d.l.zef_temp if contus == 1, robust
nlcom (_b[D.zef_temp] + _b[LD.zef_temp])/(1-_b[LD.immig_inflow_unau_pew])

tsset state_id temp_pew

xtwest zimmig_unau_pew zef_temp, lags(1) lrwindow(3) mg 



*Arellano-Bond
xtabond d.immig_inflow_unau_pew d.zef_temp, vce(robust) artests(1)


*GMM




********************************************************************************
*Table 2

reg d.zimmig_unau_pew d.l.zimmig_unau_pew d.zef_temp d.l.zef_temp i.temp_pew if contus == 1, robust

*Arellano-Bond
xtabond d.zimmig_unau_pew d.zef_temp, vce(robust) artests(0)

















