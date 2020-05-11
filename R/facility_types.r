#' get & plot freq of facility types for a country
#'
#'
#' @param country a character vector of country names or iso3c character codes.
#' @param datasource data source, 'healthsites' predownloaded, 'who', 'healthsites_live' needs API, 'hdx' not working yet
#' @param plot option to display map 'mapview' for interactive, 'sf' for static
#' @param type_filter filter healthsites data by amenity. 'all', 'clinic', 'dentist', 'doctors', 'pharmacy', 'hospital'
#'                   to exclude dentist hs_amenity=c('clinic', 'doctors', 'pharmacy', 'hospital')
#' @param plot whether to display plot
# @param who_type filter by Facility type
# @param returnclass 'sf' or 'dataframe', currently 'dataframe' only offered for WHO so that can have points with no coords
# @param type_column just for user provided files which column has information on type of site, default : 'Facility Type'
# @param label_column just for user provided files which column has information on name of site, default : 'Facility Name'
#'
#' @examples
#'
#' sfnga <- facility_types("nigeria", datasource='who', plot='sf')
#'
#' facility_types('chad', datasource='who', plot='sf')
#' facility_types('chad', datasource='healthsites', plot='sf')
#'
#'
#' #filter healthsites data by amenity type
#' facility_types('chad',datasource = 'healthsites', hs_amenity=c('clinic','hospital'))
#' #filter who data by Facility type
#' facility_types('chad',datasource = 'who',who_type=c('Regional hospital','Health Centre'))
#'
#'
#' @return \code{sf}
#' @importFrom ggplot2 ggplot aes geom_bar geom_text theme_minimal labs
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
                      plot = TRUE
                      ) {

  warning('only works for healthsites so far')

  # country <- 'Togo'
  # type_filter = c('clinic', 'doctors', 'pharmacy', 'hospital')
  # type_filter = 'all'
  # datasource = 'healthsites' #'who'

  sf1 <- afrihealthsites(country, datasource = datasource, plot=FALSE, hs_amenity=type_filter) #, who_type=who_type)

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

    # add text labels of frequency
    ggplot(sf1, aes(y = amenity, fill = amenity)) +
      geom_bar(show.legend=FALSE) +
      theme_minimal() +
      geom_text(stat='count', aes(label=..count..), hjust='left') + # hjust=-1) +
      labs(title=paste("Selected facility types from", datasource,"for",country),
           subtitle= paste("Total =",tot_facilities)) +
      NULL


    }

}
