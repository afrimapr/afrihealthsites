## code to prepare `sfssd` dataset goes here

#downloaded from
#https://www.southsudanhealth.info/facility/fac.php?list&s=0&p=0&ps=2889

#ssudan_file <- "data-raw\\south_sudan_facility_info_2020-05-13.csv"

# test reading in file
dfssd <- read.csv(ssudan_file, as.is=TRUE, check.names=FALSE)


#ssudan has a single location column containing coords divided by commas as strings
# fair few coords at null island 0,0
# seemingly some NAs, or maybe problem with me trying to pass single Location rather than 2 columns
#which(is.na(dfssudan$Location))
#sfssudan <- sf::st_as_sf(dfssudan, coords='Location')

#dfs <- head(dfssudan)

#divide into 2 columns
dfcoords <- as.data.frame(stringr::str_split(dfssd$Location,", ",simplify=TRUE), stringsAsFactors = FALSE)
#change to numeric
dfcoords <- lapply(dfcoords,as.numeric)
#name columns
#names(dfcoords) <- c("Longitude", "Latitude")
names(dfcoords) <- c("Latitude", "Longitude")
#bind back onto df
dfssd <- cbind(dfssd, dfcoords)

sfssd <- sf::st_as_sf(dfssd, coords=c("Longitude", "Latitude"), crs = 4326, na.fail = FALSE)

#mapview::mapview(sfssd)

usethis::use_data(sfssd)
