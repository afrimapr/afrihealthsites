#' compare healthsite points from different sources for a country
#'
#' main aim to plot map comparing different sources
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param datasources vector of 2 datasources from 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param plot option to display map 'mapview' for interactive, 'sf' for static
#' @param plotshow whether to show the plot, otherwiser just return plot object
#' @param plotcex sizes of symbols for each source default=c(6,3), helps view symbol overlap
#' @param col.regions list of two colour palettes to pass to mapview
#' @param alpha list of two alphas to pass to mapview - low keeps borders light
#' @param alpha.regions list of two alpha.regions to pass to mapview
#' @param layer.names allow mapview layer.names to be set c('a','b')
#' @param plotlegend whether to add legend to mapview plot
#' @param hs_amenity filter healthsites data by amenity. 'all', 'clinic', 'dentist', 'doctors', 'pharmacy', 'hospital'
#' @param who_type filter by Facility type
#TODO replace filters with generic type_filters = list(c(x,y), c(z))
#' @param canvas mapview plotting option, TRUE by default for better performance with larger data
#' @param plotlabels1 whether to add static labels for source1
#' @param plotlabels2 whether to add static labels for source2
#' @param map.types optional specification of background map tiles for mapview, default c('CartoDB.Positron','OpenStreetMap.HOT')
#' @param type_column just for user provided files which column has information on type of site, default : 'Facility Type'
#' @param label_column just for user provided files which column has information on name of site, default : 'Facility Name'
#' @param lonlat_columns for user provided files which columns contain longitude, latitude. option of NULL if no coords
#' @param admin_level what admin level to filter regions from  FALSE or NULL if no filtering
#' @param admin_names names of admin regions to filter NULL if no filter
#'
#' @examples
#'
#' #compare_hs_sources("nigeria", datasources=c('who', 'healthsites'), plot='mapview')
#' #compare_hs_sources(c('malawi','zambia'))
#'
#' #filter by admin regions
#' compare_hs_sources('togo', admin_level=1, admin_names=c('Maritime Region', 'Centrale Region'))
#'
#' @return \code{sf}
#' @export
#'
compare_hs_sources <- function(country,
                            datasources = c('healthsites','who'), #'hdx',
                            plot = 'mapview',
                            plotshow = TRUE,
                            plotcex = c(6,4),
                            col.regions = list(RColorBrewer::brewer.pal(9, "YlGn"), RColorBrewer::brewer.pal(9, "BuPu")),
                            alpha = c(0.1, 0.1), #keep point borders light, but present to show light colours
                            alpha.regions = c(0.7, 0.7),
                            layer.names = NULL, #layer.names = c('a','b')
                            plotlegend = TRUE,
                            hs_amenity = 'all',
                            who_type = 'all',
                            canvas = FALSE, #with TRUE was causing plots not to display
                            plotlabels1 = FALSE,
                            plotlabels2 = FALSE,
                            map.types=c('CartoDB.Positron','OpenStreetMap.HOT'),
                            #TODO allow these columns to be specified for both sources
                            type_column = 'Facility Type',
                            label_column = 'Facility Name',
                            lonlat_columns = c("Longitude", "Latitude"),
                            admin_level = NULL,
                            admin_names = NULL
                            ) {

  #for debugging from shiny
  message(paste0("in compare_hs_sources country=",country," admin_level=",admin_level," admin_names=",admin_names))

  sf1 <- afrihealthsites(country, datasource = datasources[[1]], plot=FALSE, hs_amenity=hs_amenity, who_type=who_type, type_column=type_column, label_column=label_column, lonlat_columns=lonlat_columns, admin_level=admin_level, admin_names=admin_names)
  sf2 <- afrihealthsites(country, datasource = datasources[[2]], plot=FALSE, hs_amenity=hs_amenity, who_type=who_type, type_column=type_column, label_column=label_column, lonlat_columns=lonlat_columns, admin_level=admin_level, admin_names=admin_names)

  #TODO add a plot='sf' option

  if (plot == 'mapview')
  {

    #type_column is only used if the dataset is not one of the recognised ones
    zcol1 <- nameof_zcol(datasources[[1]], type_column)
    zcol2 <- nameof_zcol(datasources[[2]], type_column)

    labcol1 <- nameof_labcol(datasources[[1]], label_column)
    labcol2 <- nameof_labcol(datasources[[2]], label_column)

    #to try to avoid problem with layer.name when one of datasources is an object
    #this just replaces object with layer1 or 2
    if (is.null(layer.names))
    {
      layer.names = c(1,1)
      layer.names[[1]] <- ifelse(is.character(datasources[[1]]),datasources[[1]],"layer1")
      layer.names[[2]] <- ifelse(is.character(datasources[[2]]),datasources[[2]],"layer2")
    }


    # to set length of colour palette to length of data by interpolation partly to avoid warnings from mapview
    # colorRampPalette() returns a function that accepts the number of categories
    col.regions[[1]] <- grDevices::colorRampPalette(col.regions[[1]])
    col.regions[[2]] <- grDevices::colorRampPalette(col.regions[[2]])

    #add datasources separately to cope when one is missing or empty
    if (!is.null(sf1) & isTRUE(nrow(sf1) > 0))
    {
      mapplot <- mapview::mapview(sf1,
                                  zcol=zcol1,
                                  label=paste(sf1[[zcol1]],sf1[[labcol1]]),
                                  cex=plotcex[1],
                                  col.regions=col.regions[[1]],
                                  alpha.regions = alpha.regions[1],
                                  alpha = alpha[1],
                                  layer.name=layer.names[[1]],
                                  legend=plotlegend,
                                  map.types=map.types,
                                  canvas=canvas)


    }


    if (!is.null(sf2)  & isTRUE(nrow(sf2) > 0))
    {
      if (!is.null(sf1) & isTRUE(nrow(sf1) > 0))
      {
        mapplot <- mapplot + mapview::mapview(sf2,
                                          zcol=zcol2,
                                          label=paste(sf2[[zcol2]],sf2[[labcol2]]),
                                          cex=plotcex[2],
                                          col.regions=col.regions[[2]],
                                          alpha.regions = alpha.regions[2],
                                          alpha = alpha[2],
                                          layer.name=layer.names[[2]],
                                          legend=plotlegend,
                                          map.types=map.types,
                                          canvas=canvas )
      } else {
        #if there's no sf1 then start the plot with sf2
        mapplot <- mapview::mapview(sf2,
                                     zcol=zcol2,
                                     label=paste(sf2[[zcol2]],sf2[[labcol2]]),
                                     cex=plotcex[2],
                                     col.regions=col.regions[[2]],
                                     alpha.regions = alpha.regions[2],
                                     alpha = alpha[2],
                                     layer.name=layer.names[[2]],
                                     legend=plotlegend,
                                     map.types=map.types,
                                     canvas=canvas )

      }
    }

    # adding selected admin regions to the plot
    # bit wasteful because regions are already downloaded in afrihealthsites()
    # this code is copied from there
    if (!is.null(admin_level) & isTRUE(admin_level > 0) & !is.null(admin_names))
    {
      #TODO check that this admin level is available for this country & datasource
      #initially start on admin1
      admin_level <- 1
      sfadmin <- afriadmin::afriadmin(country, level=admin_level, datasource='geoboundaries', plot=FALSE)

      #filter just the selected regions
      #BEWARE that shapeName is particular to geoboundaries
      #TODO ignore case
      #sfadmin_sel <- dplyr::filter(sfadmin, shapeName%in%admin_names)
      #base alternative to avoid dplyr dependency
      sfadmin_sel <- sfadmin[which(sfadmin$shapeName%in%admin_names),]

      #add admin polygons to the plot
      mapplot_to_add <- mapview::mapview(sfadmin_sel, zcol="shapeName", color = "darkred", col.regions = "blue", alpha.regions=0.01, lwd = 2, legend=FALSE)

      #if there are no facilities in a region, mapplot is not created above
      #so just set the plot to the polygons here
      if ( exists('mapplot'))
         mapplot <- mapplot + mapplot_to_add
      else
         mapplot <- mapplot_to_add

    }

  } #end if plot mapview


  #option to add static labels
  #problem that it converts mapview object to a leaflet object so I can only do it once (unless I change to leaflet)
  #it should work on both mapview and leaflet objects
  #seems need to use package leafem version from github mapview version is deprecated
  #BUT when I installed development version of leafem from github it messed up how the map appeared
  #devtools::install_github("r-spatial/leafem")
  #different background and legend not right even when plotlabels1 & 2 set to FALSE
  #without leafem get this on the 2nd one
  #Error in checkAdjustProjection(data) :
  #  argument "data" is missing, with no default
  #as a workaround maybe I can add both at the same time ?
  if (plotlabels1 & plotlabels2) #TODO add test for if sf1 present
  {
    lopt = leaflet::labelOptions(noHide = TRUE,
                                 direction = 'bottom',
                                 textOnly = FALSE, offset=c(10,10)) #offset and textOnly seem not to work, may work in leafem

    #FAIL using list gave huge labels at each point
    # mapplot <- mapview::addStaticLabels(mapplot, label=list(paste(sf1[[zcol1]],sf1[[labcol1]]),
    #                                                         paste(sf2[[zcol2]],sf2[[labcol2]])),
    #                                     labelOptions = lopt)
    #this using c() didn't work either ...
    #mapplot <- mapview::addStaticLabels(mapplot, label=c(paste(sf1[[zcol1]],sf1[[labcol1]]),
    #                                                        paste(sf2[[zcol2]],sf2[[labcol2]])),
    #                                    labelOptions = lopt)
    #try using + failed too
    # mapplot <- mapplot + mapview::addStaticLabels(mapplot, data=sf2, label= paste(sf2[[zcol2]],sf2[[labcol2]]),
    #                                     labelOptions = lopt)


  }  else if (plotlabels1) #TODO add test for if sf1 present
  {
    lopt = leaflet::labelOptions(noHide = TRUE,
                        direction = 'bottom',
                        textOnly = FALSE, offset=c(10,10)) #offset and textOnly seem not to work, may work in leafem

    mapplot <- mapview::addStaticLabels(mapplot, label=paste(sf1[[zcol1]],sf1[[labcol1]]), labelOptions = lopt)

  } else if (plotlabels2) #TODO add test for if sf2 present
  {
    lopt = leaflet::labelOptions(noHide = TRUE,
                                 direction = 'bottom',
                                 textOnly = FALSE, offset=c(10,10)) #offset and textOnly seem not to work

    mapplot <- mapview::addStaticLabels(mapplot, label=paste(sf2[[zcol2]],sf2[[labcol2]]), labelOptions = lopt)
  }




  if (plotshow) print(mapplot)

  invisible(mapplot)

  # of course can't do the below because they have different numbers columns
  # TODO I could subset just the geometry and zcol columns (and maybe name) and then rbind to return
  #add source column, rbind and return in case it is useful
  # sf1$datasource <- datasources[[1]]
  # sf2$datasource <- datasources[[2]]
  #
  # sfboth <- rbind(sf1,sf2)
  # invisible(sfboth)
}


#trying to create a reproducible example of the problem



