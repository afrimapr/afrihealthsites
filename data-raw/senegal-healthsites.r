#senegal-healthsites.r

#temporary code
#move somewhere else : also used in shiny/senegal_healthsites/server.r


library(sf)
library(mapview)

#path <- "C:\\Dropbox\\_afrimapr\\healthsites\\"
#filename <- "St Louis Data Collection Campaign-Gth_Hs_Osm_11.csv"

#temporarily put it in extdata
filename <- "St-Louis-Data-Collection-Campaign-Gth_Hs_Osm_11.csv"
filename <- system.file("extdata", filename, package = "afrihealthsites")

filename <- paste0(path, filename)

# encoding="UTF-8" fixes accent problems
dfsen <- utils::read.csv(filename, stringsAsFactors = FALSE, encoding="UTF-8")


#BEWARE of order of long lat and it changing with sf version
#sfsen <- sf::st_as_sf(dfsen, coords=c("Facility.Location...latitude","Facility.Location...longitude"))
sfsen <- sf::st_as_sf(dfsen, coords=c("Facility.Location...longitude", "Facility.Location...latitude"), crs = 4326, na.fail = FALSE)

# have to specify the crs above for it to display on the map
mapview::mapview(sfsen)

mapview::mapview(sfsen,
                 zcol="Number.of.Beds",
                 #at = c(0,1,2,5,10,50,100,250),
                 at = c(0,1,2,10,50,100,250),
                 cex = "Number.of.Beds")
