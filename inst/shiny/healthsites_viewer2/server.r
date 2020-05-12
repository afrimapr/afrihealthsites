#afrihealthsites/healthsites_viewer2/server.r
# keeping this very simple partly so it can be used as a template by other (maybe new) R users


cran_packages <- c("leaflet","remotes")
lapply(cran_packages, function(x) if(!require(x,character.only = TRUE)) install.packages(x))


library(remotes)
library(leaflet)
library(ggplot2)
library(patchwork) #for combining ggplots

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


  # plot of facility types
  output$plot_fac_types <- renderPlot({


    #palletes here set to match those in map from compare_hs_sources()

    gg1 <- afrihealthsites::facility_types(input$country,
                                    datasource = 'healthsites',
                                    plot = TRUE,
                                    type_filter = input$hs_amenity,
                                    #ggcolour_h=c(0,175)
                                    brewer_palette = "YlGn" )

    gg2 <- afrihealthsites::facility_types(input$country,
                                           datasource = 'who',
                                           plot = TRUE,
                                           type_filter = input$selected_who_cats,
                                           #ggcolour_h=c(185,360)
                                           brewer_palette = "BuPu" )

    #set xmax to be the same for both plots
    #hack to find max xlim for each object
    #TODO make this less hacky ! it will probably fail when ggplot changes
    max_x1 <- max(ggplot_build(gg1)$layout$panel_params[[1]]$x$continuous_range)
    max_x2 <- max(ggplot_build(gg2)$layout$panel_params[[1]]$x$continuous_range)
    #set xmax for both plots to this
    gg1 <- gg1 + xlim(c(0,max(max_x1,max_x2, na.rm=TRUE)))
    gg2 <- gg2 + xlim(c(0,max(max_x1,max_x2, na.rm=TRUE)))

    #set size of y plots to be dependent on num cats
    #y axis has cats, this actually gets max of y axis, e.g. for 6 cats is 6.6
    max_y1 <- max(ggplot_build(gg1)$layout$panel_params[[1]]$y$continuous_range)
    max_y2 <- max(ggplot_build(gg2)$layout$panel_params[[1]]$y$continuous_range)

    gg1 / gg2 + plot_layout(heights=c(max_y1, max_y2)) #patchwork

  })


}
