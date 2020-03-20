## code to prepare `sf_who_sites` dataset goes here
#use_data_raw('sf_who_sites') #to create this script

address <- "https://www.who.int/malaria/areas/surveillance/who-cds-gmp-2019-01-eng.xlsx"

#mode='wb' needed to force binary transfer on windows apparently
download_failed <- tryCatch( utils::download.file(file.path(address), tempfilesites <- tempfile(), mode = "wb"),
                             error = function(e) {
                               message(paste('download failed'))
                               return(TRUE)
                             })

#return from this function if download error was caught by tryCatch
if (download_failed) return()


who_sites <- readxl::read_excel(tempfilesites)

#sf_who_sites <- st_as_sf(who_sites, coords = c("Long", "Lat"), crs = 4326)
#Error in st_as_sf.data.frame(who_sites, coords = c("Long", "Lat"), crs = 4326) :
#  missing values in coordinates not allowed

# identify and remove rows with no coords
indices_na_coords <- which(is.na(who_sites$Long) | is.na(who_sites$Lat))

#length(indices_na_coords)
#[1] 2350 #records that have no coords

who_sites <- who_sites[-indices_na_coords,]

# convert to sf
sf_who_sites <- sf::st_as_sf(who_sites, coords = c("Long", "Lat"), crs = 4326)

#nrow(sf_who_sites)
#[1] 96395

countries_who <- unique(sf_who_sites$Country)


# > unique(sf_who_sites$`Facility type`)
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


#mapview::mapview(sf_who_sites, zcol="Facility type", legend=FALSE)


usethis::use_data(sf_who_sites)
