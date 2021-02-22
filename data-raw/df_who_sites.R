## code to prepare `df_who_sites` dataset goes here
#use_data_raw('df_who_sites') #to create this script

address <- "https://www.who.int/malaria/areas/surveillance/who-cds-gmp-2019-01-eng.xlsx"

#mode='wb' needed to force binary transfer on windows apparently
download_failed <- tryCatch( utils::download.file(file.path(address), tempfilesites <- tempfile(), mode = "wb"),
                             error = function(e) {
                               message(paste('download failed'))
                               return(TRUE)
                             })

#return from this function if download error was caught by tryCatch
if (download_failed) return()


df_who_sites <- readxl::read_excel(tempfilesites)


# identify rows with no coords
indices_na_coords <- which(is.na(df_who_sites$Long) | is.na(df_who_sites$Lat))
#length(indices_na_coords)
#[1] 2350 #records that have no coords

#I used to remove rows with no coords here
#df_who_sites <- df_who_sites[-indices_na_coords,]

#move WHO Zanzibar data into Tanzania (consistent with healthsites that has it in Tanzania)
#TODO BUT think about this, Maina(2019) paper says Zanzibar data kept separate because has it's own MoH
#if do keep it separate will need to put healthsites data into Zanzibar and add Zanazibar as a country to the UI
df_who_sites$Country[df_who_sites$Country=='Zanzibar'] <- 'Tanzania'

# add iso3c helps with country ids later
df_who_sites$iso3c <- country2iso(df_who_sites$Country)

# conversion to sf now happens elsewhere in afrihealthsites.r
#sf_who_sites <- sf::st_as_sf(df_who_sites, coords = c("Long", "Lat"), crs = 4326)

#nrow(df_who_sites)
#[1] 96395

#countries_who <- unique(df_who_sites$Country)

# add a column with broad 9 category type consistent across countries
#df_who_sites <- afrihealthsites::afrihealthsites('all', datasource = 'who', plot=FALSE)
df_who_sites$facility_type_9 <- who_type_lookup$facility_type_9[ match(df_who_sites$`Facility type`,who_type_lookup$type_who) ]

# > unique(df_who_sites$`Facility type`)
# [1] "Hospital"                                     "Municipal Hospital"
# [3] "Provincial Hospital"                          "Centro de Saúde"
# [5] "Posto de Saúde"                               "Centro Materno Infantil"
# [7] "Central Hospital"                             "Centro Sanatorio Materno Infantil"
# [9] "Regional Hospital"                            "General Hospital"
# [11] "Health Centre"                                "Community Health Centre"
# [13] "Hôpital de Zone"                              "Centre de Santé d’Arrondissement"
# [15] "Dispensaire"                                  "Centre de Santé de Sous-Prefecture"
# [17] "Centre Médical"                               "Unites de Santé de Village"
# [19] "Centre Hospitalier Départemental"             "Centro de Santé de Circonscription Urbaine"
# [21] "Hôpital"                                      "Clinic"
# [23] "Unites de Santé de village"                   "Centre de Santé Central"
# [25] "Centre National Hospitalier Universitaire"    "Centre Médico-social"
# [27] "Primary Hospital"                             "Health Post"
# [29] "District Hospital"                            "Referral Hospital"
# [31] "Centre de Santé et de Promotion Sociale"      "Centre Médical Avec Antenne Chirurgicale"
# [33] "Centre Hospitalier Régional"                  "Centre Hospitalier National"
# [35] "Centre Hospitalier Universitaire National"    "Hôpital de District"
# [37] "Hôpital Tertiaire"                            "Centre de Santé Intégré"
# [39] "Centre Medical d’Arrondissement"              "Hôpital Régional"
# [41] "Hôpital Centraux"                             "Hôpital Général"
# [43] "Postos Sanitários"                            "Hospitais Regionais"
# [45] "Hospitais Centrais"                           "Centre de Santé \"C\""
# [47] "Centre de Santé \"E\""                        "Centre de Santé \"B\""
# [49] "Centre de Santé \"A\""                        "Poste de santé"
# [51] "Centre de Sante"                              "Hôpital Régional Universitaire"
# [53] "Hôpital Préfectoraux"                         "Centre de Santé \"D\""
# [55] "Hôpital de Regional"                          "Hôpital de Nationaux"
# [57] "Regional hospital"                            "Poste de Santé"
# [59] "Centre Médico-Chirurgical"                    "Centre Médico-Urbain"
# [61] "Hôpital Comboutique"                          "l’Hôpital de Base"
# [63] "University Hospital"                          "Centre de Santé Rural"
# [65] "Centre de Santé Urbain"                       "Hospitalier Universitaire"
# [67] "Hospitalier Régional"                         "Centre de Santé"
# [69] "Hôpital Général de Référence"                 "Centre Hôpital"
# [71] "Centre de Santé de Référence"                 "Polyclinique"
# [73] "Clinique"                                     "Centre de Santé Municipal"
# [75] "Centre Medico-Chirurgical"                    "Poste De Santé"
# [77] "Hospital Medical Center"                      "Hospital Medical Centre"
# [79] "Tertiary Hospital"                            "Health Station"
# [81] "Mini Hospital"                                "Mini Clinic"
# [83] "National Referral Hospital"                   "Clinic without Maternity"
# [85] "Public Health Unit"                           "Mission Hospital"
# [87] "Clinic with Maternity"                        "Nucleas Health Centre"
# [89] "National Hospital"                            "Zonal Hospital"
# [91] "Health post"                                  "Medical Centre"
# [93] "Centre Hospitalier Urbain"                    "Hôpital Coopération"
# [95] "Health Centre (minor)"                        "Health Centre (major)"
# [97] "Teaching Hospital"                            "General Hospital Hospital"
# [99] "Community-based Health Planning and Services" "Polyclinic"
# [101] "Hôpital Prefectoral"                          "Dispensary"
# [103] "Sub-District Hospital"                        "County Referral Hospital"
# [105] "Provincial General Hospital"                  "Filter Clinic"
# [107] "National Referral Centre"                     "Community Hospital"
# [109] "Health Post/Dispensary"                       "Rural Hospital"
# [111] "Referral Health Centre"                       "Area Health Centre"
# [113] "Family Health Clinic"                         "Medi-Clinic"
# [115] "Centro de Saúde Rural I"                      "Centro de Saúde Rural II"
# [117] "Centro de Saúde Urbano C"                     "Hospital Rural"
# [119] "Centro de Saúde Urbano B"                     "Hospital Provincial"
# [121] "Hospital Distrital"                           "Centro de Saúde Urbano A"
# [123] "Hospital Geral"                               "Hospital Central"
# [125] "Intermediate Hospital"                        "Integrated Health Centre"
# [127] "Health Hut"                                   "Centre Hospitalier Universitaire"
# [129] "Primary Health Centre"                        "Model Health Centre"
# [131] "Basic Health Centre"                          "Comprehensive Health Centre"
# [133] "Federal Medical Centre"                       "Cottage Hospital"
# [135] "University Teaching Hospital"                 "Model Primary Health Centre"
# [137] "Natonal Hospital"                             "State Hospital"
# [139] "DISPENSARY"                                   "Secondary Health Post"
# [141] "Hospitais"                                    "Postos de Saúde Comunitária"
# [143] "Community Health Post"                        "Maternal & Child Health Post"
# [145] "Refferal Hospital"                            "Maternal & Child Health Centre"
# [147] "Satellite Clinic"                             "Provincial Tertiary Hospital"
# [149] "National Central Hospital"                    "Community Health Centre/Clinic"
# [151] "Community Health Centre (After hours)"        "Primary Health Care Unit"
# [153] "Primary Health Care Centre"                   "County Hospital"
# [155] "Type D Hospital"                              "Type C Hospital"
# [157] "Type B Hospital"                              "Type A Hospital"
# [159] "Designated District Hospital"                 "Regional Referral Hospital"
# [161] "Unité de Soins Périphérique"                  "Centre Hospitalier Préfectoral"
# [163] "Health Centre III"                            "Health Centre II"
# [165] "Health Centre IV"                             "Level 1 Hospital"
# [167] "Level 2 Hospital"                             "Rural Health Centre"
# [169] "Level 3 Hospital"                             "Primary Health Care Unit +"
# [171] "Rural Health Clinic"                          "District/Provincial Hospital"

# add columns with 4 tier classication from Falchetta 2020
# see also afrimapr_dev/falchetta2021-explore.Rmd
# to explore data from https://www.pnas.org/content/117/50/31760
# Falchetta2021 Planning universal accessibility to public health care in sub-Saharan Africa
# data & analyses downloaded from https://zenodo.org/record/3757084#.YDD3euj7SUk


datafolder <- 'C:\\Dropbox\\_afrimapr\\health-facilities-africa\\falchetta2020-code\\'

# from data_preparation_and_figures.R
# Import classified version
parser_healthcare_types <- readxl::read_excel(paste0(datafolder, "parser_healthcare_types.xlsx")) %>% dplyr::select(-...1)

# names(parser_healthcare_types)
# [1] "ft"      "Country" "Tier"
# 385 rows including country

parser_healthcare_types %>% dplyr::group_by(ft) %>% unique()


df_who_sites <- dplyr::left_join(df_who_sites, parser_healthcare_types, by=c("Country", "Facility type" = "ft"))

df_who_sites$Tier_name <- ifelse(df_who_sites$Tier==1,"Tier1 health post",
                                 df_who_sites$Tier==2,"Tier2 health center",
                                 df_who_sites$Tier==3,"Tier3 provincial hospital",
                                 df_who_sites$Tier==4,"Tier4 central hospital")


usethis::use_data(df_who_sites, overwrite = TRUE)
