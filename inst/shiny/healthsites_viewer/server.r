#afrihealthsites/healthsites_viewer/server.r
# keeping this very simple partly so it can be used as a template by other (maybe new) R users

library(leaflet)
#library(mapview)
#library(afrihealthsites)

# Define a server for the Shiny app
function(input, output) {


  # mapview interactive leaflet map plot
  output$serve_healthsites_map <- renderLeaflet({

    mapplot <- afrihealthsites::compare_hs_sources(input$country, datasources=c('who', 'healthsites'), plot='mapview', plotshow=FALSE)

    #important that this returns the @map bit
    #otherwise get Error in : $ operator not defined for this S4 class
    mapplot@map

    #mapview::mapview(sf_who_sites)
    #mapview::mapview(breweries)

    })


}
