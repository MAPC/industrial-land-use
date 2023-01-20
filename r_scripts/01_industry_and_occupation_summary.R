# Worker Profiles in the MAPC region by Industry and Occupation
# Variables considered for cross-tabulation are
# Created By: Aseem Deodhar
# Created Date: 2021_05_27
# Edited by: Jessie Partridge Guerrero
# Edited date: 1/20/2023

# packages
library(tidyverse)
library(sf)

# Data Sources:

# Getting Occupation Codes Matching with Industry Codes as shared ----
occp_codes <- 
  read_csv("K:/DataServices/Datasets/U.S. Census and Demographics/PUMS/Raw/pums_2015_19/PUMS_Data_Dictionary_2015-2019.csv") %>% 
  filter(var == "INDP" | var == "OCCP") %>% 
  mutate(code = as.numeric(code),
         record_type = as.numeric(record_type)) %>% 
  # stripping to only first three characters of code_value
  mutate(code_val_code = str_sub(code_value, start = 1, end = 3)) %>% 
  filter(!is.na(code_val_code)) %>% 
  filter(code_val_code != 'N/A') %>% 
  mutate(indp_codes_study = case_when(var == "INDP" & 
                                        c(code == 770 | 
                                            (code >= 1070 & code <= 3390) | 
                                            (code >= 4070 & code <= 4590) | 
                                            (code >= 6070 & code <= 6390) | 
                                            (code >= 8770) | 
                                            (code >= 8660 & code <= 8690) |
                                            (code >= 4670 & code <= 5790)) ~ code_val_code)) %>% 
  
  # creating column with matching INDP codes in OCCP values
  mutate(occp_codes_study = case_when(var == "OCCP" & 
                                        code_val_code %in% (as_vector(.$indp_codes_study)) ~ code_val_code)) %>% 
  filter(!is.na(occp_codes_study)) %>% 
  select(record_type) %>% 
  as_vector()

ocp_codes_xtab <-
  read_csv("K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Data/soc_pumsoccu_crosstab_2019.csv") 
  
major_occp_eqvl <-
  ocp_codes_xtab %>% 
  
  mutate(
    #adjust width of acs occupation codes to 4 digits
    acs_code = as.character(acs_code),
    acs_code = str_pad(acs_code, width = 4, side = "left", pad = "0"),
    
    #extract 'major' level occupations from soc codes for value matching
    major_group = str_sub(soc_code, start = 1, end = 3),
    major_group = str_pad(major_group, width = 7, side = "right", pad = "0"),
    #extract 'minor' level occupations from soc codes for value matching
    minor_group = str_sub(soc_code, start = 1, end = 5),
    minor_group = str_pad(minor_group, width = 7, side = "right", pad = "0")) %>% 
  
  # Join major and minor OCS code descriptions to ACS codes
  left_join(
    .,
    read_csv("K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Data/soc_structure_2018.csv") %>% 
      select(major_group, descp) %>% 
      filter(!is.na(major_group)) %>% 
      rename(major_desc = descp),
    by = "major_group"
  ) %>% 
  left_join(
    .,
    read_csv("K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Data/soc_structure_2018.csv") %>% 
      select(minor_group, descp) %>% 
      filter(!is.na(minor_group)) %>% 
      rename(minor_desc = descp),
    by = "minor_group"
  ) %>% 
  
  # select and group acs_codes by major groups
  select(acs_code, major_group, major_desc)

# List of 2010 Census PUMAs corresponding to MAPC region: ----
mapc_pumas_list <- read_csv("K:/DataServices/Datasets/U.S. Census and Demographics/PUMS/r-code/Projections_PUMA_2010Geog.csv") %>% 
  filter(MAPC == 1) %>% 
  select(name_t) %>% 
  as_vector()

# Mapping out PUMAs to confirm: ----
ma_pumas_shp <- read_sf("K:/DataServices/Datasets/Boundaries/MA_2010_PUMAS.shp") 
ma_pumas_shp %>% 
  filter(PUMA %in% mapc_pumas_list) %>% 
  ggplot()+geom_sf()

# Household Level Record to get list of non-group household units:
ng_hh_srnos <- read_csv("//data-001/public/DataServices/Datasets/U.S. Census and Demographics/PUMS/Raw/pums_2015_19/csv_hma/psam_h25.csv",
                        col_types = cols(SERIALNO = col_character())) %>% 
  filter(TYPE == 1) %>%
  select(SERIALNO) %>%
  as_vector()

# Person Level Record
pums_person <- 
  read_csv("//data-001/public/DataServices/Datasets/U.S. Census and Demographics/PUMS/Raw/pums_2015_19/csv_pma/psam_p25.csv",
           col_types = cols(SERIALNO = col_character(),
                            WKWN = col_number()
           )) %>% 
  select(SERIALNO, # Household Number
         SPORDER,  # Person number in HH - '01' is assumed to be householder - the person filling out the form is numbered '01'
         ST,       # State code. Massachusetts is 25
         PUMA,     # PUMA Code
         ADJINC,   # Income Adjusting Factor to account for inflation: ADJINC/1000000
         PWGTP,    # Weight to be used to multiply values 
         AGEP,     # Person Age in years
         WAGP,     # Wage or Salary Income in past 12 months - to be adjusted with ADJINC
         PINCP,    # Person's TOTAL INCOME FROM ALL SOURCES in the past 12 months - to be adjusted with ADJINC
         INDP,     # Industry Code
         OCCP,     # Occupation Code
         RAC1P,    # Primary Race of person
         HISP,     # Hispanic/Latinx Flag
         SCHL,     # Level of Education
         ENG,      # Abilty to Speak English
         WKHP,     # Hours worked per week
         JWMNP,    # Travel time to work in minutes
  ) %>% 
  mutate(across(c(RAC1P, HISP, SCHL, ENG, SPORDER, WKHP, JWMNP), as.numeric)) %>% 
  
  # rename travel time to work variable
  rename(ttw_mins = JWMNP) %>% 
  # Acc to PUMS dictionary, an NA indicates wfh or non worker. We translate that to 0
  mutate(ttw_mins = replace_na(ttw_mins, 0)) %>% 
  
  filter(
    # filter to only MAPC equivalent PUMAs:
    PUMA %in% mapc_pumas_list,
    # filtering out group quarters
    SERIALNO %in% ng_hh_srnos,
    # filtering out persons below 18 years of age:
    AGEP >= 18,
    #remove non-workers
    #!is.na(WKHP)
  ) %>% 
  
  # Mutating Values to get counts:
  mutate(
    # Person's Race
    p_race = case_when(HISP >= 2 & HISP <= 24 ~ 'Hispanic',
                       RAC1P == 1 & HISP == 1 ~ 'White',
                       RAC1P == 2 & HISP == 1 ~ 'Black',
                       RAC1P == 6 & HISP == 1 | 
                         RAC1P == 7 & HISP == 1 ~ 'AAPI',
                       RAC1P == 3 & HISP == 1 | 
                         RAC1P == 4 & HISP == 1 | 
                         RAC1P == 5 & HISP == 1 | 
                         RAC1P == 8 & HISP == 1 | 
                         RAC1P == 9 & HISP == 1 ~ 'Other'),
    rac_hisp = case_when(HISP >= 2 & HISP <= 24 ~ 1),
    rac_whit = case_when(RAC1P == 1 & HISP == 1 ~ 1),
    rac_blck = case_when(RAC1P == 2 & HISP == 1 ~ 1),
    rac_aapi = case_when(RAC1P == 6 & HISP == 1 | 
                           RAC1P == 7 & HISP == 1 ~ 1),
    rac_othr = case_when(RAC1P == 3 & HISP == 1 | 
                           RAC1P == 4 & HISP == 1 | 
                           RAC1P == 5 & HISP == 1 | 
                           RAC1P == 8 & HISP == 1 | 
                           RAC1P == 9 & HISP == 1 ~ 1),
    rac_aapi = replace_na(rac_aapi, 0),
    rac_blck = replace_na(rac_blck, 0),
    rac_whit = replace_na(rac_whit, 0),
    rac_hisp = replace_na(rac_hisp, 0),
    rac_othr = replace_na(rac_othr, 0),
    
    # Person's Educational Attainment
    p_edu = case_when(SCHL <= 15 ~ 'Less than HS Degree',
                      SCHL == 16 | SCHL == 17 ~ 'HS Degree or GED',
                      SCHL == 18 | SCHL == 19 ~ 'Some College',
                      SCHL == 20 ~ 'Associates Degree',
                      SCHL == 21 ~ 'Bachelors Degree',
                      SCHL >= 22 ~ 'Masters or more'),
    edu_lhs = case_when(SCHL <= 15 ~ 1),
    edu_hsd = case_when(SCHL == 16 | SCHL == 17 ~ 1),
    edu_smc = case_when(SCHL == 18 | SCHL == 19 ~ 1),
    edu_asd = case_when(SCHL == 20 ~ 1),
    edu_bcd = case_when(SCHL == 21 ~ 1),
    edu_msd = case_when(SCHL >= 22 ~ 1),
    
    edu_lhs = replace_na(edu_lhs, 0),
    edu_hsd = replace_na(edu_hsd, 0),
    edu_smc = replace_na(edu_smc, 0),
    edu_asd = replace_na(edu_asd, 0),
    edu_bcd = replace_na(edu_bcd, 0),
    edu_msd = replace_na(edu_msd, 0),
    
    # English Proficiency
    p_eng = case_when(is.na(ENG) | ENG == 1 | ENG == 2 ~ 'Fluent',
                      ENG == 3 ~ 'Not Fluent',
                      ENG == 4 ~ 'No English'),
    eng_flu = case_when(ENG == 1 | ENG == 2 ~ 1),
    eng_nfl = case_when(ENG == 3 ~ 1),
    eng_non = case_when(ENG == 4 ~ 1),
    
    eng_flu = replace_na(eng_flu, 0),
    eng_nfl = replace_na(eng_nfl, 0),
    eng_non = replace_na(eng_non, 0),
    
    wrk_hrs = case_when(WKHP >= 35 ~ "Full Time",
                        WKHP < 35 ~ "Part Time"),
    wrk_ft = case_when(WKHP >= 35 ~ 1),
    wrk_pt = case_when(WKHP < 35 ~ 1),
    wrk_ft = replace_na(wrk_ft, 0),
    wrk_pt = replace_na(wrk_pt, 0),
    
    # WAGE ADJUsTMENT
    infadj_wage = (WAGP*ADJINC)/1000000) %>% 
  
  # Multiplying variables by weighting factor:
  mutate(across(c(rac_hisp, rac_whit, rac_blck, rac_aapi, rac_othr,
                  edu_lhs, edu_hsd, edu_smc, edu_asd, edu_bcd, edu_msd,
                  eng_flu, eng_nfl, eng_non,
                  wrk_ft, wrk_pt), function(x){x*PWGTP})) %>% 
  
  # Grouping by INDP codes
  # Reclassifying INDP codes into chunks:
  mutate(ind_grps = case_when(INDP == '0770' ~ 'Construction',
                              as.numeric(INDP) >= 1070 & as.numeric(INDP) <= 3990 ~ 'Manufacturing',
                              as.numeric(INDP) >= 4070 & as.numeric(INDP) <= 4590 ~ 'Wholesale Trade',
                              as.numeric(INDP) >= 6070 & as.numeric(INDP) <= 6390 ~ 'Transportation & Warehousing',
                              as.numeric(INDP) == 8770 ~ 'Repair',
                              as.numeric(INDP) >= 8660 & as.numeric(INDP) <= 8690 ~ 'Accomodation & Food Service',
                              as.numeric(INDP) >= 4670 & as.numeric(INDP) <= 5790 ~ 'Retail Trade'),
         ind_grps = replace_na(ind_grps,'Other Industries')) %>% 
  
  # join by major occupation groupings taken from SOC codes
  left_join(
    .,
    major_occp_eqvl %>% select(acs_code, major_desc),
    by = c("OCCP" = "acs_code")
  )


# Jessie 1/20/2023: Commenting out the remaining code because median calculations do not account for PUMS weights and are therefore inaccurate
# Jessie 1/20/2023: To run cross tabulations, run script "02_industriallanduse_workerdemographicsummaries.R"

# # Wage Level Cross Tabulations --------------------------------------------
# # Cross Tabulations of Industry and Educational Attainment Levels, Race, English Proficiency for Wage statistics ----
# 
# # Educational Attainment:
# xtab_edu_attain <-
#   pums_person %>% 
#   group_by(ind_grps, p_edu, wrk_hrs) %>% 
#   summarise(infadj_wage_avg = mean(infadj_wage),
#             infadj_wage_med = median(infadj_wage),
#             infadj_wage_25p = quantile(infadj_wage, c(0.25)),
#             infadj_wage_75p = quantile(infadj_wage, c(0.75)),
#             infadj_wage_95p = quantile(infadj_wage, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_edu_attain, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_edu_attain_ftpt.csv")
# 
# sum(xtab_edu_attain$count)
# 
# # Race:
# xtab_race <-
#   pums_person %>% 
#   group_by(ind_grps, p_race, wrk_hrs) %>% 
#   summarise(infadj_wage_avg = mean(infadj_wage),
#             infadj_wage_med = median(infadj_wage),
#             infadj_wage_25p = quantile(infadj_wage, c(0.25)),
#             infadj_wage_75p = quantile(infadj_wage, c(0.75)),
#             infadj_wage_95p = quantile(infadj_wage, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_race, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_race_ftpt.csv")
# 
# # English Proficency:
# xtab_english <-
#   pums_person %>% 
#   group_by(ind_grps, p_eng, wrk_hrs) %>% 
#   summarise(infadj_wage_avg = mean(infadj_wage),
#             infadj_wage_med = median(infadj_wage),
#             infadj_wage_25p = quantile(infadj_wage, c(0.25)),
#             infadj_wage_75p = quantile(infadj_wage, c(0.75)),
#             infadj_wage_95p = quantile(infadj_wage, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_english, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_english_ftpt.csv")
# 
# 
# # Cross Tabulations of Industry | Occupation Codes (Major Groups) and Educational Attainment Levels, Race, English Proficiency for Wage statistics ----
# 
# # Educational Attainment:
# xtab_edu_attain_occp <-
#   pums_person %>% 
#   group_by(ind_grps, major_desc, p_edu, wrk_hrs) %>% 
#   summarise(infadj_wage_avg = mean(infadj_wage),
#             infadj_wage_med = median(infadj_wage),
#             infadj_wage_25p = quantile(infadj_wage, c(0.25)),
#             infadj_wage_75p = quantile(infadj_wage, c(0.75)),
#             infadj_wage_95p = quantile(infadj_wage, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_edu_attain_occp, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_edu_attain_occp_ftpt.csv")
# 
# sum(xtab_edu_attain_occp$count)
# 
# # Race:
# xtab_race_occp <-
#   pums_person %>% 
#   group_by(ind_grps, major_desc, p_race, wrk_hrs) %>% 
#   summarise(infadj_wage_avg = mean(infadj_wage),
#             infadj_wage_med = median(infadj_wage),
#             infadj_wage_25p = quantile(infadj_wage, c(0.25)),
#             infadj_wage_75p = quantile(infadj_wage, c(0.75)),
#             infadj_wage_95p = quantile(infadj_wage, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_race_occp, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_race_occp_ftpt.csv")
# 
# # English Proficency:
# xtab_english_occp <-
#   pums_person %>% 
#   group_by(ind_grps, major_desc, p_eng, wrk_hrs) %>% 
#   summarise(infadj_wage_avg = mean(infadj_wage),
#             infadj_wage_med = median(infadj_wage),
#             infadj_wage_25p = quantile(infadj_wage, c(0.25)),
#             infadj_wage_75p = quantile(infadj_wage, c(0.75)),
#             infadj_wage_95p = quantile(infadj_wage, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_english_occp, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_english_occp_ftpt.csv")
# 
# 
# # Travel Time Cross Tabulations -------------------------------------------
# # Cross Tabulations of Industry and Educational Attainment Levels, Race, English Proficiency for Wage statistics ----
# 
# # Educational Attainment:
# xtab_edu_attain_ttw <-
#   pums_person %>% 
#   group_by(ind_grps, p_edu, wrk_hrs) %>% 
#   summarise(ttw_mins_avg = mean(ttw_mins),
#             ttw_mins_med = median(ttw_mins),
#             ttw_mins_25p = quantile(ttw_mins, c(0.25)),
#             ttw_mins_75p = quantile(ttw_mins, c(0.75)),
#             ttw_mins_95p = quantile(ttw_mins, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_edu_attain_ttw, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_edu_attain_ttw.csv")
# 
# 
# # Race:
# xtab_race_ttw <-
#   pums_person %>% 
#   group_by(ind_grps, p_race, wrk_hrs) %>% 
#   summarise(ttw_mins_avg = mean(ttw_mins),
#             ttw_mins_med = median(ttw_mins),
#             ttw_mins_25p = quantile(ttw_mins, c(0.25)),
#             ttw_mins_75p = quantile(ttw_mins, c(0.75)),
#             ttw_mins_95p = quantile(ttw_mins, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_race_ttw, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_race_ttw.csv")
# 
# # English Proficency:
# xtab_english_ttw <-
#   pums_person %>% 
#   group_by(ind_grps, p_eng, wrk_hrs) %>% 
#   summarise(ttw_mins_avg = mean(ttw_mins),
#             ttw_mins_med = median(ttw_mins),
#             ttw_mins_25p = quantile(ttw_mins, c(0.25)),
#             ttw_mins_75p = quantile(ttw_mins, c(0.75)),
#             ttw_mins_95p = quantile(ttw_mins, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_english_ttw, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_english_ttw.csv")
# 
# 
# # Cross Tabulations of Industry | Occupation Codes (Major Groups) and Educational Attainment Levels, Race, English Proficiency for Wage statistics ----
# 
# # Educational Attainment:
# xtab_edu_attain_occp_ttw <-
#   pums_person %>% 
#   group_by(ind_grps, major_desc, p_edu, wrk_hrs) %>% 
#   summarise(ttw_mins_avg = mean(ttw_mins),
#             ttw_mins_med = median(ttw_mins),
#             ttw_mins_25p = quantile(ttw_mins, c(0.25)),
#             ttw_mins_75p = quantile(ttw_mins, c(0.75)),
#             ttw_mins_95p = quantile(ttw_mins, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_edu_attain_occp_ttw, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_edu_attain_occp_ttw.csv")
# 
# 
# # Race:
# xtab_race_occp_ttw <-
#   pums_person %>% 
#   group_by(ind_grps, major_desc, p_race, wrk_hrs) %>% 
#   summarise(ttw_mins_avg = mean(ttw_mins),
#             ttw_mins_med = median(ttw_mins),
#             ttw_mins_25p = quantile(ttw_mins, c(0.25)),
#             ttw_mins_75p = quantile(ttw_mins, c(0.75)),
#             ttw_mins_95p = quantile(ttw_mins, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_race_occp_ttw, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_race_occp_ttw.csv")
# 
# # English Proficency:
# xtab_english_occp_ttw <-
#   pums_person %>% 
#   group_by(ind_grps, major_desc, p_eng, wrk_hrs) %>% 
#   summarise(ttw_mins_avg = mean(ttw_mins),
#             ttw_mins_med = median(ttw_mins),
#             ttw_mins_25p = quantile(ttw_mins, c(0.25)),
#             ttw_mins_75p = quantile(ttw_mins, c(0.75)),
#             ttw_mins_95p = quantile(ttw_mins, c(0.95)),
#             age_avg = mean(AGEP),
#             age_med = median(AGEP),
#             count = n())
# write_csv(xtab_english_occp_ttw, 
#           "K:/DataServices/Projects/Current_Projects/EconDev/Industrial_LandUse/Output/Data/xtab_english_occp_ttw.csv")
