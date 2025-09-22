## Set path for r library
.libPaths("/exports/igmm/eddie/GenScotDepression/users/hcasey/r_library")

local({r <- getOption("repos")
r["CRAN"] <- "https://cran.r-project.org" 
options(repos=r)
})

#remotes::install_version('duckdb', '0.7.1-1')
library(duckdb)
library(dplyr)
#install.packages("dbplyr")
library(dbplyr)
library(rebus)


## Connect to database
con <- DBI::dbConnect(duckdb::duckdb(),
                      dbdir="/exports/igmm/eddie/GenScotDepression/data/ukb/phenotypes/fields/2023-12-olink-ukb676482/ukb670429.duckdb",
                      read_only=TRUE)
## List tables
DBI::dbListTables(con)

## Get baseline characteristics
BaselineCharacteristics <- tbl(con, 'BaselineCharacteristics')

## Extract sex (31) information
UKB_sex <- BaselineCharacteristics %>%
  select(f.eid, f.31.0.0)

## Get baseline characteristics
Touchscreen <- tbl(con, 'Touchscreen')

## Extract Ethnic background (21000) information
Touchscreen_ethnicity <- Touchscreen %>%
  select(f.eid, f.21000.0.0) 
  
## Get recruitment - age and imaging site
Recruitment <- tbl(con, 'Recruitment')

## Extract age (21003) and imaging site (54) information
UKB_age_site <- Recruitment %>%
  select(f.eid, f.21003.2.0, f.54.2.0)

## Load in physical measures data - BMI
PhysicalMeasures <- tbl(con, 'PhysicalMeasures')

## Extract BMI (21001) information
UKB_BMI <- PhysicalMeasures %>%
  select(f.eid, f.21001.2.0)

## Get imaging dataset
Imaging <- tbl(con, 'Imaging')

Imaging_ICV <- Imaging %>%
  select(f.eid, f.25008.2.0, f.25006.2.0, f.25004.2.0) %>%
  mutate(ICV = f.25008.2.0 + f.25006.2.0 + f.25004.2.0)

Imaging_coords <- Imaging %>%
  select(f.eid, f.25756.2.0, f.25757.2.0, f.25758.2.0)

## Create regular expression matching number ranges identifying field IDs containing regional cortical volumes, regional FA measures, regional MD measures and subcortical volumes
rx_cort <- number_range(26721, 26922)
rx_FA <- number_range(25488, 25514)
rx_MD <- number_range(25515, 25541)
rx_subcort <- number_range(25011, 25024)

## Retail only ID imaging data for analysis
UKB_imaging_small <- Imaging %>%
  select(c(1,
           which(grepl(rx_cort, names(Imaging))),
           which(grepl(rx_FA, names(Imaging))),
           which(grepl(rx_MD, names(Imaging))),
           which(grepl(rx_subcort, names(Imaging)))))


## Combine dataframes
UKB_imaging_covariates <- left_join(UKB_sex, UKB_age_site, by = "f.eid")
UKB_imaging_covariates <- left_join(UKB_imaging_covariates, Touchscreen_ethnicity, by = "f.eid")
UKB_imaging_covariates <- left_join(UKB_imaging_covariates, UKB_BMI, by = "f.eid")
UKB_imaging_covariates <- left_join(UKB_imaging_covariates, Imaging_ICV, by = "f.eid")
UKB_imaging_covariates <- left_join(UKB_imaging_covariates, Imaging_coords, by = "f.eid")
UKB_imaging_covariates <- left_join(UKB_imaging_covariates, UKB_imaging_small, by = "f.eid")



## Rename columns, add age^2
UKB_imaging_covariates <- UKB_imaging_covariates %>%
  rename(sex = f.31.0.0,
         age = f.21003.2.0,
         ethnicity = f.21000.0.0,
         assessment_centre_first_imaging = f.54.2.0,
         X_position = f.25756.2.0,
         Y_position = f.25757.2.0,
         Z_position = f.25758.2.0,
         BMI = f.21001.2.0) %>%
  mutate(age_squared = age^2)
  
## Get VerbalInterview - needed to determine neurological disorder status
VerbalInterview <- tbl(con, 'VerbalInterview') 

## Import to R environment
UKB_imaging_covariates <- UKB_imaging_covariates |> collect()
UKB_verbal_interview <- VerbalInterview |> collect()



## Save df
write.csv(UKB_imaging_covariates, "/exports/igmm/eddie/GenScotDepression/users/hcasey/UKB_imaging_covariates.csv")
write.csv(UKB_verbal_interview, "/exports/igmm/eddie/GenScotDepression/users/hcasey/UKB_verbal_interview.csv")

