## code to prepare `sf_healthsites_af` dataset goes here

#sf_healthsites_af <- NULL

#country names that currently need changing for rhealthsites
afcountries$name2 <- afcountries$name

afcountries$name2[afcountries$name=='Republic of Congo'] <- 'congo-brazzaville'
afcountries$name2[afcountries$name=='Gambia'] <- 'the gambia'
afcountries$name2[afcountries$name=='Guinea Bissau'] <- 'guinea-bissau'
afcountries$name2[afcountries$name=='Swaziland'] <- 'eswatini'
afcountries$name2[afcountries$name=='United Republic of Tanzania'] <- 'Tanzania'
#remove western sahara for now, 'sahrawi arab democratic republic' does have one hospital
afcountries <- afcountries[-which(afcountries$name=='Western Sahara'),]
afcountries <- afcountries[-which(afcountries$name=='Sao Tome and Principe'),]

#there is a problem with south africa
# Error in rbind.data.frame(...) :
# numbers of columns of arguments do not match
#remove it temporarily
afcountries <- afcountries[-which(afcountries$name=='South Africa'),]

for(countrynum in 1:nrow(afcountries))
{
  #name2 contains corrected names above
  name <- afcountries$name2[countrynum]
  iso3c <- afcountries$iso3c[countrynum]

  cat(name,"\n")

  #important that uses healthsites_live
  sfcountry <- afrihealthsites(name, datasource='healthsites_live', plot=FALSE)

  #add country identifiers
  sfcountry$country <- name
  sfcountry$iso3c <- iso3c

  if (countrynum==1) sf_healthsites_af <- sfcountry
  else sf_healthsites_af <- rbind(sf_healthsites_af, sfcountry)

}


usethis::use_data(sf_healthsites_af, overwrite = TRUE)
