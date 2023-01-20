# Worker Demographic Summaries in the MAPC region by Industry and Occupation
# Created By: Jessie Partridge Guerrero
# Created Date: 2023_01_17

library(dplyr)

#Before starting this script, run R script "01_industry_and_occupation_summary.R" in 
#GitHub repo: https://github.com/MAPC/industrial-land-use
#Only run through line 233 (before summaries)

#Filtering to workers with more than zero hours worked per week
pums_wrkrs <- filter(pums_person, wrk_hrs=="Full Time"|wrk_hrs=="Part Time")

#Sumarizing median wages and total workers by sector, by full or part time, and by educational attainment
wrkrs <-
  pums_wrkrs %>% 
  group_by(ind_grps) %>% 
  summarise(tot = sum(PWGTP),
            count = n())

wrkrs_time <-
  pums_wrkrs %>% 
  group_by(ind_grps, wrk_hrs) %>% 
  summarise(tot = sum(PWGTP),
            count = n())

wrkrs_edu <-
  pums_wrkrs %>% 
  group_by(ind_grps, p_edu) %>% 
  summarise(tot = sum(PWGTP),
            count = n())

med_wages <-
  pums_wrkrs %>% 
  group_by(ind_grps) %>% 
  summarise(mdwg = median(rep(infadj_wage, PWGTP)),
            tot = sum(PWGTP),
            count = n())


#Filtering to workers with less than a college degree (filtering out Associates, Bachelors, and Masters)
pums_wrkrs_ltc <- filter(pums_wrkrs, p_edu != "Associates Degree" & p_edu != "Bachelors Degree" & p_edu != "Masters or more")

med_wages_ltc <-
  pums_wrkrs_ltc %>% 
  group_by(ind_grps) %>% 
  summarise(mdwg = median(rep(infadj_wage, PWGTP)),
            tot = sum(PWGTP),
            count = n())

write_csv(med_wages, 
          "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/med_wages.csv")

write_csv(med_wages_ltc, 
          "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/med_wages_ltc.csv")


#############testing median code####################

afs <- filter(pums_wrkrs, ind_grps=="Accomodation & Food Service")


median(rep(afs$infadj_wage,
           times = afs$PWGTP))

