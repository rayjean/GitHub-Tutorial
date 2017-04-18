proc univariate data=nrd3;
var lobedate;
where year = 2014;
run;
data NRD3 (drop=j);
set nrd2;
thorasurg = 0;
LND = 0;
lobe = 0;
seg = 0;
pneum=0;
NOS =0;
array pr (*) PR1--PR15;
array datepr (*) PRDAY1--PRDAY15;
do j=1 to min(NPR, dim(pr));
if substr(pr(j),1,3) in ('402','403', '404') then do;
	LND=1;
	if ~missing(datepr(j)) then lnddate=datepr(j);
	end;
if substr(pr(j),1,3) in ('323') then seg=1;
if substr(pr(j),1,3) in ('324') then do; 
	lobe=1; if ~missing(datepr(j)) then lobedate=datepr(j);
	end;
	
if substr(pr(j),1,3) in ('325') then pneum=1;

if substr(pr(j),1,3) in ('325') then do;
	NOS=1;
	if ~missing(datepr(j)) then NOSdate=datepr(j);
	end;


if 31<=substr(pr(j),1,2)<=34 then thorasurg=1;
end;
where mlccs1 = '02';
run;
proc freq data=nrd3;
tables (lobe lobedate)*year/missing;
run;

proc sort data=nrd3 out=test2(keep=NRD_visitlink key_NRD NRD_DaystoEvent);
by NRD_VisitLink;
run;

data test4(keep = key: NRD_DaystoEvent Index_DaystoEvent same time );
merge test2 (in=A) NISALL.Readmit_master2014;
by NRD_VisitLink;
if A;
if key_NRD = key_index then same=1; else same=0; 
time = NRD_DaystoEvent - Index_DaystoEvent;
run;

proc freq data=test4;
tables same;
run;


proc freq data=nrd3 order=freq;
tables pr1 pr2 pr3;
where thorasurg;
run;

data want;
set work.nrd3.pr1 work.nrd3.pr2;
run;

data want (keep = key_NRD pr_:);
set nrd3;
array pr (*) pr1--pr15;
do i=1 to NPR;
	pr_f = pr(i);
	pr_2f = substr(pr(i),1,2);
	pr_3f = substr(pr(i),1,3);
	
	output want;
end;
run;

proc freq data=want order=freq;
tables pr_:;
where '31'<=pr_2f and pr_2f<='40';
run;

