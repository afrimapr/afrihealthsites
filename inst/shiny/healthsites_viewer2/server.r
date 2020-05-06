#afrihealthsites/healthsites_viewer/server.r
# keeping this very simple partly so it can be used as a template by other (maybe new) R users


cran_packages <- c("leaflet","remotes")
lapply(cran_packages, function(x) if(!require(x,character.only = TRUE)) install.packages(x))


library(remotes)
library(leaflet)

if(!require(afrihealthsites)){
  remotes::install_github("afrimapr/afrihealthsites")
}

library(afrihealthsites)
#library(mapview)


# Define a server for the Shiny app
function(input, output) {

  # mapview interactive leaflet map plot
  output$serve_healthsites_map <- renderLeaflet({

    mapplot <- afrihealthsites::compare_hs_sources(input$country,
                                                   datasources=c('healthsites','who'),
                                                   plot='mapview',
                                                   plotshow=FALSE,
                                                   hs_amenity=input$hs_amenity)

    #important that this returns the @map bit
    #otherwise get Error in : $ operator not defined for this S4 class
    mapplot@map


    })


}
