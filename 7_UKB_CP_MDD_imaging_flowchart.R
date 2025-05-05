## Flowchart of UKB brain strucutre paper
library(Gmisc, quietly = TRUE) 
library(glue)
library(grid)
library(ggplot2)
library(dplyr)
library(ggh4x)

## Load in data ----
#work_dir <- ""
full_data <- read.csv(paste0(work_dir,"/resources/UKB_imaging_covariates_qc.csv"))
UKB_exclude <- read.csv(paste0(work_dir,"/resources/w4844_20241216.csv"), header = F)
UKB_imaging_outliers <- read.csv(paste0(work_dir,"/resources/imaging_outliers.csv"))
UKB_neurological <- read.csv(paste0(work_dir,"/resources/UKB_neurological.csv"))
UKB_CP <- read.csv(paste0(work_dir,"/../UKB_chronic_pain_phenotype/output/UKB_chronic_pain_phenotype_imaging.csv"))
UKB_MDD <- read.csv(paste0(work_dir,"/resources/UKB_current_depression_imaging.csv"))

## Remove excluded
full_data <- full_data[!full_data$f.eid %in% UKB_exclude$V1,]

## Get sample sizes for each group ----
## Total
n_UKB <- nrow(full_data)

## With imaging data
## Remove rows with majority missing data and no ICV - this indicates no available brain structures
majority_threshold <- ncol(full_data) / 2
imaging_data <- full_data %>%
  filter(rowSums(is.na(.)) < majority_threshold) %>%
  filter(!is.na(ICV))

n_imaging <- nrow(imaging_data)
n_no_imaging <- n_UKB - nrow(imaging_data)

## With neurological
neurological_IDs <- UKB_neurological$f_eid[UKB_neurological$neurological == 1]
imaging_non_neurological_data <- imaging_data[!imaging_data$f.eid %in% neurological_IDs,]
n_non_neurological_in_imaging <-  nrow(imaging_non_neurological_data)
n_neurological_in_imaging <- n_imaging - nrow(imaging_non_neurological_data)

## With imaging outliers
outlier_IDs <- UKB_imaging_outliers$outlier_ids
eligible_data <- imaging_non_neurological_data[!imaging_non_neurological_data$f.eid %in% outlier_IDs,]
n_eligible <-  nrow(eligible_data)
n_excluded <- n_UKB - n_eligible
n_outliers_non_neurological_in_imaging <- n_non_neurological_in_imaging - nrow(eligible_data)

## With chronic pain phenotyping
UKB_CP <- UKB_CP[UKB_CP$n_eid %in% eligible_data$f.eid,]
n_CP <- length(na.omit(UKB_CP$chronic_pain_sites))
CP_IDs <- UKB_CP$n_eid[!is.na(UKB_CP$chronic_pain_status)]
n_CP_missing_phenotype <- sum(!eligible_data$f.eid %in% CP_IDs) ## N without chronic pain phenotyping

## With depression phenotyping
n_MDD_missing_phenotype <- sum(eligible_data$f.eid %in% UKB_MDD$f.eid[(is.na(UKB_MDD$smith_depression) | is.na(UKB_MDD$current_depression))]) ## N without depression phenotyping
n_MDD_excluded <- n_MDD_missing_phenotype
UKB_MDD <- UKB_MDD[UKB_MDD$f.eid %in% eligible_data$f.eid,]
n_MDD <- length(na.omit(UKB_MDD$depression))
MDD_IDs <- UKB_MDD$f.eid[!is.na(UKB_MDD$depression)]


## With chronic pain and depression phenotyping
n_MDD_CP <- length(intersect(MDD_IDs, CP_IDs))

## Create flowchart ----
UKB_pop <- boxGrob(glue("UK Biobank Sample:",
                        "n = {pop}",
                        pop = txtInt(n_UKB),
                        .sep = "\n"), 
                   y = 0.9, x = 0.5, bjust = c(0.5, 0.5),
                   just = "centre")

eligible_pop <- boxGrob(glue("Eligible Sample:",
                             "n = {pop}",
                             pop = txtInt(n_eligible),
                             .sep = "\n"), 
                        y = 0.6, x = 0.5, bjust = c(0.5, 0.5),
                        just = "centre")

exclude_pop <- boxGrob(glue("Excluded (n = {tot}):",
                            " - No Imaging: {no_imaging}",
                            " - Neurological condition (in imaging sample): {neurologicial}",
                            " - Outliers (in non-neurological imaging sample): {imaging_outlier}",
                            tot = txtInt(n_excluded),
                            no_imaging = txtInt(n_no_imaging),
                            neurologicial = txtInt(n_neurological_in_imaging),
                            imaging_outlier = txtInt(n_outliers_non_neurological_in_imaging),
                            .sep = "\n"), 
                       y = 0.75, x = 0.75, bjust = c(0.5, 0.5),
                       just = "left")


CP_excluded_pop <- boxGrob(glue("Excluded (n = {tot})",
                                 "- Missing chronic pain phenotyping",
                                 tot = txtInt(n_CP_missing_phenotype),
                                 .sep = "\n"), 
                            y = 0.4, x = 0.15, bjust = c(0.5, 0.5),
                            just = "left")

CP_pop <- boxGrob(glue("Chronic Pain Phenotyping:",
                       "n = {pop}",
                       pop = txtInt(n_CP),
                       .sep = "\n"), 
                  y = 0.4, x = 0.4, bjust = c(0.5, 0.5),
                  just = "centre")


MDD_excluded_pop <- boxGrob(glue("Excluded (n = {tot})",
                                 "- Missing depression phenotyping",
                        tot = txtInt(n_MDD_excluded),
                        .sep = "\n"), 
                   y = 0.4, x = 0.87, bjust = c(0.5, 0.5),
                   just = "left")


MDD_pop <- boxGrob(glue("Depression Phenotyping:",
                       "n = {pop}",
                       pop = txtInt(n_MDD),
                       .sep = "\n"), 
                  y = 0.4, x = 0.6, bjust = c(0.5, 0.5),
                  just = "centre")

CPMDD_pop <- boxGrob(glue("Both Chronic Pain and Depression Phenotyping:",
                        "n = {pop}",
                        pop = txtInt(n_MDD_CP),
                        .sep = "\n"), 
                   y = 0.2, x = 0.5, bjust = c(0.5, 0.5),
                   just = "centre")

grid.newpage()
jpeg("~/Desktop/PhD/projects/UKB_CP_MDD_brain_structure/output/flowchart.jpg", width = 13000, height = 8000, res = 1000)


connectGrob(UKB_pop, eligible_pop, "N")
connectGrob(UKB_pop, exclude_pop, "L")
connectGrob(eligible_pop, MDD_pop, "N")
connectGrob(eligible_pop, CP_pop, "N")
connectGrob(MDD_pop, CPMDD_pop, "N")
connectGrob(MDD_pop, MDD_excluded_pop, "L")
connectGrob(CP_pop, CPMDD_pop, "N")
connectGrob(CP_pop, CP_excluded_pop, "L")

UKB_pop
eligible_pop
exclude_pop
CP_pop
MDD_excluded_pop
MDD_pop
CP_excluded_pop
CPMDD_pop


dev.off()

## Save IDs of eligible participants
write.csv(eligible_data$f.eid, "~/Desktop/PhD/projects/UKB_CP_MDD_brain_structure/resources/eligible.csv", quote = F, row.names = F)

