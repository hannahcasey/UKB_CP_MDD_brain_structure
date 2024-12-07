## Flowchart of UKB brain strucutre paper
library(Gmisc, quietly = TRUE) 
library(glue)
library(grid)
library(ggplot2)
library(dplyr)
library(ggh4x)

## Load in data ----
full_data <- read.csv("/Volumes/GenScotDepression/users/hcasey/UKB_brain_structure_CP_MDD/UKB_imaging_covariates.csv")
non_british_irish <- read.csv("/Volumes/GenScotDepression/users/hcasey/UKB_brain_structure_CP_MDD/non_british_irish.csv")
UKB_neurological <- read.csv("/Users/hannahcasey/Desktop/PhD/projects/UKB_CP_MDD_brain_structure/resources/UKB_neurological.csv")
UKB_neurological <- subset(UKB_neurological, neurological == 1)
UKB_CP <- read.csv("/Users/hannahcasey/Desktop/PhD/projects/UKB_chronic_pain_phenotype/output/UKB_chronic_pain_phenotype_imaging.csv")
UKB_MDD <- read.csv("/Users/hannahcasey/Desktop/PhD/projects/UKB_depression_phenotype/output/UKB_depression_phenotype.csv")

## Sample flow chart ----
UKB_with_imaging <- full_data$f.eid[!is.na(full_data$ICV)] ## IDs with imaging - outliers removes on a case by case basis
UKB_british_irish_with_imaging <- UKB_with_imaging[!UKB_with_imaging %in% non_british_irish$x] ## IDs british/irish with imaging
UKB_british_irish_with_imaging_non_neurological <- UKB_british_irish_with_imaging[!UKB_british_irish_with_imaging %in% UKB_neurological$f_eid] ## IDs non neurological british/irish with imaging

UKB_non_british_irish_with_imaging <- UKB_with_imaging[UKB_with_imaging %in% non_british_irish$x] ## IDs non british/irish in imaging sample
UKB_neurological_british_irish_with_imaging <- UKB_british_irish_with_imaging[UKB_british_irish_with_imaging %in% UKB_neurological$f_eid] ## IDs neurological British/Irish in imaging sample

UKB_non_british_irish_with_imaging_non_neurological_CP <- UKB_CP$n_eid[(UKB_CP$n_eid %in% UKB_british_irish_with_imaging_non_neurological) & !is.na(UKB_CP$chronic_pain_status)] ## IDs british/irish in imaging sample with CP phenotyping
UKB_non_british_irish_with_imaging_non_neurological_MDD <- UKB_MDD$f_eid[(UKB_MDD$f_eid %in% UKB_british_irish_with_imaging_non_neurological) & !is.na(UKB_MDD$recurrent_depression)] ## IDs british/irish in imaging sample with MDD phenotyping
UKB_non_british_irish_with_imaging_non_neurological_CPMDD <- UKB_non_british_irish_with_imaging_non_neurological_MDD[UKB_non_british_irish_with_imaging_non_neurological_MDD %in% UKB_non_british_irish_with_imaging_non_neurological_CP]


UKB_pop <- boxGrob(glue("UK Biobank Sample",
                        "n = {pop}",
                        pop = txtInt(nrow(full_data)),
                        .sep = "\n"), 
                   y = 0.9, x = 0.5, bjust = c(0.5, 0.5),
                   just = "centre")

eligible_pop <- boxGrob(glue("British/Irish with Imaging and no Neurological Conditions",
                             "n = {pop}",
                             pop = txtInt(length(UKB_british_irish_with_imaging_non_neurological)),
                             .sep = "\n"), 
                        y = 0.6, x = 0.5, bjust = c(0.5, 0.5),
                        just = "centre")

exclude_pop <- boxGrob(glue("Excluded (n = {tot}):",
                            " - No Imaging: {no_imaging}",
                            " - Non-British/Irish (in no imaging sample): {non_british_irish}",
                            " - Neurological condition (in no imaging non British/Irish sample): {neurolocial}",
                            tot = txtInt(nrow(full_data) - length(UKB_british_irish_with_imaging_non_neurological)),
                            no_imaging = txtInt(nrow(full_data) - length(UKB_with_imaging)),
                            non_british_irish = txtInt(length(UKB_non_british_irish_with_imaging)),
                            neurolocial = txtInt(length(UKB_neurological_british_irish_with_imaging)),
                            .sep = "\n"), 
                       y = 0.75, x = 0.75, bjust = c(0.5, 0.5),
                       just = "left")

CP_pop <- boxGrob(glue("Chronic Pain Phenotyping",
                       "n = {pop}",
                       pop = txtInt(length(UKB_non_british_irish_with_imaging_non_neurological_CP)),
                       .sep = "\n"), 
                  y = 0.3, x = 0.3, bjust = c(0.5, 0.5),
                  just = "centre")

MDD_pop <- boxGrob(glue("Depression Phenotyping",
                       "n = {pop}",
                       pop = txtInt(length(UKB_non_british_irish_with_imaging_non_neurological_MDD)),
                       .sep = "\n"), 
                  y = 0.3, x = 0.7, bjust = c(0.5, 0.5),
                  just = "centre")

CPMDD_pop <- boxGrob(glue("Both Chronic Pain and Depression Phenotyping",
                        "n = {pop}",
                        pop = txtInt(length(UKB_non_british_irish_with_imaging_non_neurological_CPMDD)),
                        .sep = "\n"), 
                   y = 0.2, x = 0.5, bjust = c(0.5, 0.5),
                   just = "centre")

grid.newpage()
jpeg("~/Desktop/PhD/projects/UKB_CP_MDD_brain_structure/output/flowchart.jpg", width = 900, height = 900)

UKB_pop
eligible_pop
exclude_pop
CP_pop
MDD_pop
CPMDD_pop

connectGrob(UKB_pop, eligible_pop, "N")
connectGrob(UKB_pop, exclude_pop, "L")
connectGrob(eligible_pop, MDD_pop, "N")
connectGrob(eligible_pop, CP_pop, "N")
connectGrob(MDD_pop, CPMDD_pop, "N")
connectGrob(CP_pop, CPMDD_pop, "N")

dev.off()


