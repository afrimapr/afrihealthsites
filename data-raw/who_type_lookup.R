#a lookup table to convert from 173 facility type categories in who-kemri data to 9 catgeories
#from paper : Hulland(2019) https://link.springer.com/article/10.1186/s12916-019-1459-6

#Lookup table copied from : https://static-content.springer.com/esm/art%3A10.1186%2Fs12916-019-1459-6/MediaObjects/12916_2019_1459_MOESM1_ESM.docx
#1. Pasted, values only, into googlesheets.
#2. googlesheets find & replace "" with " to correct 5 errors from IHME lookup for Central African Republic e.g. Centre de Santé ""E""



library(googlesheets4)

# Read data for lookup table from Google Sheet
# Authorisation needed - run interactively
who_type_lookup <- read_sheet("https://docs.google.com/spreadsheets/d/1esITXJxb2ph63sA3nPXmK795PUs34Vsu16YGSIGJ47U/edit?usp=sharing")

names(who_type_lookup) <- c('country','type_who','facility_type_9')

#save(who_type_lookup, file = "data/who_type_lookup.rda" )

usethis::use_data(who_type_lookup, overwrite = TRUE)


#use of lookup

# in df_who_sites.r used to add column onto df_who_sites
#df_who_sites$facility_type_9 <- who_type_lookup$facility_type_9[ match(df_who_sites$`Facility type`,who_type_lookup$type_who) ]


#sftogo <- afrihealthsites::afrihealthsites('togo', datasource = 'who', plot=FALSE)
#match returns a vector of the positions of (first) matches of its first argument in its second.
#sftogo$facility_type_9 <- who_type_lookup$facility_type_9[ match(sftogo$`Facility type`,who_type_lookup$type_who) ]

#sfall <- afrihealthsites::afrihealthsites('all', datasource = 'who', plot=FALSE)
#sfall$facility_type_9 <- who_type_lookup$facility_type_9[ match(sfall$`Facility type`,who_type_lookup$type_who) ]

#WHO9 : I think I could cut it down further from 9
#also whocats9 from the table actually has 12 cats
#whocats9 <- unique(df_who_sites$facility_type_9)
#whocats9
#  "Hospital"              "Health Centre"         "Health Post"           "Maternity"             "Community Health Unit"
#  "Dispensary"            "Medical Center"        "Health Clinic"         NA                      "Polyclinic"
#  "Health Station"        "Health Hut"
#table(df_who_sites$facility_type_9)

# Community Health Unit  Dispensary  Health Centre  Health Clinic  Health Hut
# 3044                   13673       35394          21154          2009
# Health Post  Health Station  Hospital  Maternity  Medical Center  Polyclinic
# 16526        324             4861      42         1343            131

#Hulland(2019) says:  hospital, health clinic, dispensary, community health unit, health post, health center, maternity ward, medical center, or polyclinic
#so it doesn't have: Health Hut, Health Station and NA
# sfwhoall <- afrihealthsites('all', datasource = 'who', plot=FALSE )
# whocats9 <- unique(sfwhoall$facility_type_9)

#whocatsless <- whocats9[which(! (whocats9=='Polyclinic' | whocats9=='Maternity' | whocats9=='Health station' ))]

#a check on the 240 NAs in reclassed WHO data
#sfwhoNA <- sfwhoall[which(is.na(sfwhoall$facility_type_9)),]
#unique(sfwhoNA[['Facility type']]) # gives 17 types that appear not to have been converted
#"Unites de Santé de village"  "Postos Sanitários"           "Hospitais Regionais"         "Hospitais Centrais"
#"Centre Médico-Chirurgical"   "Centre Médico-Urbain"        "Poste De Santé"              "Clinic without Maternity"
#"Public Health Unit"          "Clinic with Maternity"       "Health post"                 "Area Health Centre"
#"Family Health Clinic"        "Medi-Clinic"                 "Hospitais"                   "Postos de Saúde Comunitária"
#"Primary Health Care Unit +"
#TODO add these into who_type_lookup


