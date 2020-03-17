## code to prepare `afcountries` dataset goes here
# copied from afriadmin package, may want to put in its own package to avoid code repetition

#usethis::use_data_raw("afcountries") #opens up an interactive window to save this script

# vector of all ISO 3 letter country codes for african countries
# can use rnaturalearth to get
#library(rnaturalearth)
#51 misses cape verde, comoros
#sf_ne_africa <- ne_countries(scale = 110, type = "countries", continent = 'africa', returnclass='sf')
#54 misses mauritius, seychelles. includes western sahara, somaliland
sf_ne_africa <- rnaturalearth::ne_countries(scale = "medium", type = "countries", continent = 'africa', returnclass='sf')

#plot(sf::st_geometry(sf_ne_africa))

#select just 2 columns, drop geometry
afcountries <- sf::st_drop_geometry(subset(sf_ne_africa, select=c('admin','adm0_a3')))
#rename columns
names(afcountries) <- c('name','iso3c')
#correct some codes
afcountries$iso3c[afcountries$iso3c=='SAH'] <- 'ESH' #replace western sahara code for gadm
afcountries$iso3c[afcountries$iso3c=='SDS'] <- 'SSD' #replace south sudan code for gadm
# why do I have solomon islands in africa ? think should be somaliland, internationally considered part of somalia
afcountries <- afcountries[afcountries$iso3c != 'SOL',] #remove somaliland code not in gadm

usethis::use_data(afcountries)
