#a lookup table to convert from 173 facility type categories in who-kemri data to 9 catgeories
#TODO add paper citation

#Lookup table copied from : https://static-content.springer.com/esm/art%3A10.1186%2Fs12916-019-1459-6/MediaObjects/12916_2019_1459_MOESM1_ESM.docx
#1. Pasted, values only, into googlesheets.
#2. googlesheets find & replace "" with " to correct 5 errors from IHME lookup for Central African Republic e.g. Centre de Santé ""E""

#from paper : Hulland(2019) https://link.springer.com/article/10.1186/s12916-019-1459-6

library(googlesheets4)

# Read data for lookup table from Google Sheet
# Authorisation needed - run interactively
who_type_lookup <- read_sheet("https://docs.google.com/spreadsheets/d/1esITXJxb2ph63sA3nPXmK795PUs34Vsu16YGSIGJ47U/edit?usp=sharing")

names(who_type_lookup) <- c('country','type_who','facility_type_9')

#save(who_type_lookup, file = "data/who_type_lookup.rda" )

usethis::use_data(who_type_lookup, overwrite = TRUE)


#use of lookup

#sftogo <- afrihealthsites::afrihealthsites('togo', datasource = 'who', plot=FALSE)
#match returns a vector of the positions of (first) matches of its first argument in its second.
#sftogo$facility_type_9 <- who_type_lookup$facility_type_9[ match(sftogo$`Facility type`,who_type_lookup$type_who) ]


#sfall <- afrihealthsites::afrihealthsites('all', datasource = 'who', plot=FALSE)
#sfall$facility_type_9 <- who_type_lookup$facility_type_9[ match(sfall$`Facility type`,who_type_lookup$type_who) ]
