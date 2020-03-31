#afrihealthsites/senegal_healthsites/server.r
# keeping this very simple partly so it can be used as a template by other (maybe new) R users


cran_packages <- c("leaflet","remotes")
lapply(cran_packages, function(x) if(!require(x,character.only = TRUE)) install.packages(x))

library(remotes)
library(leaflet)

if(!require(afrihealthsites)){
  remotes::install_github("afrimapr/afrihealthsites")
}

library(afrihealthsites)
library(mapview)
library(sf)

#load the data
#temporarily put it in extdata
filename <- "St Louis Data Collection Campaign-Gth_Hs_Osm_11.csv"
filename <- system.file("extdata", filename, package = "afrihealthsites")

# encoding="UTF-8" fixes accent problems
dfsen <- read.csv(filename, stringsAsFactors = FALSE, encoding="UTF-8")

#BEWARE of order of long lat and it changing with sf version
#sfsen <- sf::st_as_sf(dfsen, coords=c("Facility.Location...latitude","Facility.Location...longitude"))
sfsen <- sf::st_as_sf(dfsen, coords=c("Facility.Location...longitude", "Facility.Location...latitude"), crs = 4326)


# Define a server for the Shiny app
function(input, output) {

  # mapview interactive leaflet map plot
  output$serve_healthsites_map <- renderLeaflet({


    mapplot <- mapview::mapview(sfsen,
                     zcol = input$attribute_to_plot,
                     layer.name = input$attribute_to_plot,
                     label=paste(sfsen[["Facility.Category"]],":",sfsen[["Name.of.Facility"]],":",sfsen[[input$attribute_to_plot]]),
                     #at = c(0,1,2,5,10,50,100,250),
                     #at = c(0,1,2,10,50,100,250),
                     cex = input$attribute_to_plot)

    #important that this returns the @map bit
    #otherwise get Error in : $ operator not defined for this S4 class
    mapplot@map

    #mapview::mapview(sf_who_sites)

    })


}
