#' get & plot freq of facility types for a country
#'
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param datasource data source, 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param datasource_title optional title for datasource to be used in plots - particularly if a filname has been passed for datasource
#' @param type_filter filter by facility type - will depend on the data source
# @param ggcolour_h c(0,360) ggplot colour hue range
#' @param brewer_palette ColorBrewer palette default 'BuPu',
# @param who_type filter by Facility type
# @param returnclass 'sf' or 'dataframe', currently 'dataframe' only offered for WHO so that can have points with no coords
#' @param lonlat_columns just for user provided files which columns contain longitude, latitude
#' @param type_column just for user provided files which column has information on type of site, default : 'Facility Type'
#' @param label_column just for user provided files which column has information on name of site, default : 'Facility Name'
#' @param plot_title title for plot, 'default', string or NULL for no title
#' @param plot whether to display plot
#'
#' @examples
#'
#' ggnga <- facility_types("nigeria", datasource='who')
#'
#' facility_types('chad', datasource='who')
#' facility_types('chad', datasource='healthsites')
#'
#'
#' #filter healthsites data by amenity type
#' facility_types('chad',datasource = 'healthsites', type_filter=c('clinic','hospital'))
#' #filter who data by Facility type
#' facility_types('chad',datasource = 'who', type_filter=c('Regional hospital','Health Centre'))
#'
#' # from an sf object
#' data(sfssd)
#' ggssd <- facility_types("south sudan",
#'                         datasource=sfssd,
#'                         type_column = "type")
#'
#' # using consistent 9 class facility types for WHO data, specify type_column='facility_type_9'
#' facility_types('all', datasource='who', type_column='facility_type_9')
#'
#' @return \code{ggplot2} object
#' @importFrom ggplot2 ggplot aes geom_bar geom_text theme_minimal labs scale_fill_manual scale_x_reverse
#' @importFrom grDevices colorRampPalette
#' @export
#'
facility_types <- function(country,
                      datasource = 'healthsites', #'hdx', #'who',
                      datasource_title = NULL,
                      type_filter = 'all',
                      #hs_amenity = 'all',
                      #who_type = 'all',
                      #returnclass = 'sf',
                      type_column = 'Facility Type',
                      label_column = 'Facility Name',
                      # ggcolour_h = c(0, 360),
                      brewer_palette = 'BuPu',
                      lonlat_columns = c("Longitude", "Latitude"),
                      plot_title = 'default',
                      plot = TRUE

                      ) {


  # country <- 'Togo'
  # type_filter = c('clinic', 'doctors', 'pharmacy', 'hospital')
  # type_filter = 'all'
  # datasource = 'healthsites' #'who'

  # setting name of the type_column for who & healthsites (potential to supply user-defined option)
  type_column <- nameof_zcol(datasource = datasource, type_column = type_column)

  #currently different filter arg used for healthsites (hs_amenity) & who (who_type)
  #todo maybe try to generalise that in afrihealthsites()

  # deal with passed object first - can cause problems with other conditions
  # have to use %in% because sf objects give both sf & dataframe for class
  if ("data.frame" %in% class(datasource) || "sf" %in% class(datasource) || file.exists(datasource)) # a user supplied file
  {

    sf1 <- afrihealthsites(country, datasource = datasource, plot=FALSE,
                           type_filter = type_filter,
                           type_column = type_column,
                           label_column = label_column,
                           lonlat_columns = lonlat_columns) #, who_type=who_type)


  }  else if (is.character(datasource) && datasource == 'healthsites')
  {

    sf1 <- afrihealthsites(country, datasource = datasource, plot=FALSE, hs_amenity=type_filter) #, who_type=who_type)

  } else if (is.character(datasource) && datasource == 'who')
  {

    sf1 <- afrihealthsites(country, datasource = datasource, plot=FALSE, who_type=type_filter, type_column=type_column) #, who_type=who_type)

  }



  # if there are no facilities (e.g. North Africa WHO) return NULL
  if (is.null(sf1)) return(NULL)

  tot_facilities <- nrow(sf1)

  # ggplot(sf1) +
  #   geom_bar(aes(y = amenity))

  #todo order facilities

  #if (plot != FALSE)
  #{

    if (!requireNamespace("ggplot2", quietly = TRUE)) {
      stop("Package \"ggplot2\" needed for this function to work. Please install it from CRAN",
           call. = FALSE)
    }


    #TODO try to generalise this so that can use the type_column argument to specify y & fill
    # one option is just to create a new column with the same name for all

    #reversing order to match order in map from compare_hs_sources()
    sf1$facility_type <- factor(sf1[[type_column]], levels = rev(sort(unique(sf1[[type_column]]))))

    numcolours <- length(unique(sf1$facility_type))

    gg <- ggplot2::ggplot(sf1, aes(y = facility_type, fill = facility_type))


    # OLD WAY OF DOING
    # if (datasource == 'healthsites')
    # {
    #   #reversing order to match order in map from compare_hs_sources()
    #   sf1$amenity <- factor(sf1$amenity, levels = rev(sort(unique(sf1$amenity))))
    #   gg <- ggplot2::ggplot(sf1, aes(y = amenity, fill = amenity))
    #   numcolours <- length(unique(sf1[["amenity"]]))
    #
    # } else if (datasource == 'who')
    # {
    #   sf1$`Facility type` <- factor(sf1$`Facility type`, levels = rev(sort(unique(sf1$`Facility type`))))
    #   gg <- ggplot2::ggplot(sf1, aes(y = `Facility type`, fill = `Facility type`))
    #   numcolours <- length(unique(sf1[["Facility type"]]))
    # }


    if ( is.null(datasource_title) )
    {
      if (is.character(datasource)) datasource_title <- datasource
      else datasource_title <- "file"
    }

    if (plot_title == 'default')
       plot_title <- paste("Selected facility types from", datasource_title,"for",country,"( Total =",tot_facilities,")" )


    gg <- gg + geom_bar(show.legend=FALSE) +
      theme_minimal() +
      geom_text(stat='count', aes(label=..count..), hjust='left') + # hjust=-1) +
      labs(title=plot_title) +
      #subtitle= paste("Total =",tot_facilities)) +
      #scale_fill_brewer(palette=brewer_palette) + #problem with scale_fill_brewer when too many classes
      #pallete reversed to match those in map from compare_hs_sources()
      scale_fill_manual(values = rev(colorRampPalette(RColorBrewer::brewer.pal(5, brewer_palette))(numcolours))) +
      #scale_y_reverse() #to get order of cats to match those in map from compare_hs_sources()
      #scale_fill_hue(h = ggcolour_h, c=150) +
      NULL

    if (plot) plot(gg)

    # return the ggplot object
    invisible(gg)

    # ggplot(sf1, aes(y = amenity, fill = amenity)) +
    #   geom_bar(show.legend=FALSE) +
    #   theme_minimal() +
    #   geom_text(stat='count', aes(label=..count..), hjust='left') + # hjust=-1) +
    #   labs(title=paste("Selected facility types from", datasource,"for",country,"( Total =",tot_facilities,")" ))+
    #        #subtitle= paste("Total =",tot_facilities)) +
    #   NULL


    #}

}
