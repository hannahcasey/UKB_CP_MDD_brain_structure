library(dplyr)

## Load in verbal interview
UKB_verbal_interview <- read_csv("/Volumes/GenScotDepression/users/hcasey/UKB_brain_structure_CP_MDD/UKB_verbal_interview.csv", header = T)

## get cancer and non-cancer codes f.20001 and f.20002

## Extract illness codes at time of imaging
UKB_illness_codes_non_cancer <- cbind(UKB_verbal_interview$f.eid,
                     UKB_verbal_interview[grepl("f.20002.2.", names(UKB_verbal_interview))])


UKB_illness_codes_cancer <- cbind(UKB_verbal_interview$f.eid,
                     UKB_verbal_interview[grepl("f.20001.2.", names(UKB_verbal_interview))])

## Get list with neurological condition at time of imaging

# Benign neuroma - 1683
# Brain abscess/intracranial abscess - 1245
# Brain haemorrhage - 1491
# Cerebral aneurysm - 1425
# Cerebral palsy - 1433
# Chronic/degenerative neurological problem - 1258
# dementia/alzheimers/cognitive impairment - 1263
# Encephalitis - 1246
# Epilepsy - 1264
# Fracture skull/head - 1626
# Head injury - 1266
# Ischaemic stroke - 1583
# Meningitis - 1247
# Motor Neurone Disease - 1259
# Multiple Sclerosis - 1261
# Nervous system infection - 1244
# Neurological injury/trauma - 1240
# Other demyelinating disease (not Multiple Sclerosis) - 1397
# Other neurological problem - 1434
# Parkinson’s Disease - 1262
# Spina Bifida - 1524
# Stroke - 1081
# Subarachnoid haemorrhage - 1086
# Subdural haemorrhage/haematoma - 1083
# Transient ischaemic attack - 1082
# Meningioma/benign meningeal tumour -1659

# Brain cancer/primary malignant brain tumour - 1032
# Meningeal cancer/malignant meningioma - 1031

UKB_neurological <- data_frame(f_eid = UKB_illness_codes_non_cancer$`UKB_verbal_interview$f.eid`)

## Make array of neurologival illness codes
UKB_neurological_codes_not_cancer <- c(1683, 1245, 1491, 1425, 1433, 1258, 1263, 1246, 1264, 1626, 1266, 1583, 1247, 1259, 1261, 1244, 1240, 1397, 1434, 1262, 1524, 1081, 1086, 1083, 1082, 1659)
UKB_neurological_codes_cancer <- c(1032, 1031)


UKB_neurological$neurological <- 0

UKB_neurological$neurological[apply(UKB_illness_codes_non_cancer, 1, function(r) any(r %in% UKB_neurological_codes_not_cancer))] <- 1
UKB_neurological$neurological[apply(UKB_illness_codes_cancer, 1, function(r) any(r %in% UKB_neurological_codes_cancer))] <- 1

## Save neurological status 
write.csv(UKB_neurological, "~/Desktop/PhD/projects/UKB_CP_MDD_brain_structure/resources/UKB_neurological.csv", quote = F, row.names = F)
