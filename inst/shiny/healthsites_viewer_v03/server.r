#afrihealthsites/healthsites_viewer_v03/server.r

# to add selection by admin region

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


#global variables

# to try to allow retaining of map zoom, when type checkboxes are selected
zoom_view <- NULL
# when country is changed I want whole map to change
# but when input$hs_amenity or input$selected_who_cats are changed I want to retain zoom
# perhaps can just reset zoomed view to NULL when country is changed


# Define a server for the Shiny app
function(input, output) {

  ######################################
  # mapview interactive leaflet map plot
  output$serve_healthsites_map <- renderLeaflet({

    mapplot <- afrihealthsites::compare_hs_sources(input$country,
                                                   datasources=c('healthsites','who'),
                                                   plot='mapview',
                                                   plotshow=FALSE,
                                                   hs_amenity=input$hs_amenity,
                                                   type_column = input$who_type_option, #allows for 9 broad cats
                                                   who_type=input$selected_who_cats,
                                                   admin_level=input$cboxadmin,
                                                   admin_names=input$selected_admin_names)

    # to retain zoom if only types have been changed
    if (!is.null(zoom_view))
    {
      mapplot@map <- leaflet::fitBounds(mapplot@map, lng1=zoom_view$west, lat1=zoom_view$south, lng2=zoom_view$east, lat2=zoom_view$north)
    }


    #important that this returns the @map bit
    #otherwise get Error in : $ operator not defined for this S4 class
    mapplot@map

    })

  #########################################################################
  # trying to detect map zoom as a start to keeping it when options changed
  observeEvent(input$serve_healthsites_map_bounds, {

    #print(input$serve_healthsites_map_bounds)

    #save to a global object so can reset to it
    zoom_view <<- input$serve_healthsites_map_bounds
  })

  ####################################################################
  # perhaps can just reset zoomed view to NULL when country is changed
  # hurrah! this works, is it a hack ?
  observe({
    input$country
    zoom_view <<- NULL
  })


  ###################################
  # to update map without resetting everything use leafletProxy
  # see https://rstudio.github.io/leaflet/shiny.html
  # Incremental changes to the map should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  # BUT I don't quite know how to use with a mapview map ...
  # observe({
  #   #pal <- colorpal()
  #   # leafletProxy("map", data = filteredData()) %>%
  #   #   clearShapes() %>%
  #   #   addCircles(radius = ~10^mag/10, weight = 1, color = "#777777",
  #   #              fillColor = ~pal(mag), fillOpacity = 0.7, popup = ~paste(mag)
  #   #  )
  # })


  ################################################################################
  # dynamic selectable list of who facility categories for selected country
  output$select_who_cat <- renderUI({

    # get selected country name
    #input$country

    # get categories in who for this country
    # first get the sf object - but later don't need to do that
    # TODO add a function to afrihealthsites package to return just the cats
    sfwho <- afrihealthsites::afrihealthsites(input$country, datasource = 'who', plot = FALSE)

    #who_cats <- unique(sfwho$`Facility type`)
    # allowing for 9 cat reclass, & 4 Tiers
    who_cats <- sort(unique(sfwho[[input$who_type_option]]))

    #"who-kemri categories"
    checkboxGroupInput("selected_who_cats", label = NULL, #label = h5("who-kemri categories"),
                       choices = who_cats,
                       selected = who_cats,
                       inline = FALSE)
  })

  ################################################################################
  # dynamic selectable list of admin regions for selected country [&later admin level]
  output$select_admin <- renderUI({

    # get selected country name
    #input$country

    # get categories in who for this country
    # first get the sf object - but maybe later don't need to do that
    # TODO? add a function to afriadmin package to return just the cats
    sfadmin <- afriadmin::afriadmin(input$country, datasource = 'geoboundaries', plot = FALSE)

    admin_names <- unique(sfadmin$shapeName)

    #should I allow multiple regions or just one ?
    #problem doing this as checkboxGroupInput is that it takes up loads of space
    #better  MVP may be to offer selectInput() with just one regions selectable
    #or selectInput even with multiple selections allowed takes less space
    #checkboxGroupInput("selected_admin_names", label = NULL, #label = h5("who-kemri categories"),
    selectInput("selected_admin_names", label = NULL, #label = h5("who-kemri categories"),
                       choices = admin_names,
                       selected = admin_names[1],
                       size=5, selectize=FALSE, multiple=TRUE)
  })

  ########################
  # barplot of facility types
  output$plot_fac_types <- renderPlot({


    #palletes here set to match those in map from compare_hs_sources()

    gg1 <- afrihealthsites::facility_types(input$country,
                                    datasource = 'healthsites',
                                    plot = TRUE,
                                    type_filter = input$hs_amenity,
                                    #ggcolour_h=c(0,175)
                                    brewer_palette = "YlGn",
                                    admin_level=input$cboxadmin,
                                    admin_names=input$selected_admin_names )

    gg2 <- afrihealthsites::facility_types(input$country,
                                           datasource = 'who',
                                           plot = TRUE,
                                           type_filter = input$selected_who_cats,
                                           type_column = input$who_type_option, #allows for 9 broad cats
                                           #ggcolour_h=c(185,360)
                                           brewer_palette = "BuPu",
                                           admin_level=input$cboxadmin,
                                           admin_names=input$selected_admin_names )

    # avoid error for N.Africa countries with no WHO data
    if (is.null(gg2))
    {
      gg1

    } else
    {
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

      #setting heights to num cats makes bar widths constant between cats
      gg1 / gg2 + plot_layout(heights=c(max_y1, max_y2)) #patchwork
    }



  })

  #######################
  # table of raw who data
  output$table_raw_who <- DT::renderDataTable({

    sfwho <- afrihealthsites::afrihealthsites(input$country, datasource = 'who', who_type = input$selected_who_cats, plot = FALSE,
                                              admin_level=input$cboxadmin,
                                              admin_names=input$selected_admin_names)

    # drop the geometry column - not wanted in table
    sfwho <- sf::st_drop_geometry(sfwho)

    DT::datatable(sfwho, options = list(pageLength = 50))

  })

  ###############################
  # table of raw healthsites data
  output$table_raw_hs <- DT::renderDataTable({

    sfhs <- afrihealthsites::afrihealthsites(input$country, datasource = 'healthsites', hs_amenity = input$hs_amenity, plot = FALSE,
                                             admin_level=input$cboxadmin,
                                             admin_names=input$selected_admin_names)

    # drop the geometry column and few others - not wanted in table
    sfhs <- sf::st_drop_geometry(sfhs)
    sfhs <- sfhs[, which(names(sfhs)!="iso3c" & names(sfhs)!="country")]

    DT::datatable(sfhs, options = list(pageLength = 50))
  })

  ###############################
  # table of national list (MFL) availability
  output$table_national_list_avail <- DT::renderDataTable({


    DT::datatable(national_list_avail(), options = list(pageLength = 55))
  })

}
