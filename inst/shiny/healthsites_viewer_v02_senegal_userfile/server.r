#afrihealthsites/healthsites_viewer_v02_senegal_userfile/server.r

# add ability for Senegal to show user supplied file for Senegal data collection (alongside existing kemri & healthsites data)


cran_packages <- c("leaflet","remotes")
lapply(cran_packages, function(x) if(!require(x,character.only = TRUE)) install.packages(x))


library(remotes)
library(leaflet)
library(ggplot2)
library(patchwork) #for combining ggplots
#library(googlesheets4) # to get user data from googlesheets

if(!require(afrihealthsites)){
  remotes::install_github("afrimapr/afrihealthsites")
}

library(afrihealthsites)
#library(mapview)

# trying out shi18ny for internationalisation
# if(!require(shi18ny)){
#   remotes::install_github("datasketch/shi18ny")
# }



#global variables

# to try to allow retaining of map zoom, when type checkboxes are selected
zoom_view <- NULL
# when country is changed I want whole map to change
# but when input$hs_amenity or input$selected_who_cats are changed I want to retain zoom
# perhaps can just reset zoomed view to NULL when country is changed


###################################################################
#TODO can I add the extra Senegal data to the mapplot object here ?

# as first test try reading the data from the googledoc
# https://drive.google.com/file/d/1wYPUYv__fE47WsCmndb9BkaD1guS10uW/view
# original xls file from Mark failed to read
#urldata <- "https://docs.google.com/spreadsheets/d/1wYPUYv__fE47WsCmndb9BkaD1guS10uW/edit#gid=2021053723"
# saved as a googlesheet
# urldata <- "https://docs.google.com/spreadsheets/d/1gXtpV-B7L1nP4PK1WMDP7qvkWygw4XJSkVO-gN5IM4E/edit#gid=2021053723"
# saved to github otherwise fails on shinyapps due to needed google authorisation (prob fixable but this easier)
#urldata <- "https://raw.githubusercontent.com/afrimapr/afrimapr_dev/master/data-raw/senegal-emergency-health-data-English-2020-08-03.csv"
urldata <- "https://raw.githubusercontent.com/afrimapr/afrimapr_dev/master/data-raw/senegal-emergency-health-data-English-2020-08-07.csv"


# read in data
dfuser <- read.csv(urldata, encoding = 'UTF-8', check.names = FALSE)
#dfuser <- googlesheets4::read_sheet(ss = urldata)
# convert to spatial format
sfuser <- sf::st_as_sf(dfuser, coords = c("_Facility Location_longitude", "_Facility Location_latitude"), crs = 4326, na.fail=FALSE)



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
                                                   who_type=input$selected_who_cats)


    ###################################################################
    #TODO can I add the extra Senegal data to the mapplot object here ?

    # coolio either of these adds new data to the existing map
    # mapplot + sfuser
    # mvsen + mapview(sfuser)
    mapplot <- mapplot + mapview::mapview(sfuser,
                                 zcol = "Facility Category",
                                 label=paste("new data",sfuser[["Facility Category"]],sfuser[["Name of Facility"]]),
                                 layer.name = "new data",
                                 col.regions = RColorBrewer::brewer.pal(3, "Oranges"))

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
    # allowing for 9 cat reclass
    who_cats <- unique(sfwho[[input$who_type_option]])

    #"who-kemri categories"
    checkboxGroupInput("selected_who_cats", label = NULL, #label = h5("who-kemri categories"),
                       choices = who_cats,
                       selected = who_cats,
                       inline = FALSE)
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
                                    brewer_palette = "YlGn" )

    gg2 <- afrihealthsites::facility_types(input$country,
                                           datasource = 'who',
                                           plot = TRUE,
                                           type_filter = input$selected_who_cats,
                                           type_column = input$who_type_option, #allows for 9 broad cats
                                           #ggcolour_h=c(185,360)
                                           brewer_palette = "BuPu" )

    #newly collected data in dataframe
    gg3 <- afrihealthsites::facility_types(input$country,
                                           datasource = sfuser, #using sf stops it from needing names of coord columns
                                           plot = TRUE,
                                           #lonlat_columns =
                                           type_filter = 'all',
                                           type_column = 'Facility Category',
                                           brewer_palette = "Oranges" )

    # avoid error for N.Africa countries with no WHO data
    # this version is just for Senegal so not a problem - but possible future issue for other countries
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
      max_x3 <- max(ggplot_build(gg3)$layout$panel_params[[1]]$x$continuous_range)
      #set xmax for all plots to this
      max_x <- max(max_x1,max_x2,max_x3, na.rm=TRUE)
      gg1 <- gg1 + xlim(c(0,max_x))
      gg2 <- gg2 + xlim(c(0,max_x))
      gg3 <- gg3 + xlim(c(0,max_x))

      #set size of y plots to be dependent on num cats
      #y axis has cats, this actually gets max of y axis, e.g. for 6 cats is 6.6
      max_y1 <- max(ggplot_build(gg1)$layout$panel_params[[1]]$y$continuous_range)
      max_y2 <- max(ggplot_build(gg2)$layout$panel_params[[1]]$y$continuous_range)
      max_y3 <- max(ggplot_build(gg3)$layout$panel_params[[1]]$y$continuous_range)

      #setting heights to num cats makes bar widths constant between cats
      gg1 / gg2 / gg3 + plot_layout(heights=c(max_y1, max_y2, max_y3)) #patchwork
    }



  })

  #######################
  # table of raw who data
  output$table_raw_who <- DT::renderDataTable({

    sfwho <- afrihealthsites::afrihealthsites(input$country, datasource = 'who', who_type = input$selected_who_cats, plot = FALSE)

    DT::datatable(sfwho, options = list(pageLength = 50))
  })

  ###############################
  # table of raw healthsites data
  output$table_raw_hs <- DT::renderDataTable({

    sfhs <- afrihealthsites::afrihealthsites(input$country, datasource = 'healthsites', hs_amenity = input$hs_amenity, plot = FALSE)

    DT::datatable(sfhs, options = list(pageLength = 50))
  })

  #######################
  # table of new user supplied data
  output$table_raw_user <- DT::renderDataTable({

    #data read in at start
    DT::datatable(dfuser, options = list(pageLength = 50))
  })

  #trying out internationalisation, I couldn't quite get it to work e.g. for headerPanel etc.
  # # Configure shi18ny
  # i18n <- list(
  #   defaultLang = "en",
  #   availableLangs = c("fr", "en", "pt")
  # )
  #
  # # Call language module to get currently selected language and save it in a reactive
  # lang <- callModule(langSelector, "lang", i18n = i18n, showSelector = TRUE)
  #
  # # Update UI translation
  # observeEvent(lang(),{
  #   uiLangUpdate(input$shi18ny_ui_classes, lang())
  # })

}
