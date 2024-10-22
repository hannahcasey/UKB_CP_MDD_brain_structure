# UKB_CP_MDD_brain_structure
Analysis of brain structure in chronic pain and depression in UKB


## 1_UKB_CP_MDD_brain_structure_duckDB.R

UKB data used in analysis stored in duckDB database. This script connects to database, extracts and combine columns of interest into one dataframe and returns.

## 2_UKB_CP_MDD_brain_structure_neurological.R

Identify participants with neurological conditions, based on self-report, in UKB imaging sample (to be excluded).

## 3_UKB_CP_MDD_brain_structure_prep.Rmd

1. Calculate global and lobar measurements for imaging features
2. Replace field ID column names with descriptive names
3. Remove outliers (<5 SD from mean)
4. Scale brain structure measures and continuous covariates
5. Create long-formatted dataframe with for bilateral data

## 4_UKB_CP_MDD_brain_structure_assoc.Rmd

1. Combine chronic pain and depression phenotypes (see [UKB_chronic_pain_phenotype](https://github.com/hannahcasey/UKB_chronic_pain_phenotype) and [UKB_depression_phenotype](https://github.com/hannahcasey/UKB_depression_phenotype))
2. Get baseline characteristics for treatments groups
3. Carry out association analysis
       - Identify any hemisphere interactions
       - GLM: unilateral structures and separate bilateral structures (where hemisphere interaction is present)
       - LME: bilateral structures (where hemisphere interaction is not present)
       - Repeat in sex-stratified samples
4. Sensitivity analysis: association analysis with equal number of males and females

## 5_UKB_CP_MDD_DTI_plot.Rmd

1. Map standardized effect sizes to HEX colour codes
2. Instructions to produce DTI plots using [Mango: Multi-image Analysis GUI](https://mangoviewer.com)


## 6_UKB_CP_MDD_imaging_present.Rmd

Plot results of association analysis.

## 7_UKB_CP_MDD_imaging_flowchart.R

Create flowchart of sample sizes.

## 8_UKB_brain_structure_CP_MDD_supplementary.Rmd

Create supplementary material DOCX file.
