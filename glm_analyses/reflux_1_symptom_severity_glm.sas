*AUTHORS

Livia Guadagnoli & Lukas Van Oudenhove @LaBGAS, KU Leuven

https://gbiomed.kuleuven.be/english/research/50000625/50000628/labgas

January 2022;


*-------------------------------
Research question and hypotheses
--------------------------------
Research Questions: 
-What factors (psych questionnaire + physiological variables) are most associated with self-reported symptom severity?
-Is the association stronger for psychological variables compared to physiological? 
-Amongst psychological factors, are there differences in general vs. symptom specific?
-Do the factors most associated with symptom severity differ when evaluated individually by reflux cohort?

Hypotheses:
-Psychological variables are more strongly associated with self-reported symptom severity compared to physiological reflux values.
-We will see similar trends across reflux cohorts;

libname refl_bas "C:\Users\u0140676\OneDrive - KU Leuven\My files\proj-reflux-database\Data_files\SAS_Files\Final_Base_Datasets"; /* Liv's path */

*-----------------------------
Create dataset for question #1
------------------------------;
data refl_bas.reflux_question1;
set refl_bas.reflux_imp_final_pca_psy_clean;
run;

*--------------------
Distributions of DVs
---------------------;
proc univariate data=refl_bas.reflux_question1 freq plots;
var RQ_Acid_imp_IT RQ_Slaapstoornissen_imp_IT RQ_Total;
histogram / nmidpoints=50 kernel normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est) gamma (theta=est sigma=est alpha=est) exp (theta=est sigma=est) power (theta=est sigma=est alpha=est);
run;

*-----------------------------
Box-Cox transformations of DVs
------------------------------

*RQ_ACID

*add variable z with all zeros;
data refl_bas.reflux_question1;
set refl_bas.reflux_question1;
z=0;
run;

*use proc transreg to determine optimal lambda and transform
parameter = |minimum|, offset to get rid of negative or zero values
output statement writes dataset which contains transformed var with prefix BC_;
proc transreg data=refl_bas.reflux_question1 maxiter=0 nozeroconstant plots=all;
   	model BoxCox(RQ_Acid_imp_IT/parameter=1 tstandard=z) = identity(z);
	output out=work.bc_RQ_Acid tdp=BC_ ;
run;

*add the BC_ transformed variable to reflux dataset;
data refl_bas.reflux_question1;
merge work.bc_rq_acid refl_bas.reflux_question1;
drop _TYPE_ _NAME_ Intercept TIntercept Tz;
label BC_RQ_Acid_imp_IT = 'ReQuest (acid subscale) (Box-Cox transformed)';
run;

/*
alternative: perform Box-Cox transformation manually
lambda taken from proc transreg output
lambda = 0 in this case, special case indicating log transform is best;
data refl_bas.reflux_question1;
set refl_bas.reflux_question1;
BC_RQ_Acid_imp_IT = log(1 + RQ_Acid_imp_IT);
label BC_RQ_Acid_imp_IT = 'ReQuest (acid subscale) (Box-Cox transformed)';
run;
*/

*check distribution of raw and transformed variable;
proc univariate data=refl_bas.reflux_question1 freq plots;
var RQ_Acid_imp_IT BC_RQ_Acid_imp_IT;
histogram / nmidpoints=50 kernel normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est) gamma (theta=est sigma=est alpha=est) exp (theta=est sigma=est) power (theta=est sigma=est alpha=est);
run;
*NOTE: still not looking great due to excess zeros, but better;


*RQ_SLEEP

*use proc transreg to determine optimal lambda and transform
parameter = |minimum|, offset to get rid of negative or zero values
output statement writes dataset which contains transformed var with prefix BC_;
proc transreg data=refl_bas.reflux_question1 maxiter=0 nozeroconstant plots=all;
   	model BoxCox(RQ_Slaapstoornissen_imp_IT/parameter=1 tstandard=z) = identity(z);
	output out=work.bc_RQ_Sleep tdp=BC_ ;
run;

*add the BC_ transformed variable to reflux dataset;
data refl_bas.reflux_question1;
merge work.bc_rq_sleep refl_bas.reflux_question1;
drop _TYPE_ _NAME_ Intercept TIntercept Tz;
label BC_RQ_Slaapstoornissen_imp_IT = 'ReQuest (sleep subscale) (Box-Cox transformed)';
run;

/*
alternative: perform Box-Cox transformation manually
lambda taken from proc transreg output
lambda = 0 in this case, special case indicating log transform is best;
data refl_bas.reflux_question1;
set refl_bas.reflux_question1;
BC_RQ_Slaapstoornissen_imp_IT = log(1 + RQ_Slaapstoornissen_imp_IT);
label BC_RQ_Slaapstoornissen_imp_IT = 'ReQuest (sleep subscale) (Box-Cox transformed)';
run;
*/

*check distribution of raw and transformed variable;
proc univariate data=refl_bas.reflux_question1 freq plots;
var RQ_Slaapstoornissen_imp_IT BC_RQ_Slaapstoornissen_imp_IT;
histogram / nmidpoints=50 kernel normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est) gamma (theta=est sigma=est alpha=est) exp (theta=est sigma=est) power (theta=est sigma=est alpha=est);
run;
*NOTE: still not looking great due to excess zeros, but better;


*RQ_TOTAL

*use proc transreg to determine optimal lambda and transform
parameter = |minimum|, offset to get rid of negative or zero values
output statement writes dataset which contains transformed var with prefix BC_;
proc transreg data=refl_bas.reflux_question1 maxiter=0 nozeroconstant;
   	model BoxCox(RQ_Total/parameter=1 tstandard=z) = identity(z);
	output out=work.bc_RQ_Total tdp=BC_;
run;

*add the BC_ transformed variable to reflux dataset;
data refl_bas.reflux_question1;
merge work.bc_rq_total refl_bas.reflux_question1;
drop _TYPE_ _NAME_ Intercept TIntercept Tz;
label BC_RQ_Total = 'ReQuest (total score) (Box-Cox transformed)';
run;

/*
alternative: perform Box-Cox transformation manually
lambda taken from proc transreg output
lambda = 0.25 in this case
enter in box-cox formula;
data refl_bas.reflux_question1;
set refl_bas.reflux_question1;
BC_RQ_Total = ((1 + RQ_Total)**0.25 -1)/0.25;
label BC_RQ_Total = 'ReQuest (total score) (Box-Cox transformed)';
run;
*/

*check distribution of raw and transformed variable;
proc univariate data=refl_bas.reflux_question1 freq plots;
var RQ_Total BC_RQ_Total;
histogram / nmidpoints=50 kernel normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est) gamma (theta=est sigma=est alpha=est) exp (theta=est sigma=est) power (theta=est sigma=est alpha=est);
run;
*NOTE: not normal but definitely looking better;

*----------------------------
Reorder transformed variables
-----------------------------;

*print for easy copy-paste of all variable names;
proc print data=refl_bas.reflux_question1;
run;

*reorder;
data refl_bas.reflux_question1;
retain 

	subject

	classification

	age_imp

	gender_imp

	marital_status_imp

	education_imp

	occupation_imp

	weight_imp

	length_imp

	BMI_imp

	OESOFAGITIS

	pH_MII__ON_or_OFF_PPI

	pH_MII_ON_OFF_CODED

	total_gastric_acid_exp_imp

	total_eso_acid_exp_imp

	tot_vol_exp_imp

	total_nr_acid_imp

	up_gastr_acid_exp

	Noct_gastric_acid_exp

	Up_eso_acid_exp

	Noct_eso_acid_exp

	up_vol_exp

	noct_vol_exp

	up_nr_acid

	up_nr_nonacid

	up_total_nr

	noct_nr_acid

	noct_nr_nonacid

	noct_total_nr

	total_nr_nonacid

	TOTAL_nr

	nr_prox_reflux

	pH_imp_HB

	pH_imp_regurg

	pH_imp_cough

	pH_imp_other

	pH_imp_all

	pH_imp_atypical

	SI_HB_total_Recode

	SI_regurg_total_Recode

	SI_atypical_total_Recode

	SAP_HB_total_Recode

	SAP_regurg_total_Recode

	SAP_atypical_total_Recode

	SI_sum_total

	SAP_sum_total

	wellbeing_imp

	RQ_Acid_imp_IT

	BC_RQ_Acid_imp_IT

	RQ_Bovenbuik_imp_IT

	RQ_Misselijkheid_imp_IT

	RQ_Onderbuik_imp_IT

	RQ_Slaapstoornissen_imp_IT

	BC_RQ_Slaapstoornissen_imp_IT

	RQ_Andere_imp_IT

	RQ_Total

	BC_RQ_Total

	z;
set refl_bas.reflux_question1;
run;


*-------------------
Distributions of IVs
--------------------;
proc univariate data=refl_bas.reflux_question1 freq plots;
var CTQtot_imp_IT Factor1-Factor5 TOTAL_nr tot_vol_exp_imp;
histogram / nmidpoints=50 kernel normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est) gamma (theta=est sigma=est alpha=est) exp (theta=est sigma=est) power (theta=est sigma=est alpha=est);
run;
*NOTE: CTQ & eso vars definitely need transformation;

proc freq data=refl_bas.reflux_question1;
table classification pH_MII_ON_OFF_CODED;
run; 
*IMPORTANT NOTE: PPI intake has 36 missings - need to specify as informative missing;

*recode pH_MII_ON_OFF_CODED for this purpose;
data refl_bas.reflux_question1;
set refl_bas.reflux_question1;
if pH_MII_ON_OFF_CODED = . then pH_MII_ON_OFF_INF_MISS = 0;
else pH_MII_ON_OFF_INF_MISS = pH_MII_ON_OFF_CODED;
label pH_MII_ON_OFF_INF_MISS = 'PPI intake during pH-MII (informative missing)';
run;

*format this newly created variable;
proc format library=refl_bas.catalog;
	value ppi_mis
		-1='off'
		0='missing'
		1='on';
run;

data refl_bas.reflux_question1;
	set refl_bas.reflux_question1;
	format pH_MII_ON_OFF_INF_MISS ppi_mis.;
run;


*-----------------------------
Box-Cox transformations of IVs
------------------------------

*CTQ;

*use proc transreg to determine optimal lambda, transform and standardize
parameter = |minimum|, offset to get rid of negative or zero values
output statement writes dataset which contains transformed var with prefix BC_;
proc transreg data=refl_bas.reflux_question1 maxiter=0 nozeroconstant plots=all;
   	model BoxCox(CTQtot_imp_IT/parameter=0 tstandard=z) = identity(z);
	output out=work.bc_CTQ tdp=BC_;
run;

*add the BC_ transformed variable to reflux dataset;
data refl_bas.reflux_question1;
merge work.bc_ctq refl_bas.reflux_question1;
drop _TYPE_ _NAME_ Intercept TIntercept Tz;
label BC_CTQtot_imp_IT = 'CTQ (total score) (Box-Cox transformed)';
run;

/*
alternative: perform Box-Cox transformation manually
lambda taken from proc transreg output
lambda = -1.75 in this case
enter in box-cox formula;
data refl_bas.reflux_question1;
set refl_bas.reflux_question1;
BC_CTQtot_imp_IT = (CTQtot_imp_IT**-1.75 -1)/-1.75;
label BC_CTQtot_imp_IT = 'CTQ (total score) (Box-Cox transformed)';
run;

perform standardization manually;
proc standard data=refl_bas.reflux_question1  mean = 0 STD = 1 out=refl_bas.reflux_question1;
var BC_CTQtot_imp_IT;
run;
*/

proc univariate data=refl_bas.reflux_question1;
var BC_CTQtot_imp_IT CTQtot_imp_IT;
histogram / nmidpoints=50 kernel normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est) gamma (theta=est sigma=est alpha=est) exp (theta=est sigma=est) power (theta=est sigma=est alpha=est);
run;


*TOTAL NR REFLUX EPISODES;

*use proc transreg to determine optimal lambda, transform and standardize
parameter = |minimum|, offset to get rid of negative or zero values
output statement writes dataset which contains transformed var with prefix BC_;
proc transreg data=refl_bas.reflux_question1 maxiter=0 nozeroconstant plots=all;
   	model BoxCox(TOTAL_nr/parameter=1 tstandard=z) = identity(z);
	output out=work.bc_total_nr tdp=BC_;
run;

*add the BC_ transformed variable to reflux dataset;
data refl_bas.reflux_question1;
merge work.bc_total_nr refl_bas.reflux_question1;
drop _TYPE_ _NAME_ Intercept TIntercept Tz;
label BC_TOTAL_nr = 'total number of reflux events (Box-Cox transformed)';
run;

/*
alternative: perform Box-Cox transformation manually
lambda taken from proc transreg output
lambda = 0.25 in this case
enter in box-cox formula;
data refl_bas.reflux_question1;
set refl_bas.reflux_question1;
BC_TOTAL_nr = ((TOTAL_nr+1)**0.25 -1)/0.25;
label BC_TOTAL_nr = 'total number of reflux events (Box-Cox transformed)';
run;

*standardize manually;
proc standard data=refl_bas.reflux_question1  mean = 0 STD = 1 out=refl_bas.reflux_question1;
var BC_TOTAL_nr;
run;
*/

proc univariate data=refl_bas.reflux_question1;
var BC_TOTAL_nr TOTAL_nr;
histogram / nmidpoints=50 kernel normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est) gamma (theta=est sigma=est alpha=est) exp (theta=est sigma=est) power (theta=est sigma=est alpha=est);
run;
*NOTE: mucho mejor;


*TOTAL VOLUME EXPOSURE;

*use proc transreg to determine optimal lambda, transform and standardize
parameter = |minimum|, offset to get rid of negative or zero values
output statement writes dataset which contains transformed var with prefix BC_;
proc transreg data=refl_bas.reflux_question1 maxiter=0 nozeroconstant plots=all;
   	model BoxCox(tot_vol_exp_imp/parameter=1 tstandard=z) = identity(z);
	output out=work.bc_total_vol tdp=BC_;
run;

*add the BC_ transformed variable to reflux dataset;
data refl_bas.reflux_question1;
merge work.bc_total_vol refl_bas.reflux_question1;
drop _TYPE_ _NAME_ Intercept TIntercept Tz;
label BC_tot_vol_exp_imp = 'total volume exposure (Box-Cox transformed)';
run;


/*
alternative: perform Box-Cox transformation manually
lambda taken from proc transreg output
lambda = -0.75 in this case
enter in box-cox formula;
data refl_bas.reflux_question1;
set refl_bas.reflux_question1;
BC_tot_vol_exp_imp = ((tot_vol_exp_imp+1)**-0.75 -1)/-0.75;
label BC_tot_vol_exp_imp = 'total volume exposure (Box-Cox transformed)';
run;

*standardize;
proc standard data=refl_bas.reflux_question1  mean = 0 STD = 1 out=refl_bas.reflux_question1;
var BC_tot_vol_exp_imp;
run;
*/

proc univariate data=refl_bas.reflux_question1;
var BC_tot_vol_exp_imp tot_vol_exp_imp;
histogram / nmidpoints=50 kernel normal (mu=est sigma=est) lognormal (sigma=est theta=est zeta=est) gamma (theta=est sigma=est alpha=est) exp (theta=est sigma=est) power (theta=est sigma=est alpha=est);
run;


*----------------------------
Reorder transformed variables
-----------------------------;

*print for easy copy-paste of all variable names;
proc print data=refl_bas.reflux_question1;
run;

*reorder;
data refl_bas.reflux_question1;
retain 

	subject

	classification

	age_imp

	gender_imp

	marital_status_imp

	education_imp

	occupation_imp

	weight_imp

	length_imp

	BMI_imp

	OESOFAGITIS

	pH_MII__ON_or_OFF_PPI

	pH_MII_ON_OFF_CODED

	pH_MII_ON_OFF_INF_MISS

	total_gastric_acid_exp_imp

	total_eso_acid_exp_imp

	total_nr_acid_imp

	up_gastr_acid_exp

	Noct_gastric_acid_exp

	Up_eso_acid_exp

	Noct_eso_acid_exp

	up_vol_exp

	noct_vol_exp

	tot_vol_exp_imp

	BC_tot_vol_exp_imp

	up_nr_acid

	up_nr_nonacid

	up_total_nr

	noct_nr_acid

	noct_nr_nonacid

	noct_total_nr

	total_nr_nonacid

	nr_prox_reflux

	TOTAL_nr

	BC_TOTAL_nr

	pH_imp_HB

	pH_imp_regurg

	pH_imp_cough

	pH_imp_other

	pH_imp_all

	pH_imp_atypical

	SI_HB_total_Recode

	SI_regurg_total_Recode

	SI_atypical_total_Recode

	SAP_HB_total_Recode

	SAP_regurg_total_Recode

	SAP_atypical_total_Recode

	SI_sum_total

	SAP_sum_total

	wellbeing_imp

	RQ_Acid_imp_IT

	BC_RQ_Acid_imp_IT

	RQ_Bovenbuik_imp_IT

	RQ_Misselijkheid_imp_IT

	RQ_Onderbuik_imp_IT

	RQ_Slaapstoornissen_imp_IT

	BC_RQ_Slaapstoornissen_imp_IT

	RQ_Andere_imp_IT

	RQ_Total

	BC_RQ_Total

	CTQtot_imp_IT

	BC_CTQtot_imp_IT;
set refl_bas.reflux_question1;
drop z;
run;


*---------------------
Bivariate correlations
----------------------;
proc sgscatter data=refl_bas.reflux_question1;
plot BC_RQ_Total*(BC_CTQtot_imp_IT Factor1-Factor5 BC_tot_vol_exp_imp BC_TOTAL_nr) / jitter group=classification reg=(cli clm /*nogroup*/);
run;

proc sgscatter data=refl_bas.reflux_question1;
plot BC_RQ_Acid_imp_IT*(BC_CTQtot_imp_IT Factor1-Factor5 BC_tot_vol_exp_imp BC_TOTAL_nr) / jitter group=classification reg=(cli clm /*nogroup*/);
run;

proc sgscatter data=refl_bas.reflux_question1;
plot BC_RQ_Slaapstoornissen_imp_IT*(BC_CTQtot_imp_IT Factor1-Factor5 BC_tot_vol_exp_imp BC_TOTAL_nr) / jitter group=classification reg=(cli clm /*nogroup*/);
run;
*NOTE: obviously remaining degree of min-inflation except for total, otherwise looking decent;

proc corr data=refl_bas.reflux_question1 spearman plots(maxpoints=none)=matrix(histogram nvar=all nwith=all) plots=scatter(ellipse=prediction nvar=all nwith=all);
var BC_CTQtot_imp_IT Factor1-Factor5 BC_tot_vol_exp_imp BC_TOTAL_nr;
with BC_RQ_Total BC_RQ_Acid_imp_IT BC_RQ_Slaapstoornissen_imp_IT;
run;


*-------------------
General Linear Model
--------------------;

*TOTAL SCORE;

*proc glm;
proc glm data=refl_bas.reflux_question1 plots=all;
model BC_RQ_Total = BC_CTQtot_imp_IT / solution p tolerance clparm effectsize;
run;

proc glm data=refl_bas.reflux_question1 plots=all;
model BC_RQ_Total = BC_CTQtot_imp_IT Factor1-Factor5 / solution p tolerance clparm effectsize;
run;


proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Total = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm effectsize;
lsmeans classification / cl diff=all adjust=tukey stderr;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
output out=total_pred predicted=P_BC_RQ_Total residual=R_BC_RQ_Total;
run;

*plot predicted versus observed;
proc corr data=total_pred plots=all;
var BC_RQ_Total P_BC_RQ_Total;
run;


*check residuals;
proc univariate data=total_pred;
var R_BC_RQ_Total;
histogram R_BC_RQ_Total / normal;
run;

*glm by reflux subgroup;
proc sort data=refl_bas.reflux_question1;
by classification;
run;

proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Total = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp pH_MII_ON_OFF_INF_MISS classification BC_CTQtot_imp_IT*classification Factor1*classification Factor2*classification Factor3*classification Factor4*classification Factor5*classification BC_TOTAL_nr*classification BC_tot_vol_exp_imp*classification pH_MII_ON_OFF_INF_MISS*classification / solution p tolerance clparm effectsize;
lsmeans classification / cl diff=all adjust=tukey stderr;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
run;

proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
by classification;
model BC_RQ_Total = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm effectsize;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
run;

*interaction by PPI on/off;
proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Total = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp pH_MII_ON_OFF_INF_MISS classification BC_CTQtot_imp_IT*pH_MII_ON_OFF_INF_MISS Factor1*pH_MII_ON_OFF_INF_MISS Factor2*pH_MII_ON_OFF_INF_MISS Factor3*pH_MII_ON_OFF_INF_MISS Factor4*pH_MII_ON_OFF_INF_MISS Factor5*pH_MII_ON_OFF_INF_MISS BC_TOTAL_nr*pH_MII_ON_OFF_INF_MISS BC_tot_vol_exp_imp*pH_MII_ON_OFF_INF_MISS classification*pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm effectsize;
lsmeans classification / cl diff=all adjust=tukey stderr;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
run;

*ACID;

*proc glm;
proc glm data=refl_bas.reflux_question1 plots=all;
model BC_RQ_Acid_imp_IT = BC_CTQtot_imp_IT / solution p tolerance clparm effectsize;
run;

proc glm data=refl_bas.reflux_question1 plots=all;
model BC_RQ_Acid_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 / solution p tolerance clparm effectsize;
run;

*proc glm does not allow informative missing in class statement so use informative missing ppi var;
proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Acid_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm effectsize;
lsmeans classification / cl diff=all adjust=tukey stderr;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
output out=acid_pred predicted=P_BC_RQ_Acid_imp_IT residual=R_BC_RQ_Acid_imp_T;
run;

*plot predicted versus observed;
proc corr data=acid_pred plots=all;
var BC_RQ_Acid_imp_IT P_BC_RQ_Acid_imp_IT;
run;

*check residuals;
proc univariate data=acid_pred;
var R_BC_RQ_Acid_imp_T;
histogram R_BC_RQ_Acid_imp_T / normal;
run;

*proc genmod version of same model
please note that this allows informative missing in class statement;
proc genmod data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_CODED / missing;
model BC_RQ_Acid_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_CODED / cl diagnostics dist=normal r type1 type3 wald waldci;
lsmeans classification / cl diff=all adjust=tukey plots=all;
lsmeans pH_MII_ON_OFF_CODED / cl diff=all adjust=tukey plots=all;
run;
*identical results, as it should be;

*proc fmm
YouTube tutorial https://www.youtube.com/watch?v=dOwLZZVFYWg;
*hurdle model w/ truncated normal;
proc fmm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model RQ_Acid_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / cl dist=tnormal(0,.);
model + / dist=constant;
probmodel BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / cl;
run;

*zinb model;
proc fmm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model RQ_Acid_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / cl dist=negbin;
model + / dist=constant;
run;

*normal model;
proc fmm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Acid_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / cl dist=normal;
run;
*identical results to proc glm and genmod version of normal model
normal model fits best;

*glm by reflux subgroup;
proc sort data=refl_bas.reflux_question1;
by classification;
run;

proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Acid_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp pH_MII_ON_OFF_INF_MISS classification BC_CTQtot_imp_IT*classification Factor1*classification Factor2*classification Factor3*classification Factor4*classification Factor5*classification BC_TOTAL_nr*classification BC_tot_vol_exp_imp*classification pH_MII_ON_OFF_INF_MISS*classification / solution p tolerance clparm effectsize;
lsmeans classification / cl diff=all adjust=tukey stderr;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
estimate 'effect of Factor 5 in FH' Factor5 1 Factor5*classification 1;
estimate 'effect of Factor 5 in RHS' Factor5 1 Factor5*classification 0 1;
estimate 'effect of Factor 5 in Borderline GERD' Factor5 1 Factor5*classification 0 0 1;
estimate 'effect of Factor 5 in True GERD' Factor5 1 Factor5*classification 0 0 0 1;
run;

proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
by classification;
model BC_RQ_Acid_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm effectsize;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
run;

*interaction by PPI on/off;
proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Acid_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp pH_MII_ON_OFF_INF_MISS classification BC_CTQtot_imp_IT*pH_MII_ON_OFF_INF_MISS Factor1*pH_MII_ON_OFF_INF_MISS Factor2*pH_MII_ON_OFF_INF_MISS Factor3*pH_MII_ON_OFF_INF_MISS Factor4*pH_MII_ON_OFF_INF_MISS Factor5*pH_MII_ON_OFF_INF_MISS BC_TOTAL_nr*pH_MII_ON_OFF_INF_MISS BC_tot_vol_exp_imp*pH_MII_ON_OFF_INF_MISS classification*pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm effectsize;
lsmeans classification / cl diff=all adjust=tukey stderr;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
run;

*SLEEP;

*proc glm;
proc glm data=refl_bas.reflux_question1 plots=all;
model BC_RQ_Slaapstoornissen_imp_IT = BC_CTQtot_imp_IT / solution p tolerance clparm effectsize;
run;

proc glm data=refl_bas.reflux_question1 plots=all;
model BC_RQ_Slaapstoornissen_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 / solution p tolerance clparm effectsize;
run;

proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Slaapstoornissen_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm effectsize;
lsmeans classification / cl diff=all adjust=tukey stderr;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
output out=sleep_pred predicted=P_BC_RQ_Slaapstoornissen_imp_IT residual=R_BC_RQ_Slaapstoornissen_imp_IT;
run;

*plot predicted versus observed;
proc corr data=sleep_pred plots=all;
var BC_RQ_Slaapstoornissen_imp_IT P_BC_RQ_Slaapstoornissen_imp_IT;
run;

*check residuals;
proc univariate data=sleep_pred;
var R_BC_RQ_Slaapstoornissen_imp_IT;
histogram R_BC_RQ_Slaapstoornissen_imp_IT / normal;
run;

*proc fmm
*hurdle model w/ truncated normal;
proc fmm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model RQ_Slaapstoornissen_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / cl dist=tnormal(0,.);
model + / dist=constant;
probmodel BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / cl;
run;

*zinb model;
proc fmm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model RQ_Slaapstoornissen_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / cl dist=negbin;
model + / dist=constant;
run;

*normal model;
proc fmm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Slaapstoornissen_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp classification pH_MII_ON_OFF_INF_MISS / cl dist=normal;
run;
*identical results to proc glm version of normal model
normal model fits best;

*glm by reflux subgroup;
proc sort data=refl_bas.reflux_question1;
by classification;
run;

proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Slaapstoornissen_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp pH_MII_ON_OFF_INF_MISS classification BC_CTQtot_imp_IT*classification Factor1*classification Factor2*classification Factor3*classification Factor4*classification Factor5*classification BC_TOTAL_nr*classification BC_tot_vol_exp_imp*classification pH_MII_ON_OFF_INF_MISS*classification / solution p tolerance clparm effectsize;
lsmeans classification / cl diff=all adjust=tukey stderr;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
estimate 'effect of Factor 5 in FH' Factor5 1 Factor5*classification 1;
estimate 'effect of Factor 5 in RHS' Factor5 1 Factor5*classification 0 1;
estimate 'effect of Factor 5 in Borderline GERD' Factor5 1 Factor5*classification 0 0 1;
estimate 'effect of Factor 5 in True GERD' Factor5 1 Factor5*classification 0 0 0 1;
run;

proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
by classification;
model BC_RQ_Slaapstoornissen_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm effectsize;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
run;

*interaction by PPI on/off;
proc glm data=refl_bas.reflux_question1 plots=all order=internal;
class classification pH_MII_ON_OFF_INF_MISS;
model BC_RQ_Slaapstoornissen_imp_IT = BC_CTQtot_imp_IT Factor1-Factor5 BC_TOTAL_nr BC_tot_vol_exp_imp pH_MII_ON_OFF_INF_MISS classification BC_CTQtot_imp_IT*pH_MII_ON_OFF_INF_MISS Factor1*pH_MII_ON_OFF_INF_MISS Factor2*pH_MII_ON_OFF_INF_MISS Factor3*pH_MII_ON_OFF_INF_MISS Factor4*pH_MII_ON_OFF_INF_MISS Factor5*pH_MII_ON_OFF_INF_MISS BC_TOTAL_nr*pH_MII_ON_OFF_INF_MISS BC_tot_vol_exp_imp*pH_MII_ON_OFF_INF_MISS classification*pH_MII_ON_OFF_INF_MISS / solution p tolerance clparm effectsize;
lsmeans classification / cl diff=all adjust=tukey stderr;
lsmeans pH_MII_ON_OFF_INF_MISS / cl diff=all adjust=tukey stderr;
run;

*-----------------
Mediation Analyses
------------------;

*Note: we are using process v213 for the mediation analyses.


*Mediation Analyses for ReQuest Total with Factor 2, Factor 4 and Factor 5 in parallel; 
%process (data=refl_bas.reflux_question1,vars= BC_RQ_Total BC_CTQtot_imp_IT Factor1 Factor2 Factor3 Factor4 Factor5,model=4,y=BC_RQ_Total,m=Factor2 Factor4 Factor5,x=BC_CTQtot_imp_IT,w=,z=,v=,q=,conf=95,
  hc3=0,cluster=,wmodval=999,zmodval=999,vmodval=999,qmodval=999,mmodval=999,
  xmodval=999,boot=1000,center=0,quantile=0,effsize=0,normal=0,varorder=2,total=0,
  plot=0,detail=1,iterate=10000,converge=0.00000001,percent=0,jn=0,coeffci=1,
  covmy=0,contrast=0,seed=0,save=xxx,mc=0,decimals=10.4,covcoeff=0,olsdichy=0,olsdichm=0,ws=0);

*Mediation Analyses for ReQuest Acid with Factor 2 and Factor 5 in parallel; 
%process (data=refl_bas.reflux_question1,vars= BC_RQ_Acid_imp_IT BC_CTQtot_imp_IT Factor1 Factor2 Factor3 Factor4 Factor5,model=4,y=BC_RQ_Acid_imp_IT,m=Factor2 Factor5,x=BC_CTQtot_imp_IT,w=,z=,v=,q=,conf=95,
  hc3=0,cluster=,wmodval=999,zmodval=999,vmodval=999,qmodval=999,mmodval=999,
  xmodval=999,boot=1000,center=0,quantile=0,effsize=0,normal=0,varorder=2,total=0,
  plot=0,detail=1,iterate=10000,converge=0.00000001,percent=0,jn=0,coeffci=1,
  covmy=0,contrast=0,seed=0,save=xxx,mc=0,decimals=10.4,covcoeff=0,olsdichy=0,olsdichm=0,ws=0);
  
 *Mediation Analyses for ReQuest Sleep with Factor 2 and Factor 3 in parallel
 *Note: CTQ is not significantly associated with RQ_Sleep in Step 1 of glm so no mediation, but keeping code to have;
%process (data=refl_bas.reflux_question1,vars= BC_RQ_Slaapstoornissen_imp_IT BC_CTQtot_imp_IT Factor1 Factor2 Factor3 Factor4 Factor5,model=4,y=BC_RQ_Slaapstoornissen_imp_IT,m=Factor2 Factor3,x=BC_CTQtot_imp_IT,w=,z=,v=,q=,conf=95,
  hc3=0,cluster=,wmodval=999,zmodval=999,vmodval=999,qmodval=999,mmodval=999,
  xmodval=999,boot=1000,center=0,quantile=0,effsize=0,normal=0,varorder=2,total=0,
  plot=0,detail=1,iterate=10000,converge=0.00000001,percent=0,jn=0,coeffci=1,
  covmy=0,contrast=0,seed=0,save=xxx,mc=0,decimals=10.4,covcoeff=0,olsdichy=0,olsdichm=0,ws=0);


*-----------------------
Question 1 Descriptives
------------------------;

*Differences between classifications:
*Differences in PPI use between classifications;
proc freq data = refl_bas.reflux_question1;
Tables classification*pH_MII_ON_OFF_CODED
/Chisq expected deviation norow nocol nopercent;
run;

*Differences in gender between classifications;
proc freq data = refl_bas.reflux_question1;
Tables classification*gender_imp
/Chisq expected deviation norow nocol nopercent;
run;

*Differences in age, BMI between classifications;
proc glm data=refl_bas.reflux_question1;
class classification;
model age_imp bmi_imp = classification / solution p tolerance clparm;
manova h=_all_ / summary;
lsmeans classification / diff=all adjust=tukey;
run;



*Mediation Analyses for ReQuest Total with Factor 2, Factor 4 and Factor 5 in parallel; 
%process (data=refl_bas.reflux_question1,vars= BC_RQ_Total BC_CTQtot_imp_IT Factor1 Factor2 Factor3 Factor4 Factor5,model=4,y=Factor2,m=BC_RQ_Total,x=BC_CTQtot_imp_IT,w=,z=,v=,q=,conf=95,
  hc3=0,cluster=,wmodval=999,zmodval=999,vmodval=999,qmodval=999,mmodval=999,
  xmodval=999,boot=1000,center=0,quantile=0,effsize=0,normal=0,varorder=2,total=0,
  plot=0,detail=1,iterate=10000,converge=0.00000001,percent=0,jn=0,coeffci=1,
  covmy=0,contrast=0,seed=0,save=xxx,mc=0,decimals=10.4,covcoeff=0,olsdichy=0,olsdichm=0,ws=0);
