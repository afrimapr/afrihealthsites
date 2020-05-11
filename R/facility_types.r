#' get & plot freq of facility types for a country
#'
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param datasource data source, 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param plot option to display map 'mapview' for interactive, 'sf' for static
#' @param type_filter filter healthsites data by amenity. 'all', 'clinic', 'dentist', 'doctors', 'pharmacy', 'hospital'
#'                   to exclude dentist hs_amenity=c('clinic', 'doctors', 'pharmacy', 'hospital')
# @param ggcolour_h c(0,360) ggplot colour hue range
#' @param plot whether to display plot
#' @param brewer_palette ColorBrewer palette default 'BuPu',
# @param who_type filter by Facility type
# @param returnclass 'sf' or 'dataframe', currently 'dataframe' only offered for WHO so that can have points with no coords
# @param type_column just for user provided files which column has information on type of site, default : 'Facility Type'
# @param label_column just for user provided files which column has information on name of site, default : 'Facility Name'
#'
#' @examples
#'
#' sfnga <- facility_types("nigeria", datasource='who')
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
#'
#' @return \code{ggplot2} object
#' @importFrom ggplot2 ggplot aes geom_bar geom_text theme_minimal labs scale_fill_manual scale_x_reverse
#' @importFrom grDevices colorRampPalette
#' @export
#'
facility_types <- function(country,
                      datasource = 'healthsites', #'hdx', #'who',
                      #plot = 'mapview',
                      type_filter = 'all',
                      #hs_amenity = 'all',
                      #who_type = 'all',
                      #returnclass = 'sf',
                      # type_column = 'Facility Type',
                      # label_column = 'Facility Name'
                      # ggcolour_h = c(0, 360),
                      brewer_palette = 'BuPu',
                      plot = TRUE
                      ) {

  #warning('only works for healthsites so far')

  # country <- 'Togo'
  # type_filter = c('clinic', 'doctors', 'pharmacy', 'hospital')
  # type_filter = 'all'
  # datasource = 'healthsites' #'who'


  # setting name of the type_column for who & healthsites (potential to supply user-defined option)
  type_column <- nameof_zcol(datasource = datasource, type_column = type_column)

  #currently different filter arg used for healthsites (hs_amenity) & who (who_type)
  #todo maybe try to generalise that in afrihealthsites()
  if (datasource == 'healthsites')
  {

    sf1 <- afrihealthsites(country, datasource = datasource, plot=FALSE, hs_amenity=type_filter) #, who_type=who_type)

  } else if (datasource == 'who')
  {

    sf1 <- afrihealthsites(country, datasource = datasource, plot=FALSE, who_type=type_filter) #, who_type=who_type)

  }

  # if there are no facilities (e.g. North Africa WHO) return NULL
  if (is.null(sf1)) return(NULL)

  tot_facilities <- nrow(sf1)

  # ggplot(sf1) +
  #   geom_bar(aes(y = amenity))

  #todo order facilities

  if (plot != FALSE)
  {

    if (!requireNamespace("ggplot2", quietly = TRUE)) {
      stop("Package \"ggplot2\" needed for this function to work. Please install it from CRAN",
           call. = FALSE)
    }


    #TODO try to generalise this so that can use the type_column argument to specify y & fill
    if (datasource == 'healthsites')
    {
      #reversing order to match order in map from compare_hs_sources()
      sf1$amenity <- factor(sf1$amenity, levels = rev(sort(unique(sf1$amenity))))
      gg <- ggplot2::ggplot(sf1, aes(y = amenity, fill = amenity))
      numcolours <- length(unique(sf1[["amenity"]]))

    } else     if (datasource == 'who')
    {
      sf1$`Facility type` <- factor(sf1$`Facility type`, levels = rev(sort(unique(sf1$`Facility type`))))
      gg <- ggplot2::ggplot(sf1, aes(y = `Facility type`, fill = `Facility type`))
      numcolours <- length(unique(sf1[["Facility type"]]))
    }


    gg <- gg + geom_bar(show.legend=FALSE) +
      theme_minimal() +
      geom_text(stat='count', aes(label=..count..), hjust='left') + # hjust=-1) +
      labs(title=paste("Selected facility types from", datasource,"for",country,"( Total =",tot_facilities,")" )) +
      #subtitle= paste("Total =",tot_facilities)) +
      #scale_fill_brewer(palette=brewer_palette) + #problem with scale_fill_brewer when too many classes
      scale_fill_manual(values = colorRampPalette(RColorBrewer::brewer.pal(5, brewer_palette))(numcolours)) +
      #scale_y_reverse() #to get order of cats to match those in map from compare_hs_sources()
      #scale_fill_hue(h = ggcolour_h, c=150) +
      NULL

    plot(gg)

    # return the ggplot object
    invisible(gg)

    # ggplot(sf1, aes(y = amenity, fill = amenity)) +
    #   geom_bar(show.legend=FALSE) +
    #   theme_minimal() +
    #   geom_text(stat='count', aes(label=..count..), hjust='left') + # hjust=-1) +
    #   labs(title=paste("Selected facility types from", datasource,"for",country,"( Total =",tot_facilities,")" ))+
    #        #subtitle= paste("Total =",tot_facilities)) +
    #   NULL


    }

}
