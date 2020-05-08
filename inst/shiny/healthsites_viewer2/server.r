#afrihealthsites/healthsites_viewer2/server.r
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
                                                   hs_amenity=input$hs_amenity,
                                                   who_type=input$selected_who_cats)

    #important that this returns the @map bit
    #otherwise get Error in : $ operator not defined for this S4 class
    mapplot@map

    })

  # create dynamic selectable list of who facility categories for selected country
  output$select_who_cat <- renderUI({

    # get selected country name
    #input$country

    # get categories in who for this country
    # first get the sf object - but later don't need to do that
    # TODO add a function to afrihealthsites package to return just the cats
    sfwho <- afrihealthsites::afrihealthsites(input$country, datasource = 'who', plot = FALSE)
    who_cats <- unique(sfwho$`Facility type`)

    checkboxGroupInput("selected_who_cats", label = "who-kemri categories", #label = h5("who-kemri categories"),
                       choices = who_cats,
                       selected = who_cats,
                       inline = FALSE)
  })



}
